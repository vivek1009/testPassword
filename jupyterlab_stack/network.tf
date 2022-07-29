resource "oci_core_vcn" "generated_oci_core_vcn" {
  cidr_block     = var.jupyterlab_vcn_CIDR
  compartment_id = var.compartment_ocid
  display_name   = join("", ["vcn-", var.workstation_id, "-env"])
  freeform_tags  = { "WorkstationCost" = local.cost_tracking_tag_value }
}

resource "oci_core_subnet" "generated_oci_core_subnet" {
  cidr_block     = var.jupyterlab_subnet_CIDR
  compartment_id = var.compartment_ocid
  display_name   = join("", ["subnet-", var.workstation_id])
  route_table_id = oci_core_vcn.generated_oci_core_vcn.default_route_table_id
  vcn_id         = oci_core_vcn.generated_oci_core_vcn.id
  freeform_tags  = { "WorkstationCost" = local.cost_tracking_tag_value }
}

resource "oci_core_internet_gateway" "subnet_internet_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.generated_oci_core_vcn.id
  display_name   = "internet_gateway_${oci_core_vcn.generated_oci_core_vcn.display_name}"
  freeform_tags  = { "WorkstationCost" = local.cost_tracking_tag_value }
}

resource "oci_core_default_route_table" "subnet_route_table" {
  manage_default_resource_id = oci_core_vcn.generated_oci_core_vcn.default_route_table_id
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.subnet_internet_gateway.id
  }
  freeform_tags  = { "WorkstationCost" = local.cost_tracking_tag_value }
}

resource "oci_core_default_security_list" "subnet_security_list" {
  compartment_id = var.compartment_ocid

  egress_security_rules {
    // allow all egress traffic
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    // allow all SSH
    protocol = var.security_list_ingress_security_rules_protocol
    source   = var.security_list_ingress_security_rules_source
    tcp_options {
      min = var.security_list_ingress_security_rules_tcp_options_ssh_port
      max = var.security_list_ingress_security_rules_tcp_options_ssh_port
    }
  }

  ingress_security_rules {
    protocol    = var.security_list_ingress_security_rules_protocol
    source      = var.security_list_ingress_security_rules_source
    source_type = var.security_list_ingress_security_rules_cidr_source_type
    tcp_options {
      max = var.security_list_ingress_security_rules_tcp_options_jupyterlab_port
      min = var.security_list_ingress_security_rules_tcp_options_jupyterlab_port
    }
  }

  ingress_security_rules {
    protocol    = var.security_list_ingress_security_rules_protocol
    source      = var.security_list_ingress_security_rules_source
    source_type = var.security_list_ingress_security_rules_cidr_source_type
    tcp_options {
      max = var.security_list_ingress_security_rules_tcp_options_novnc_port
      min = var.security_list_ingress_security_rules_tcp_options_novnc_port
    }
  }

  ingress_security_rules {
    protocol    = var.security_list_ingress_security_rules_protocol
    source      = var.security_list_ingress_security_rules_source
    source_type = var.security_list_ingress_security_rules_cidr_source_type
    tcp_options {
      max = var.security_list_ingress_security_rules_tcp_options_ttyd_port
      min = var.security_list_ingress_security_rules_tcp_options_ttyd_port
    }
  }
  manage_default_resource_id = oci_core_vcn.generated_oci_core_vcn.default_security_list_id
  freeform_tags  = { "WorkstationCost" = local.cost_tracking_tag_value }
}
