resource "aws_s3_bucket" "gpi_cat_loadbalancerlogs" {
    bucket = "gpi-cat-loadbalancerlog"
}

resource "aws_s3_bucket_policy" "gpi_cat_loadbalancerlogs_policy" {
    bucket = aws_s3_bucket.gpi_cat_loadbalancerlogs.id

    policy = jsonencode({
            Version = "2012-10-17"
            Statement = [
            {
                Effect = "Allow"
                Principal = {
                    AWS = data.aws_elb_service_account.main.arn # Or "Service": "elb.amazonaws.com" for newer regions
                }
                Action = "s3:PutObject"
                Resource = "${aws_s3_bucket.gpi_cat_loadbalancerlogs.arn}/*"
            }
            ]
        })
}

