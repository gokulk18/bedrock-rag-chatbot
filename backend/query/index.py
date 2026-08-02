import json
import logging
import os
import time
import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ssm_client                   = boto3.client('ssm')
dynamodb_client              = boto3.resource('dynamodb')
bedrock_agent_runtime_client = boto3.client('bedrock-agent-runtime')
bedrock_agent_client         = boto3.client('bedrock-agent')

def handler(event, context):
    headers = {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': '*',
        'Access-Control-Allow-Methods': 'OPTIONS,POST'
    }

    diag = {}

    try:
        body = {}
        if event.get('body'):
            if isinstance(event['body'], str):
                try:
                    body = json.loads(event['body'])
                except Exception:
                    body = {}
            else:
                body = event['body']
        else:
            body = event

        prompt     = body.get('prompt') or body.get('question')
        session_id = body.get('session_id') or body.get('sessionId') or 'default-session'

        if not prompt:
            return {
                'statusCode': 400,
                'headers': headers,
                'body': json.dumps({'error': 'Missing required "prompt" in request body.'})
            }

        # ── Step 1: Read env vars ──────────────────────────────────────
        kb_id_param = os.environ.get('KNOWLEDGE_BASE_ID_PARAM')
        table_name  = os.environ.get('CONVERSATION_TABLE_NAME')
        diag['kb_id_param']  = kb_id_param
        diag['table_name']   = table_name

        # ── Step 2: Fetch KB ID from SSM ──────────────────────────────
        try:
            knowledge_base_id = ssm_client.get_parameter(Name=kb_id_param)['Parameter']['Value']
            diag['knowledge_base_id'] = knowledge_base_id
        except Exception as e:
            diag['ssm_error'] = str(e)
            raise Exception(f"SSM lookup failed for '{kb_id_param}': {e}")

        # ── Step 3: Check KB status ────────────────────────────────────
        try:
            kb_info = bedrock_agent_client.get_knowledge_base(knowledgeBaseId=knowledge_base_id)
            kb_status = kb_info['knowledgeBase']['status']
            diag['kb_status'] = kb_status
            if kb_status != 'ACTIVE':
                raise Exception(f"Knowledge Base is not ACTIVE (status={kb_status}). Sync documents first.")
        except ClientError as e:
            diag['kb_check_error'] = str(e)
            raise Exception(f"Cannot access Knowledge Base '{knowledge_base_id}': {e}")

        # ── Step 4: DynamoDB conversation history ─────────────────────
        table        = dynamodb_client.Table(table_name)
        history_res  = table.get_item(Key={'session_id': session_id})
        history_item = history_res.get('Item', {})
        messages     = history_item.get('messages', [])

        # ── Step 5: Invoke Bedrock with fallback model chain ──────────
        FALLBACK_MODELS = [
            "arn:aws:bedrock:us-east-1::foundation-model/amazon.nova-pro-v1:0",
            "arn:aws:bedrock:us-east-1::foundation-model/us.amazon.nova-pro-v1:0",
            "arn:aws:bedrock:us-east-1::foundation-model/amazon.nova-lite-v1:0",
            "arn:aws:bedrock:us-east-1::foundation-model/us.amazon.nova-lite-v1:0",
            "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-haiku-20240307-v1:0",
            "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-text-express-v1"
        ]

        response   = None
        model_errors = {}

        for model_arn in FALLBACK_MODELS:
            rag_kwargs = {
                'input': {'text': prompt},
                'retrieveAndGenerateConfiguration': {
                    'type': 'KNOWLEDGE_BASE',
                    'knowledgeBaseConfiguration': {
                        'knowledgeBaseId': knowledge_base_id,
                        'modelArn': model_arn
                    }
                }
            }
            if history_item.get('bedrock_session_id'):
                rag_kwargs['sessionId'] = history_item['bedrock_session_id']

            try:
                logger.info(f"Trying model: {model_arn}")
                response = bedrock_agent_runtime_client.retrieve_and_generate(**rag_kwargs)
                logger.info(f"Success with model: {model_arn}")
                break
            except Exception as e:
                err_str = str(e)
                model_errors[model_arn] = err_str
                logger.warning(f"Failed {model_arn}: {err_str}")
                if 'sessionId' in rag_kwargs:
                    try:
                        del rag_kwargs['sessionId']
                        response = bedrock_agent_runtime_client.retrieve_and_generate(**rag_kwargs)
                        break
                    except Exception as inner_e:
                        model_errors[model_arn + ' (no-session)'] = str(inner_e)

        if not response:
            diag['model_errors'] = model_errors
            logger.error(f"All models failed. Diagnostics: {json.dumps(diag)}")
            return {
                'statusCode': 500,
                'headers': headers,
                'body': json.dumps({
                    'error': 'All Bedrock models failed.',
                    'diagnostics': diag
                })
            }

        answer             = response.get('output', {}).get('text', '')
        citations          = response.get('citations', [])
        bedrock_session_id = response.get('sessionId')

        messages.append({
            'user':      prompt,
            'assistant': answer,
            'timestamp': int(time.time())
        })

        table.put_item(Item={
            'session_id':        session_id,
            'bedrock_session_id': bedrock_session_id,
            'messages':          messages,
            'ttl':               int(time.time()) + (30 * 24 * 60 * 60)
        })

        return {
            'statusCode': 200,
            'headers': headers,
            'body': json.dumps({
                'session_id': session_id,
                'answer':     answer,
                'citations':  citations
            })
        }

    except Exception as e:
        diag['fatal_error'] = str(e)
        logger.error(f"Fatal error: {str(e)}", exc_info=True)
        return {
            'statusCode': 500,
            'headers': headers,
            'body': json.dumps({
                'error': str(e),
                'diagnostics': diag
            })
        }


