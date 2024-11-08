# map of akamai products, just to make life easy
variable "aka_products" {
  description = "map of akamai products"
  type        = map(string)

  default = {
    "ion" = "prd_Fresca"
    "dsa" = "prd_Site_Accel"
    "dd"  = "prd_Download_Delivery"
  }
}

variable "cpcode" {
  description = "Your unique Akamai CPcode name to be used with your property"
  type        = string
}

# akamai product to use
variable "product_name" {
  description = "The Akamai delivery product name"
  type        = string
  default     = "ion"
}

# IPV4, IPV6_PERFORMANCE or IPV6_COMPLIANCE
variable "ip_behavior" {
  description = "use IPV4 to only use IPv4"
  type        = string
  default     = "IPV6_COMPLIANCE"
}

# FreeFlow=edgesuite.net, ESSL=egekey.net
variable "domain_suffix" {
  description = "edgehostname suffix"
  type        = string
  default     = "edgesuite.net"
}

variable "group_name" {
  description = "Akamai group to use this resource in"
  type        = string
}

variable "email" {
  description = "Email address of users to inform when property gets created"
  type        = string
}

variable "hostname" {
  description = "Name of the hostname but also user for property and edgehostname"
  type        = string
}

variable "origin_hostname" {
  description = "The origin hostname"
  type        = string
  default = "my-origin.customer.com"
}

variable "edge_hostname" {
  description = "The origin hostname"
  type        = string
  default = "test-static.great-demo.com"
}