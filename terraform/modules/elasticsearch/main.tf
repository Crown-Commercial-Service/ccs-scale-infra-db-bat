##########################################################
# Elasticsearch
##########################################################

module "globals" {
  source = "../globals"
}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_security_group" "es" {
  name   = "elasticsearch"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.security_group_ids
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticsearch_domain" "main" {
  domain_name             = "scale-eu2-${lower(var.environment)}-es-spree"
  elasticsearch_version   = "7.4"

  cluster_config {
    instance_type          = var.es_instance_type
    instance_count         = length(var.private_app_subnet_ids)
    zone_awareness_enabled = true

    zone_awareness_config {
      availability_zone_count = length(var.private_app_subnet_ids)
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.es_ebs_volume_size
  }

  vpc_options {
    subnet_ids         = var.private_app_subnet_ids
    security_group_ids = [aws_security_group.es.id]
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  encrypt_at_rest {
    enabled = var.encrypt_at_rest
  }

  node_to_node_encryption {
    enabled = true
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

resource "aws_elasticsearch_domain_policy" "main" {
  domain_name = aws_elasticsearch_domain.main.domain_name

  access_policies = <<POLICIES
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "es:*",
            "Principal": {
              "AWS": "*"
            },
            "Resource": "${aws_elasticsearch_domain.main.arn}/*"
        }
    ]
}
POLICIES
}

resource "aws_ssm_parameter" "es_url" {
  name      = "/bat/${lower(var.environment)}-elasticsearch-url"
  type      = "String"
  value     = aws_elasticsearch_domain.main.endpoint
  overwrite = true
}
