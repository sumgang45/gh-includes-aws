resource "aws_ecr_repository" "foo" {
  name         = "appsecengineer-${random_string.suffix.result}-ecr-customer-app"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}
