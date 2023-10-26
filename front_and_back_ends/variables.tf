variable "region" {
    description = "aws region"
    type = string
    default = "ca-central-1"
}

variable "create_front_end_server" {
    description = "to enable or disable front end server"
    type = bool
    default = true
}

variable "create_back_end_server" {
    description = "to enable or disable back end server"
    type = bool
    default = true
}

variable "activate_nat_gateway" {
    description = "to enable or disable net gateway"
    type = bool
    default = true
}

# variable "ops_pre_peering" {
#     description = "vpc peering between ops and pre"
#     type = string
#     default = "pcx-06d415c4776e50a9c"
# }