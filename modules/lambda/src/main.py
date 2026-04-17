"""Lambda handler for AIOps demo."""

import json


def handler(event, context):
    """Handle incoming Lambda invocations."""
    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Hello from Lambda"}),
    }
