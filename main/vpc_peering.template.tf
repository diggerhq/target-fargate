
{% if environment_config.peer_vpcs %}
  {% set peer_vpcs = environment_config.peer_vpcs.split(",") %}

  {% for peer_vpc in peer_vpcs %}

    resource "aws_vpc_peering_connection" "peer_{{peer_vpc}}" {
      # peer_owner_id = var.peer_owner_id
      peer_vpc_id   = "{{peer_vpc}}"
      vpc_id        = aws_vpc.vpc.id
    }

  {% endfor %}
{% endif %}
