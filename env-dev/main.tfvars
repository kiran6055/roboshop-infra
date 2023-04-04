env = "dev"
default_vpc_id = "vpc-04018a37c2a1f4629"

vpc ={
  main = {
    cidr_block = "10.0.0.0/16"
  }
}

subnets ={
  public ={
    cidr_block = ["10.0.0.0/24", "10.0.1.0/24"]
    availability_zone = ["us-east-1a", "us-east-1b"]
    name = "public"
    vpc_name = "main"
    internet_gw = true

  }
  web ={
    cidr_block         = ["10.0.2.0/24", "10.0.3.0/24"]
    availability_zone  = ["us-east-1a", "us-east-1b"]
    name               = "web"
    vpc_name           = "main"
    nat_gw = true

  }
  db = {
    cidr_block         = ["10.0.4.0/24", "10.0.5.0/24"]
    availability_zone  = ["us-east-1a", "us-east-1b"]
    name               = "db"
    vpc_name           = "main"
    nat_gw = true
  }
  app = {
    cidr_block         = ["10.0.6.0/24", "10.0.7.0/24"]
    availability_zone  = ["us-east-1a", "us-east-1b"]
    name               = "app"
    vpc_name           = "main"
    nat_gw = true
  }


}