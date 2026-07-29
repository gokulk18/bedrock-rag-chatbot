import os

import boto3

bedrock = boto3.client("bedrock-agent")


def lambda_handler(event, _context):
    """Starts an idempotent KB sync after an S3 create/delete EventBridge event."""
    response = bedrock.start_ingestion_job(
        knowledgeBaseId=os.environ["KNOWLEDGE_BASE_ID"],
        dataSourceId=os.environ["DATA_SOURCE_ID"],
        clientToken=event.get("id", "manual-sync"),
        description="S3 document change synchronization",
    )
    return {"ingestion_job": response["ingestionJob"]["ingestionJobId"]}
