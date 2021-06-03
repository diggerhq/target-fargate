
{% if environment_config.peer_vpc %}
  # fetch data about the requester VPC
  resource "aws_vpc_peering_connection" "peer_{{environment_config.peer_vpc}}" {
    # peer_owner_id = var.peer_owner_id
    peer_vpc_id   = "{{environment_config.peer_vpc}}"
    vpc_id        = aws_vpc.vpc.id
    auto_accept   = false

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


  # Accepter's side of the connection.
  resource "aws_vpc_peering_connection_accepter" "peer" {
    vpc_peering_connection_id = aws_vpc_peering_connection.peer_{{environment_config.peer_vpc}}.id
    auto_accept               = true
  }  

  resource "aws_route" "requestor_{{peer_vpc}}" {
    route_table_id = aws_route_table.route_table_public.id
    destination_cidr_block = var.vpcCIDRblock
    vpc_peering_connection_id = aws_vpc_peering_connection.peer_{{environment_config.peer_vpc}}.id
  }


{% endif %}
