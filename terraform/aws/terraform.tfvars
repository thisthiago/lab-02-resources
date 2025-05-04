glue_tables = {
  dev = {
    silver_delta = {
      tables = [
        "teste-glue-etl",
      ]
    },
    silver_parquet = {
      tables = [
        "teste-parquet"
      ]
    },
  }
}


vpc_cidr = {
  prod = "192.168.0.0/16"
  dev  = "10.0.0.0/20"
}

vpc_private_subnets = {
  prod = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  dev  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

vpc_public_subnets = {
  prod = ["192.168.4.0/24", "192.168.5.0/24", "192.168.6.0/24"]
  dev  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}