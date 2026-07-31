import json
import logging
import os
import time
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ssm_client = boto3.client('ssm')
dynamodb_client = boto3.resource('dynamodb')
bedrock_agent_runtime_client = boto3.client('bedrock-agent-runtime')

def handler(event, context):
    logger.info(f"Received request event: {json.dumps(event)}")
    
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

    prompt = body.get('prompt') or body.get('question')
    session_id = body.get('session_id') or body.get('sessionId') or 'default-session'
    
    if not prompt:
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': 'Missing required "prompt" in request body.'})
        }
        
    kb_id_param = os.environ.get('KNOWLEDGE_BASE_ID_PARAM')
    model_id_param = os.environ.get('MODEL_ID_PARAM')
    table_name = os.environ.get('CONVERSATION_TABLE_NAME')
    
    try:
        model_id = ssm_client.get_parameter(Name=model_id_param)['Parameter']['Value']
        knowledge_base_id = ssm_client.get_parameter(Name=kb_id_param)['Parameter']['Value']
        
        table = dynamodb_client.Table(table_name)
        history_res = table.get_item(Key={'session_id': session_id})
        history_item = history_res.get('Item', {})
        messages = history_item.get('messages', [])
        
        if model_id.startswith('arn:'):
            primary_arn = model_id
        else:
            primary_arn = f"arn:aws:bedrock:us-east-1::foundation-model/{model_id}"

        candidate_arns = [
            primary_arn,
            "arn:aws:bedrock:us-east-1::foundation-model/us.anthropic.claude-3-5-sonnet-20241022-v2:0",
            "arn:aws:bedrock:us-east-1::foundation-model/us.anthropic.claude-3-5-sonnet-20240620-v1:0",
            "arn:aws:bedrock:us-east-1::foundation-model/amazon.nova-lite-v1:0",
            "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-text-express-v1"
        ]

        response = None
        last_error = None

        for candidate_arn in candidate_arns:
            rag_kwargs = {
                'input': {'text': prompt},
                'retrieveAndGenerateConfiguration': {
                    'type': 'KNOWLEDGE_BASE',
                    'knowledgeBaseConfiguration': {
                        'knowledgeBaseId': knowledge_base_id,
                        'modelArn': candidate_arn
                    }
                }
            }
            if history_item.get('bedrock_session_id'):
                rag_kwargs['sessionId'] = history_item.get('bedrock_session_id')

            try:
                logger.info(f"Attempting RetrieveAndGenerate with modelArn: {candidate_arn}")
                response = bedrock_agent_runtime_client.retrieve_and_generate(**rag_kwargs)
                break
            except Exception as e:
                err_str = str(e)
                logger.warning(f"Failed with {candidate_arn}: {err_str}")
                last_error = e

                # If session ID was stale, retry without session ID first
                if 'sessionId' in rag_kwargs and ('cannot be modified' in err_str.lower() or 'validationexception' in err_str.lower()):
                    try:
                        del rag_kwargs['sessionId']
                        response = bedrock_agent_runtime_client.retrieve_and_generate(**rag_kwargs)
                        break
                    except Exception as retry_err:
                        last_error = retry_err
                        continue

        if not response:
            raise last_error
        
        answer = response.get('output', {}).get('text', '')
        citations = response.get('citations', [])
        bedrock_session_id = response.get('sessionId')
        
        new_turn = {
            'user': prompt,
            'assistant': answer,
            'timestamp': int(time.time())
        }
        messages.append(new_turn)
        
        table.put_item(
            Item={
                'session_id': session_id,
                'bedrock_session_id': bedrock_session_id,
                'messages': messages,
                'ttl': int(time.time()) + (30 * 24 * 60 * 60)
            }
        )
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'session_id': session_id,
                'answer': answer,
                'citations': citations
            })
        }
    except Exception as e:
        logger.error(f"Error processing query request: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': str(e)})
        }
