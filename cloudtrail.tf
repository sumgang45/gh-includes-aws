resource "aws_cloudtrail" "foobar" {
  name                          = "github-aws-include-attack-${random_string.random.result}-trail"
  s3_bucket_name                = aws_s3_bucket.foo.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = true
  enable_log_file_validation    = true
  depends_on = [
    aws_s3_bucket_policy.trailpolicyfors3
  ]
  cloud_watch_logs_role_arn  = aws_iam_role.trail_role.arn
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.example.arn}:*"
}

resource "aws_s3_bucket" "foo" {
  bucket        = "github-aws-include-attack-${random_string.random.result}"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "foo" {
  bucket = aws_s3_bucket.foo.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "ssrf" {
  bucket     = aws_s3_bucket.foo.id
  acl        = "private"
  depends_on = [aws_s3_bucket.foo, aws_s3_bucket_ownership_controls.foo]
}


resource "aws_s3_bucket_policy" "trailpolicyfors3" {
  depends_on = [
    aws_s3_bucket.foo
  ]
  bucket = aws_s3_bucket.foo.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::github-aws-include-attack-${random_string.random.result}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            
            "Resource": "arn:aws:s3:::github-aws-include-attack-${random_string.random.result}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}


data "aws_caller_identity" "current" {}

resource "aws_iam_role" "trail_role" {
  name = "CW_role-${random_string.random.result}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "lambda-basic-exec-role" {
  role       = aws_iam_role.trail_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
