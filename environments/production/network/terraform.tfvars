project        = "datasaur"
env            = "production"
region         = "ap-southeast-1"
cidr_block     = "10.2.0.0/16"
public_subnets = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
azs            = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
vpn_cidr_block = ["1.2.3.4/32"] #CHANGETHIS