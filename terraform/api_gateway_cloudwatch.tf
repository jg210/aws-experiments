# This file sets up permissions that allow API gateway to send logs to CloudWatch. It's 
# aws_api_gateway_method_settings that controls what (if anything) is sent though.

resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.main.arn
}

resource "aws_iam_role" "main" {
  name = "api-gateway-logs-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  #checkov:skip=CKV_AWS_338:don't want to pay for over 365 days of log retention
  #checkov:skip=CKV_AWS_158:TODO KMS encryption?
  name = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.api.id}/production"
  retention_in_days = 7
}