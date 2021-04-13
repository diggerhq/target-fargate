
resource "aws_api_gateway_vpc_link" "main" {
  name        = "${var.ecs_cluster.name}-${var.service_name}"
  description = "allows public API Gateway for ${var.ecs_cluster.name}-${var.service_name} to talk to private NLB"
  target_arns = [aws_lb.main.arn]
}

resource "aws_api_gateway_rest_api" "main" {
  name = "${var.ecs_cluster.name}-${var.service_name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_authorizer" "cognito_auth" {
  name = "cognito"
  rest_api_id = aws_api_gateway_rest_api.main.id
  type = "COGNITO_USER_POOLS"
  provider_arns = [var.cognito_user_pools_arn]
}


resource "aws_api_gateway_method" "main" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.main.id
  http_method      = "ANY"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id
  api_key_required = false
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method" "options" {
    rest_api_id   = "${aws_api_gateway_rest_api.main.id}"
    resource_id   = "${aws_api_gateway_resource.main.id}"
    http_method   = "OPTIONS"
    authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_200" {
    rest_api_id   = "${aws_api_gateway_rest_api.main.id}"
    resource_id   = "${aws_api_gateway_resource.main.id}"
    http_method   = "${aws_api_gateway_method.options.http_method}"
    status_code   = "200"
    response_models = {
        "application/json" = "Empty"
    }
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
    }
    depends_on = ["aws_api_gateway_method.options"]
}

resource "aws_api_gateway_integration" "options_integration" {
    rest_api_id   = "${aws_api_gateway_rest_api.main.id}"
    resource_id   = "${aws_api_gateway_resource.main.id}"
    http_method   = "${aws_api_gateway_method.options.http_method}"
    type          = "MOCK"
    depends_on = ["aws_api_gateway_method.options"]
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
    rest_api_id   = "${aws_api_gateway_rest_api.main.id}"
    resource_id   = "${aws_api_gateway_resource.main.id}"
    http_method   = "${aws_api_gateway_method.options.http_method}"
  status_code   = "${aws_api_gateway_method_response.options_200.status_code}"
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }
    depends_on = ["aws_api_gateway_method_response.options_200"]
}

resource "aws_api_gateway_integration" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${aws_lb.main.dns_name}/{proxy}"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.main.id
  timeout_milliseconds    = 29000 # 50-29000

  cache_key_parameters = ["method.request.path.proxy"]
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_method_response" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method
  status_code = aws_api_gateway_method_response.main.status_code

  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_api_gateway_integration.main
  ]
}

resource "aws_api_gateway_deployment" "main" {
  depends_on  = ["aws_api_gateway_integration.main"]
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = "v1"
}


data "aws_route53_zone" "main" {
  name = var.zone
}

resource "aws_api_gateway_domain_name" "main" {
  domain_name              = var.domain
  regional_certificate_arn = var.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = aws_api_gateway_domain_name.main.domain_name
  type    = "CNAME"
  records = [aws_api_gateway_domain_name.main.regional_domain_name]
  ttl     = "60"
}


resource "aws_api_gateway_base_path_mapping" "main" {
  api_id      = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_deployment.main.stage_name
  domain_name = aws_api_gateway_domain_name.main.domain_name
}

# The API Gateway endpoint
output "api_gateway_endpoint" {
  value = "https://${aws_api_gateway_domain_name.main.domain_name}"
}