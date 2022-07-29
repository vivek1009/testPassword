resource "oci_file_storage_file_system" "user_file_system" {
  #Required
  availability_domain = data.oci_identity_availability_domains.service_ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  freeform_tags  = { "WorkstationCost" = local.cost_tracking_tag_value }

  #Optional
  #defined_tags = {"Operations.CostCenter"= "42"}
  display_name = join("", [var.workstation_id, "_fs"])
  #freeform_tags = {"Department"= "Finance"}
}