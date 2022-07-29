data "oci_identity_availability_domains" "service_ads" {
  compartment_id = var.compartment_ocid
}

data "oci_objectstorage_namespace" "namespace" {
  compartment_id = var.compartment_ocid
}

data "oci_core_private_ips" "jupyterlab_instance_private_ip" {
  ip_address = oci_core_instance.jupyterlab_instance.private_ip
  subnet_id  = oci_core_subnet.generated_oci_core_subnet.id
}