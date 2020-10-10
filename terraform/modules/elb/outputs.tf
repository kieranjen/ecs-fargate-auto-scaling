output "elb" {
  value = aws_lb.elb
}

output "ecs_target_group" {
  value = aws_lb_target_group.ecs
}
