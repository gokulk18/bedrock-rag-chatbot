import json
import os
from datetime import datetime, timezone

import boto3

bedrock = boto3.client("bedrock-agent-runtime")
dynamodb = boto3.resource("dynamodb")


def lambda_handler(event, _context):
    body = json.loads(event.get("body") or "{}")
    question = body.get("question", "").strip()
    if not question:
        return _response(400, {"message": "'question' is required"})

    configuration = {
        "type": "KNOWLEDGE_BASE",
        "knowledgeBaseConfiguration": {
            "knowledgeBaseId": os.environ["KNOWLEDGE_BASE_ID"],
            "modelArn": os.environ["MODEL_ARN"],
        },
    }
    request = {
        "input": {"text": question},
        "retrieveAndGenerateConfiguration": configuration,
    }
    if body.get("session_id"):
        request["sessionId"] = body["session_id"]
    result = bedrock.retrieve_and_generate(**request)
    session_id = result["sessionId"]
    now = datetime.now(timezone.utc).isoformat()
    dynamodb.Table(os.environ["CONVERSATIONS_TABLE"]).put_item(Item={
        "session_id": session_id,
        "timestamp": now,
        "question": question,
        "answer": result["output"]["text"],
    })
    return _response(200, {
        "session_id": result["sessionId"],
        "answer": result["output"]["text"],
        "citations": result.get("citations", []),
    })


def _response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(body, default=str),
    }
