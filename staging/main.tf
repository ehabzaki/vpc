module "staging" {
    source  = "../modules/vpc"
    environment= "staging"
    availability_zones = ["a","b"]
}
