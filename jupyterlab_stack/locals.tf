locals {
  # memory units are in GB
  small_instance_cpu_and_memory  = tomap({ "cpu_count" = 1, "cpu_mem" = 16, shape = "VM.Standard.E4.Flex" })
  medium_instance_cpu_and_memory = tomap({ "cpu_count" = 20, "cpu_mem" = 64, shape = "VM.Standard.E4.Flex" })
  large_instance_cpu_and_memory  = tomap({ "cpu_count" = 40, "cpu_mem" = 120, shape = "VM.Standard.E4.Flex" })
  gpu_instance_cpu_and_memory    = tomap({ "cpu_count" = 6, "cpu_mem" = 90, "gpu_mem" = 16, shape = "VM.GPU3.1" })

  instance_type_hashmap = tomap({
    "small" : local.small_instance_cpu_and_memory,
    "medium" : local.medium_instance_cpu_and_memory,
    "large" : local.large_instance_cpu_and_memory,
  "gpu" : local.gpu_instance_cpu_and_memory })

  # Local to control subscription to Marketplace image.
  mp_subscription_enabled = var.mp_subscription_enabled ? 1 : 0

  # Marketplace Image listing variables - required for subscription only
  listing_id               = var.mp_listing_id
  listing_resource_id      = var.mp_listing_resource_id
  listing_resource_version = var.mp_listing_resource_version

  bootstrap_configure_file = templatefile(var.bootstrap_file, {
    password = var.password
    jupyter_port = var.jupyter_port
    vnc_port = var.vnc_port
    ttyd_port = var.ttyd_port
    uname = var.ttyd_username
  })

  # Auto generated cost tracking tag value
  cost_tracking_tag_value = "${uuid()}"
}
