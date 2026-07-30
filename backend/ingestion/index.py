import json
import logging
import os
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ssm_client = boto3.client('ssm')
bedrock_agent_client = boto3.client('bedrock-agent')

def handler(event, context):
    logger.info(f"Received S3 event trigger: {json.dumps(event)}")
    
    kb_id_param = os.environ.get('KNOWLEDGE_BASE_ID_PARAM')
    data_source_id = os.environ.get('DATA_SOURCE_ID')
    
    try:
        kb_param_response = ssm_client.get_parameter(Name=kb_id_param)
        knowledge_base_id = kb_param_response['Parameter']['Value']
        logger.info(f"Fetched Knowledge Base ID from SSM: {knowledge_base_id}")
        
        response = bedrock_agent_client.start_ingestion_job(
            knowledgeBaseId=knowledge_base_id,
            dataSourceId=data_source_id
        )
        
        ingestion_job_id = response['ingestionJob']['ingestionJobId']
        logger.info(f"Successfully started Bedrock ingestion job: {ingestion_job_id}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Ingestion job started successfully',
                'ingestionJobId': ingestion_job_id,
                'knowledgeBaseId': knowledge_base_id
            })
        }
    except Exception as e:
        logger.error(f"Error starting ingestion job: {str(e)}")
        raise e
