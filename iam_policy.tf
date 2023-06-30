resource "aws_iam_role_policy" "customer_policy" {
  name   = "customer_policy"
  role   = aws_iam_role.customer_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*",
        "sts:GetServiceBearerToken"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

