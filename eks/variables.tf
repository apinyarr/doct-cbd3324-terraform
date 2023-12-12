variable "region" {
    description = "aws region"
    type = string
    default = "ca-central-1"
}

variable "activate_nat_gateway" {
    description = "to enable or disable net gateway"
    type = bool
    default = true
}