project        = "datasaur"
env            = "staging"
region         = "ap-southeast-1"
cidr_block     = "10.1.0.0/16"
public_subnets = ["10.1.1.0/24", "10.1.96.0/24", "10.1.160.0/24"]
azs            = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
vpn_cidr_block = ["1.2.3.4/32"]