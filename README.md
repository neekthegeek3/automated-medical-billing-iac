# automated-medical-billing-iac
This project is designed as a foundational "Department Eliminator." While the infrastructure is built to enterprise standards, users are responsible for ensuring specific regulatory compliance (HIPAA/GDPR) based on their final AI prompts and data handling policies.

This documentation is written to reflect your 8+ years of IT experience, using professional terminology that will resonate with potential clients and employers. It emphasizes the "Sovereign" nature of the build and the high-compliance standards (HIPAA/KMS) you’ve implemented.

### Final Launch Steps (The "Go-Live" Sequence)

To get this launched successfully, follow this specific order:

1.  **AWS Console Action:** Log in to the AWS Console in `us-west-1`. Go to **Amazon Bedrock > Model Access** and request access for **Claude 3 Haiku**. This usually takes 1-5 minutes to approve.
2.  **DNS Preparation:** Ensure your domain is already a **Public Hosted Zone** in Route 53. Grab that `Zone ID`.
3.  **Local Setup:** * Create your `terraform.tfvars` using the template in the README.
    * Ensure your `scripts/` folder contains exactly two files: `janitor_function.py` and `processor.py`.
4.  **Terminal Sequence:**
    ```bash
    terraform init
    terraform plan   # Review this carefully to ensure 40+ resources are being created
    terraform apply
    ```
5.  **The "Handshake" Test:**
    * Once deployed, the terminal will output your `ses_domain`.
    * Send an email with a sample medical PDF attachment to `inbox@yourdomain.com`.
    * Monitor the **Lambda CloudWatch Logs** for the `processor` function. You should see the AI's JSON output within 15 seconds of the email landing.

### One Final GitHub Tip
Before you push to GitHub, create a file named `.gitignore` in the root and add these lines so you don't leak your private info:
```text
.terraform/
*.tfstate
*.tfstate.backup
*.tfvars
*.zip

---
## Altan ACAI Ecosystem
This repository is a specialized implementation of the [Altan ACAI Core](https://github.com/neekthegeek3/altan-acai-core) framework. While the Core repository handles the overarching business logic and strategy, this repo provides the production-ready Terraform modules for medical-specific deployments.
