data "aws_s3_object" "lambda" {
  bucket = "aws-experiments"
  key    = "artifacts/uk/me/jeremygreen/spring-experiments/1.0/spring-experiments-1.0-aws.jar"
}

resource "aws_lambda_function" "spring_experiments" {
  function_name = "spring_experiments"
  s3_bucket = data.aws_s3_object.lambda.bucket
  s3_key = data.aws_s3_object.lambda.key
  source_code_hash = data.aws_s3_object.lambda.etag
  handler = "uk.me.jeremygreen.springexperiments.StreamLambdaHandler::handleRequest"
  runtime = "java17"
  reserved_concurrent_executions = 5
  timeout = "15"
  role = aws_iam_role.spring_experiments.arn
  environment {
    variables = {
      JAVA_TOOL_OPTIONS = "-Dlogging.level.org.springframework.web=DEBUG"
      # JAVA_TOOL_OPTIONS = "-Dlogging.level.root=DEBUG"
    }
  }
}

resource "aws_iam_role" "spring_experiments" {
  name = "spring_experiments"
  assume_role_policy = data.aws_iam_policy_document.lambda_role_policy.json
}

data "aws_iam_policy_document" "lambda_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "aws_experiments_download_by_lambda" {
  role = aws_iam_role.spring_experiments.name
  policy_arn = aws_iam_policy.aws_experiments_download.arn
}

resource "aws_iam_role_policy_attachment" "lambda_AWSLambdaBasicExecutionRole" {
  role = aws_iam_role.spring_experiments.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "spring_experiments" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.spring_experiments.function_name
  principal = "apigateway.amazonaws.com"
  # "/*/*" => any method and any resource.
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "spring_experiments" {
  #checkov:skip=CKV_AWS_338:don't want to pay for over 365 days of log retention
  name = "/aws/lambda/spring_experiments"
  retention_in_days = 7
}