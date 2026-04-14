resource "aws_route53_record" "ses_mx" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "MX"
  ttl     = "600"
  records = ["10 inbound-smtp.${var.aws_region}.amazonaws.com"]
}

# Verification TXT record so AWS knows you own the domain
resource "aws_route53_record" "ses_verification" {
  zone_id = var.hosted_zone_id
  name    = "_amazonses.${var.domain_name}"
  type    = "TXT"
  ttl     = "600"
  records = [var.ses_verification_token]
}
