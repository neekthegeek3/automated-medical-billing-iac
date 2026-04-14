import boto3
import json
import os
from datetime import datetime, timezone

# AWS Clients
textract = boto3.client('textract')
bedrock = boto3.client('bedrock-runtime')
dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    try:
        # 1. Get the bucket and file from the S3 trigger
        # This is the 'processed_' file coming from the Janitor
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']
        document_id = key.split('/')[-1]

        # 2. Extract Text using Amazon Textract (The 'Eyes')
        print(f"Analyzing document: {key}")
        response = textract.analyze_document(
            Document={'S3Object': {'Bucket': bucket, 'Name': key}},
            FeatureTypes=['FORMS', 'TABLES']
        )
        
        # Clean the OCR output into a single string
        raw_text = " ".join([
            item['Text'] for item in response['Blocks'] 
            if item['BlockType'] == 'LINE'
        ])

        # 3. Intelligence Module: Amazon Bedrock (The 'Brain')
        # We use Claude 3 Haiku for the best speed/cost ratio
        prompt = f"""
        Human: You are a professional Medical Coding & Billing Expert. 
        Analyze the clinical text provided and extract the following into a JSON object:
        1. PatientName
        2. Diagnosis (Primary)
        3. ICD10_Codes (List)
        4. CPT_Codes (List)
        5. Justification (Briefly explain why these codes were chosen)

        Clinical Note: {raw_text}
        
        Return ONLY the JSON. No conversational filler.
        Assistant:"""

        body = json.dumps({
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 1000,
            "messages": [{"role": "user", "content": prompt}],
            "temperature": 0 # Set to 0 for deterministic, factual accuracy
        })

        ai_response = bedrock.invoke_model(
            modelId="anthropic.claude-3-haiku-20240307-v1:0",
            body=body
        )
        
        # 4. JSON Parsing & Sanitization
        raw_completion = json.loads(ai_response.get('body').read())
        extracted_text = raw_completion['content'][0]['text']

        # Remove potential Markdown code blocks if the AI includes them
        clean_json_str = extracted_text.replace('```json', '').replace('```', '').strip()
        final_data = json.loads(clean_json_str)

        # 5. Permanent Storage: DynamoDB (The 'Vault')
        # Ensure your environment variable matches your root main.tf (TABLE_NAME)
        table = dynamodb.Table(os.environ['TABLE_NAME'])
        table.put_item(
            Item={
                'DocumentId': document_id,
                'ProcessedDate': datetime.now(timezone.utc).isoformat(),
                'BillingData': final_data,
                'Status': 'COMPLETED',
                'RawTextSnippet': raw_text[:1000] # Audit trail
            }
        )

        print(f"Successfully processed {document_id}")
        return {"status": "success", "document_id": document_id}

    except Exception as e:
        print(f"CRITICAL ERROR: {str(e)}")
        # In a production MSP environment, you'd trigger an SNS alert here
        raise e