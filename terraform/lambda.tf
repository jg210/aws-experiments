data "archive_file" "lambda_zip" {
  type = "zip"
  source_dir = "../resources/lambda"
  output_path = "../resources/lambda.zip"
}

resource "aws_lambda_function" "hello" {
  function_name = "hello"
  filename = "../resources/lambda.zip"
  handler = "lambda.hello"
  runtime = "nodejs10.x"
  role = aws_iam_role.hello.arn
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

resource "aws_iam_role" "hello" {
  name = "hello"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "hello" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello.function_name
  principal = "apigateway.amazonaws.com"
  # "/*/*" => any method and any resource1.
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
