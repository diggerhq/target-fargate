
{% if environment_config.peer_vpc %}
  # fetch data about the requester VPC
  data "aws_vpc" "requester" {
    id    = aws_vpc.vpc.id
  }

  data "aws_route_tables" "requester" {
    vpc_id = aws_vpc.vpc.id
  }

  resource "aws_vpc_peering_connection" "peer_{{peer_vpc}}" {
    # peer_owner_id = var.peer_owner_id
    peer_vpc_id   = "{{peer_vpc}}"
    vpc_id        = aws_vpc.vpc.id

    {% if environment_config.peer_vpc_region %}
    peer_region = "{{environment_config.peer_vpc_region}}"
    {% endif %}

    accepter {
      allow_remote_vpc_dns_resolution = true
    }

    # requester {
    #   allow_remote_vpc_dns_resolution = true
    # }
  }

  resource "aws_route" "requestor_{{peer_vpc}}" {
    count = length(data.aws_route_tables.requester.ids)
    route_table_id = data.aws_route_tables.requester.ids[count.index]
    destination_cidr_block = var.vpcCIDRblock
    vpc_peering_cononection_id = aws_vpc_peering_connection.peer_{{peer_vpc}}.id
  }


{% endif %}
