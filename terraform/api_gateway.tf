resource "aws_api_gateway_rest_api" "api" {
  name = "api"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.spring_experiments.invoke_arn
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.spring_experiments.invoke_arn
 }

resource "aws_api_gateway_deployment" "api_production" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  lifecycle {
    create_before_destroy = true
  }
  triggers = {
    # "using whole resources will show a difference after the initial implementation.
    # It will stabilize to only change when resources change afterwards."
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy,
      aws_api_gateway_method.proxy,
      aws_api_gateway_method.proxy_root,
      aws_api_gateway_integration.lambda,
      aws_api_gateway_integration.lambda_root,
    ]))
  }
  stage_name  = "production"
}

resource "aws_api_gateway_method_settings" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name = aws_api_gateway_deployment.api_production.stage_name
  method_path = "*/*"
  settings {
    throttling_burst_limit = 5
    throttling_rate_limit = 10
    logging_level      = "INFO"
    metrics_enabled    = true
    data_trace_enabled = true
  }
}

data "aws_acm_certificate" "api" {
  domain = "*.${var.domain}"
  statuses = ["ISSUED"]
  most_recent = true
}

resource "aws_api_gateway_domain_name" "api" {
  domain_name = "${var.subdomain_api}.${var.domain}"
  regional_certificate_arn = data.aws_acm_certificate.api.arn
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  provisioner "local-exec" {
    command = "curl --verbose --data-urlencode \"domain=${var.domain}\" --data-urlencode \"password@$${HOME}/.dns-api-password\" --data-urlencode \"command=REPLACE ${var.subdomain_api} 60 CNAME ${aws_api_gateway_domain_name.api.regional_domain_name}.\" \"$(cat $${HOME}/.dns-api-url)\""
  }
}

resource "aws_api_gateway_base_path_mapping" "api" {
  api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_deployment.api_production.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name
}
