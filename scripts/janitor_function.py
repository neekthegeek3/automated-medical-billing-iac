import boto3
import email
import os
from email.policy import default

s3 = boto3.client('s3')

def lambda_handler(event, context):
    # Get the bucket and object key from the S3 event
    raw_bucket = event['Records'][0]['s3']['bucket']['name']
    raw_key = event['Records'][0]['s3']['object']['key']
    
    # Destination bucket for the clean PDFs
    dest_bucket = os.environ['DEST_BUCKET']

    # 1. Download the raw email file
    response = s3.get_object(Bucket=raw_bucket, Key=raw_key)
    raw_email_data = response['Body'].read()

    # 2. Parse the email content
    msg = email.message_from_bytes(raw_email_data, policy=default)

    # 3. Iterate through attachments
    for part in msg.iter_attachments():
        filename = part.get_filename()
        
        # Only grab PDFs
        if filename and filename.lower().endswith('.pdf'):
            # Create a clean filename using the S3 key to avoid collisions
            clean_filename = f"processed_{raw_key}_{filename}"
            pdf_data = part.get_payload(decode=True)

            # 4. Upload the stripped PDF to the Intelligence Ingestion bucket
            print(f"Extracting {filename} to {dest_bucket}")
            s3.put_object(
                Bucket=dest_bucket,
                Key=clean_filename,
                Body=pdf_data,
                ContentType='application/pdf',
                ServerSideEncryption='aws:kms', # Hardened Encryption
                SSEKMSKeyId=os.environ['KMS_KEY_ID']
            )

    # 5. SECURITY & COST: Delete the raw email (it contains PII in headers)
    print(f"Cleaning up raw email: {raw_key}")
    s3.delete_object(Bucket=raw_bucket, Key=raw_key)

    return {"status": "Cleaned and Forwarded"}