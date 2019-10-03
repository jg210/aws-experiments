resource "aws_api_gateway_rest_api" "api" {
  name = "api"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "GET"
  authorization = "NONE"
}

# resource "aws_api_gateway_method" "proxy_root" {
#   rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
#   resource_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
#   http_method   = "GET"
#   authorization = "NONE"
# }

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.hello.invoke_arn}"
}

# resource "aws_api_gateway_integration" "lambda_root" {
#   rest_api_id = "${aws_api_gateway_rest_api.api.id}"
#   resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
#   http_method = "${aws_api_gateway_method.proxy_root.http_method}"
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = "${aws_lambda_function.hello.invoke_arn}"
# }

resource "aws_api_gateway_deployment" "api_production" {
  depends_on = [
    "aws_api_gateway_integration.lambda"
    #"aws_api_gateway_integration.lambda_root",
  ]
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "production"
}

resource "aws_api_gateway_method_settings" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name = "${aws_api_gateway_deployment.api_production.stage_name}"
  method_path = "*/*"
  settings {
    throttling_burst_limit = 5
    throttling_rate_limit = 10
  }
}
