# A basic config using Secure By Default (SBD) certs pointing to a origin and reusing same edgeHostname
# Configure the Akamai Terraform Provider to use betajam credentials via .edgerc or TF_VAR environment vars.
provider "akamai" {
  /* config {
    access_token = var.akamai_access_token
    host = var.akamai_host
    client_token = var.akamai_client_token
    client_secret = var.akamai_client_secret
  } */
  edgerc         = "~/.edgerc"
  config_section = "betajam"
}

# just use group_name to lookup our contract_id and group_id
# this will simplify our variables file as this contains contract and group id
# use "akamai property groups list" to find all your groups
data "akamai_contract" "contract" {
  group_name = var.group_name
}

locals {
  # using ION as our default product in case wrong product type has been provided as input var.
  # our failsave method just because we can. ;-)
  default_product = "prd_Fresca"

  # convert the list of maps to a map of maps with entry.hostname as key of the map
  # this map of maps will be fed into our EdgeDNS module to create the CNAME records.
  dv_records = { for entry in resource.akamai_property.aka_property.hostnames[*].cert_status[0] : entry.hostname => entry }

  cp_code_id = tonumber(trimprefix(resource.akamai_cp_code.cp_code.id, "cpc_"))

  // hostnames to add using same edgehostname in a dynamic block
  hostnames_config = [
    {
      cname_from             = var.hostname
      cname_to               = "${var.edge_hostname}.${var.domain_suffix}"
      cert_provisioning_type = "DEFAULT"
    },
    {
      cname_from             = "test-me-2.great-demo.com"
      cname_to               = "${var.edge_hostname}.${var.domain_suffix}"
      cert_provisioning_type = "DEFAULT"
    }
  ]
}


# for the demo don't create cpcode's over and over again, just reuse existing one
# if cpcode already existst it will take the existing one.
resource "akamai_cp_code" "cp_code" {
  name        = var.cpcode
  contract_id = data.akamai_contract.contract.id
  group_id    = data.akamai_contract.contract.group_id
  product_id  = lookup(var.aka_products, lower(var.product_name), local.default_product)
}

resource "akamai_property" "aka_property" {
  name        = var.hostname
  contract_id = data.akamai_contract.contract.id
  group_id    = data.akamai_contract.contract.group_id
  product_id  = resource.akamai_cp_code.cp_code.product_id

  # our secure by default example use a fixed edgehostname.
  # no need to create separate edgehostname resource when using secure by default (SBD) certs.
  dynamic "hostnames" {
    for_each = local.hostnames_config
    content {
      cname_from             = hostnames.value.cname_from
      cname_to               = hostnames.value.cname_to
      cert_provisioning_type = hostnames.value.cert_provisioning_type
    }
  }
  # our pretty static rules file. Only dynamic part is the origin name
  # we could use the akamai_template but trying standard templatefile() for a change.
  rules = templatefile("akamai_config/config.tftpl", { origin_hostname = var.origin_hostname, cp_code_id = local.cp_code_id, cp_code_name = var.cpcode })
 }

# let's activate this property on staging
# staging will always use latest version but when useing on production a version number should be provided.
resource "akamai_property_activation" "aka_staging" {
  property_id = resource.akamai_property.aka_property.id
  contact     = [var.email]
  version     = resource.akamai_property.aka_property.latest_version
  network     = "STAGING"
  note        = "Action triggered by Terraform."
  auto_acknowledge_rule_warnings = true
}


resource "akamai_property_activation" "aka_production" {
  property_id = resource.akamai_property.aka_property.id
  contact     = [var.email]
  version     = resource.akamai_property.aka_property.latest_version
  network     = "PRODUCTION"
  note        = "Action triggered by Terraform."
  auto_acknowledge_rule_warnings = true
}
