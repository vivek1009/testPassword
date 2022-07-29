# This image refers to approved image from marketplace used for publishing stack
variable "marketplace_source_images" {
  type = map(object({
    ocid                  = string
    is_pricing_associated = bool
    compatible_shapes     = list(string)
  }))
  default = {
    main_mktpl_image = {
      ocid                  = "ocid1.image.oc1..aaaaaaaa43vs2zfe7fmoapk7vkndh5q6csi6ipromtesexdaqan3wupljvcq"
      is_pricing_associated = false
      compatible_shapes     = []
    }
  }
}
