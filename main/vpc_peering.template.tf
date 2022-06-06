
{% if environment_config.peer_vpc %}
  # fetch data about the requester VPC

  # additional provider
  provider "aws" {
    alias  = "accepter"
    {% if environment_config.peer_vpc_region %}
    region = "{{environment_config.peer_vpc_region}}"
    {% else %}
    region  = var.region
    {% endif %}
    # profile = var.aws_profile
    {% if assume_role_arn %}
    assume_role {
      role_arn={{assume_role_arn}}
      external_id={{assume_role_external_id}}
    }
    {% else %}
    access_key = var.aws_key
    secret_key = var.aws_secret
    {% endif %}
  }

  data "aws_vpc" "accepter" {
    provider = aws.accepter
    id = "{{environment_config.peer_vpc}}"
  }

  resource "aws_vpc_peering_connection" "peer_{{environment_config.peer_vpc}}" {
    # peer_owner_id = var.peer_owner_id
    peer_vpc_id   = "{{environment_config.peer_vpc}}"
    vpc_id        = local.vpc.id
    auto_accept   = false

    {% if environment_config.peer_vpc_region %}
    peer_region = "{{environment_config.peer_vpc_region}}"
    {% endif %}

    tags = {
      Name = "${var.ecs_cluster_name}-${var.environment}-PeerVPC"
    }
    # accepter {
    #   allow_remote_vpc_dns_resolution = true
    # }

    # requester {
    #   allow_remote_vpc_dns_resolution = true
    # }
  }


  # Accepter's side of the connection.
  resource "aws_vpc_peering_connection_accepter" "peer" {
    provider = aws.accepter
    vpc_peering_connection_id = aws_vpc_peering_connection.peer_{{environment_config.peer_vpc}}.id
    auto_accept               = true
  }  

  resource "aws_route" "requestor_{{environment_config.peer_vpc}}" {
    route_table_id = aws_route_table.route_table_public.id
    destination_cidr_block = data.aws_vpc.accepter.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer_{{environment_config.peer_vpc}}.id
  }


{% endif %}
