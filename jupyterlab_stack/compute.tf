resource "oci_core_instance" "jupyterlab_instance" {
  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file)
    user_data           = base64encode(local.bootstrap_configure_file)
  }
  agent_config {
    is_management_disabled = "false"
    is_monitoring_disabled = "false"
    plugins_config {
      desired_state = "DISABLED"
      name          = "Vulnerability Scanning"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "OS Management Service Agent"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Management Agent"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Custom Logs Monitoring"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Compute Instance Run Command"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Compute Instance Monitoring"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Block Volume Management"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Bastion"
    }
  }
  availability_config {
    recovery_action = "RESTORE_INSTANCE"
  }
  availability_domain = data.oci_identity_availability_domains.service_ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  create_vnic_details {
    assign_private_dns_record = "true"
    assign_public_ip          = "false"
    freeform_tags             = { "stackType" = var.stack_type, "stackName" = var.workstation_id }
    subnet_id                 = oci_core_subnet.generated_oci_core_subnet.id
  }
  display_name = join("", ["jupyterlab-inst-", var.workstation_id])
  instance_options {
    are_legacy_imds_endpoints_disabled = "false"
  }
  is_pv_encryption_in_transit_enabled = "true"
  shape                               = local.instance_type_hashmap[var.jupyterlab_instance_shape_and_size]["shape"]
  shape_config {
    memory_in_gbs = local.instance_type_hashmap[var.jupyterlab_instance_shape_and_size]["cpu_mem"]
    ocpus         = local.instance_type_hashmap[var.jupyterlab_instance_shape_and_size]["cpu_count"]
  }
  source_details {
    source_id   = var.jupyterlab_instance_image_ocid
    source_type = "image"
  }
  freeform_tags  = { "WorkstationCost" = local.cost_tracking_tag_value }
}

resource "oci_core_public_ip" "jupyterlab_instance_public_ip" {
  compartment_id = var.compartment_ocid
  display_name   = "jupyterlab_instance_public_ip"
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.jupyterlab_instance_private_ip.private_ips[0]["id"]
  freeform_tags  = { "WorkstationCost" = local.cost_tracking_tag_value }
}
