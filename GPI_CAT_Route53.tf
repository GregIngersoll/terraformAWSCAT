data "aws_route53_zone" "mahony_ingersoll" {
    name = "mahony-ingersoll.com."
}

data "aws_route53_records" "mahony_ingersoll_route53_records" {
    zone_id = data.aws_route53_zone.mahony_ingersoll.zone_id
}

# resource "aws_route53_record" "mahony_ingersoll_alb" {
#     zone_id = data.aws_route53_zone.mahony_ingersoll.id
#     name = ""
#     type = "A"
#     alias {
#         name = aws_lb.GPI_CAT_LoadBalancer.dns_name
#         zone_id = aws_lb.GPI_CAT_LoadBalancer.zone_id
#         evaluate_target_health = true
#     }
# }