output "instance_public_ip" {
  value       = oci_core_public_ip.jupyterlab_instance_public_ip.ip_address
  description = "The public IP address of the core instance."
}

output "cost_tracking_tag_value" {
  value       = local.cost_tracking_tag_value
  description = "Tag value for a specific stack cost tracking."
}

output "instance_urls" {
  value = {
    jupyter = {
      url           = join("", ["http://", oci_core_public_ip.jupyterlab_instance_public_ip.ip_address, ":", var.security_list_ingress_security_rules_tcp_options_jupyterlab_port]),
      documentation = "https://jupyter-notebook.readthedocs.io/en/stable/",
      name          = "Jupyter"
    },
    vnc = {
      url = join("", ["http://", oci_core_public_ip.jupyterlab_instance_public_ip.ip_address, ":", var.security_list_ingress_security_rules_tcp_options_novnc_port, "/vnc.html"]),
      documentation = "https://tigervnc.org/",
      name          = "Virtual Desktop"
    }
    ttyd = {
      url = join("", ["http://", oci_core_public_ip.jupyterlab_instance_public_ip.ip_address, ":", var.security_list_ingress_security_rules_tcp_options_ttyd_port]),
      documentation = "https://github.com/tsl0922/ttyd#readme",
      name          = "TTYD"
    }
  }
  description = "access urls"
}