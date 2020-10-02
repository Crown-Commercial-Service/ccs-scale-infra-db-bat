##########################################################
# Elasticsearch
##########################################################

module "globals" {
  source = "../globals"
}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

# TODO: Tighten Security Group
resource "aws_security_group" "es" {
  name   = "elasticsearch"
  vpc_id = var.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticsearch_domain" "main" {
  domain_name           = "scale-eu2-${lower(var.environment)}-es-spree"
  elasticsearch_version = "7.4"

  cluster_config {
    instance_type = "t2.medium.elasticsearch"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  vpc_options {
    subnet_ids         = var.private_app_subnet_ids
    security_group_ids = [aws_security_group.es.id]
  }

  depends_on = [
    aws_iam_service_linked_role.es,
  ]

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "ES"
  }
}

resource "aws_ssm_parameter" "es_url" {
  name      = "/bat/${lower(var.environment)}-elasticsearch-url"
  type      = "String"
  value     = aws_elasticsearch_domain.main.endpoint
  overwrite = true
}

