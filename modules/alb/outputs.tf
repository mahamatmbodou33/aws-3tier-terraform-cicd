output "target_group_arn_app1" {
  value = module.alb.target_groups["app1"].arn
}
output "target_group_arn_app2" {
  value = module.alb.target_groups["app2"].arn
}

# output "alb_dns_name" {
#   value = module.alb.dns_name
# }
# output "alb_zone_id" {
#   value = module.alb.zone_id
# }

output "dns_name" {
  value = module.alb.dns_name
}

output "zone_id" {
  value = module.alb.zone_id
}

output "target_groups" {
  value = module.alb.target_groups
}

output "alb_arn" {
  value = module.alb.arn
}
## These outputs are used in the monitoring module to create CloudWatch alarms based on the ALB and target group ARNs.
output "alb_arn_suffix" {
  value = module.alb.arn_suffix
}

output "target_group_arn_suffix_app1" {
  value = module.alb.target_groups["app1"].arn_suffix
}

output "target_group_arn_suffix_app2" {
  value = module.alb.target_groups["app2"].arn_suffix
}