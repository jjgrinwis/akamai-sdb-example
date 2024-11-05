# group to create resources in
group_name = "Ion Standard Beta Jam 1-3-16TWBVX"

# what user to inform when hostname has been created
email = "nobody@akamai.com"

# let's use ESSL network
domain_suffix = "edgekey.net"

# property name
hostname = "sorin.great-demo.com"

# this is an exising cpcode name connected to the right product (ion)
# you can find cpcodes via akamai pm lcp -g grp_id -c ctr_id
cpcode = "jgrinwis"

# our security configuration
security_configuration = "WAF Security File"

# security policy to attach this property to. Security policy should be part of security config var.security_configuration
security_policy = "Monitoring Only Security Policy"