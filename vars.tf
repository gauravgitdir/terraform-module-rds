variable "allocated_storage" {
type = number
}


variable "subnet_prefix" {
type = string
}

variable "vpc_name" {
type = string
}

variable "db_security_group_name" {
type = string
}


variable "account_id" {
type = number
}


variable "engine" {
type = string
}

variable "engine_version" {
type = string
}

variable "instance_class" {
type = string
}

variable "name" {
type = string
}

variable "username" {
type = string
}

variable "password" {
type = string
}

variable "parameter_group_name" {
type = number
}

variable "db_instance_parameter_grp_name_instance" {
type = string
}

variable "db_instance_parameter_grp_name_cluster" {
type = string
}

variable "db_family" {
type = string
}

variable "component" {
type = string
}

variable "secret_key" {
type = string
}

variable "db_name" {
type = string
}

variable "db_engine" {
type = string
}

variable "db_engine_version" {
type = number
}

variable "db_engine_mode" {
type = string
}


variable "db_admin_username" {
type = string
}

variable "db_port" {
type = number
}

variable "instance_class" {
type = string
}

variable "publicly_accessible" {
type = bool
}

variable "auto_minor_version_upgrade" {
type = bool
}

variable "db_preferred_maintenance_window_instances" {
type =  string
}




