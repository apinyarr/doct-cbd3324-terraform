output "FRONTEND_IP" {
  value = module.front_end_ec2.public_ip
}

output "BACKEND_IP" {
  value = module.back_end_ec2.private_ip
}