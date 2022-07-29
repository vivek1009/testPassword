variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
variable "workstation_id" {}

variable "password" {
  sensitive = true
  type = password
}

variable "jupyter_port" { default = "8888/tcp" }
variable "vnc_port" { default = "5801/tcp" }
variable "ttyd_port" { default = "7681/tcp" }


variable "jupyterlab_instance_shape_and_size" { default = "small" }
variable "stack_type" { default = "JupyterlabResearchStack" }
variable "jupyterlab_instance_image_ocid" {
  default = "ocid1.image.oc1.iad.aaaaaaaanxbmz7rm7tkopukbbahtcbcx45v5omusafwhjaenzf7tkcoq56qa"
}
variable "jupyterlab_vcn_CIDR" { default = "10.0.0.0/16" }
variable "jupyterlab_subnet_CIDR" { default = "10.0.0.0/24" }

variable "security_list_ingress_security_rules_protocol" { default = 6 }
variable "security_list_ingress_security_rules_source" { default = "0.0.0.0/0" }
variable "security_list_ingress_security_rules_cidr_source_type" { default = "CIDR_BLOCK"}
variable "security_list_ingress_security_rules_tcp_options_jupyterlab_port" { default = 8888 }
variable "security_list_ingress_security_rules_tcp_options_novnc_port" { default = 5801 }
variable "security_list_ingress_security_rules_tcp_options_ssh_port" { default = 22 }
variable "security_list_ingress_security_rules_tcp_options_ttyd_port" { default = 7681 }

variable "ssh_public_key_file" {
  default = "./ssh_public_key_file.pub"
}

variable "bootstrap_file" {
  default = "./bootstrap.sh"
}

variable "mp_subscription_enabled" {
  description = "Subscribe to Marketplace listing?"
  type        = bool
  default     = false
}

variable "mp_listing_id" {
  default     = ""
  description = "Marketplace Listing OCID"
}

variable "mp_listing_resource_id" {
  default     = ""
  description = "Marketplace Listing Image OCID"
}

variable "mp_listing_resource_version" {
  default     = ""
  description = "Marketplace Listing Package/Resource Version"
}

variable "ttyd_username" {
  type = string
}
