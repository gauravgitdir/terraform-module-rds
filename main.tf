data "aws_caller_identity" "current" {}

data "aws_security_group" "postgresqlexample-sg" {
  id = var.db_security_group_name
}

# Existing VPC we will be using
data "aws_vpc" "vpc" {
  tags =  {
    Name = var.vpc_name
  }
}
# Existing Subnet ids we will be using to setup aurora rds PostgreSQL qinstance
data "aws_subnet_ids" "examplepostgresql_private_subnets" {
  tags = {
    Name = var.subnet_prefix
  }

  vpc_id = data.aws_vpc.vpc.id
}

# Database subnet group
#------------------------------------------------------------------------------------------------------
resource "aws_db_subnet_group" "examplepostgresql-subnet-group" {
  name                            = var.db_subnet_group_name
  subnet_ids                      = data.aws_subnet_ids.examplepostgresql_private_subnets.ids
  description                     = "Subnet group for Amazon Aurora PostgreSQL AEA DB"

  tags = {
      Name = var.db_subnet_group_name
      component = var.component
    }
}
# Database parameter group: The set of parameters that requires to put for db instance while launching
#------------------------------------------------------------------------------------------------------
resource "aws_rds_cluster_parameter_group" "examplepostgresql-cluster-param-grp" {
  name                          = var.db_instance_parameter_grp_name_cluster
  family                        = var.db_family
  description                   = "Parameter group for Amazon Aurora Postgres DB"
  parameter {
    name = "rds.force_ssl"
    value = "1"
  }

  tags = {
      Name = var.db_instance_parameter_grp_name_instance
      component = var.component
    }
}

resource "aws_db_parameter_group" "examplepostgresql-instance-param-grp" {
  name                          = var.db_instance_parameter_grp_name_instance
  family                        = var.db_family
  description                   = "Parameter group for Amazon Aurora Postgres DB"
  parameter {
    name = "log_connections"
    value = "1"
  }
  parameter {
    name = "log_disconnections"
    value = "1"
  }
  parameter {
    name = "log_statement"
    value = "none"
  }
  parameter {
    name = "log_duration"
    value = "0"
  }
  parameter {
    name = "log_min_duration_statement"
    value = "10"
  }
  parameter {
    name = "log_hostname"
    value = "0"
  }

  tags = {
    Name = var.db_instance_parameter_grp_name_instance
    component = var.component
  }
}

resource "random_password" "rds_password" {
  length = 16
  special = false
}

resource "aws_secretsmanager_secret" "examplerdssecret" {
  name = var.secret_key

  tags = {
    Name = "AEA-Secret-key"
    component = var.component
  }
}

resource "aws_secretsmanager_secret_version" "secretValue" {
  secret_id     = aws_secretsmanager_secret.examplerdssecret.id
  secret_string = random_password.rds_password.result
}


resource "aws_kms_key" "exampleauthoringwebKMSKey" {
  description             = "A KMS key to encrypt the Aurora postgres database"
  policy                  = data.template_file.kms_policy.rendered
  tags = {
    Name = "AEA-KMS-Key"
    component = var.component
  }
}

resource "aws_kms_alias" "exampleauthoringwebKMSKeyAlias" {
  target_key_id = aws_kms_key.exampleauthoringwebKMSKey.key_id
}


resource "aws_rds_cluster" "example-postgresql-cluster" {
  cluster_identifier              = "${var.db_cluster_instance_name}-cluster"
  database_name                   = var.db_name
  engine                          = var.db_engine
  engine_version                  = var.db_engine_version
  engine_mode                     = var.db_engine_mode
  master_username                 = var.db_admin_username
  master_password                 = aws_secretsmanager_secret_version.secretValue.secret_string
  port                            = var.db_port
  vpc_security_group_ids          = [data.aws_security_group.postgresqlexample-sg.id]
  db_subnet_group_name            = aws_db_subnet_group.examplepostgresql-subnet-group.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.examplepostgresql-cluster-param-grp.name
  deletion_protection             = false
  apply_immediately               = true
  kms_key_id                      = aws_kms_key.exampleauthoringwebKMSKey.arn
  storage_encrypted               = true

tags = {
      Name = var.db_cluster_instance_name
      component = var.component
    }

}




resource "aws_rds_cluster_instance" "cluster_instances" {
count = local.instance_count
  identifier         = "${var.db_cluster_instance_name}-${var.cluster_instance_identifier}-${count.index}"
  cluster_identifier = aws_rds_cluster.example-postgresql-cluster.cluster_identifier
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.example-postgresql-cluster.engine
  engine_version     = aws_rds_cluster.example-postgresql-cluster.engine_version
  publicly_accessible = var.publicly_accessible
  db_parameter_group_name = aws_db_parameter_group.examplepostgresql-instance-param-grp.name
  db_subnet_group_name = aws_db_subnet_group.examplepostgresql-subnet-group.name
  performance_insights_enabled = true
  performance_insights_kms_key_id = aws_kms_key.exampleauthoringwebKMSKey.arn
   tags = {
    Name = "${var.db_cluster_instance_name}-${var.db_name}"
    component = var.component
  }

}

