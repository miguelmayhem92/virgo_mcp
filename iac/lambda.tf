resource "aws_ecr_repository" "this" {
  name = "virgo-mcp"
}

# resource "aws_iam_role" "lambda" {
#   name = "my-lambda-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect    = "Allow"
#       Principal = { Service = "lambda.amazonaws.com" }
#       Action    = "sts:AssumeRole"
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "basic_execution" {
#   role       = aws_iam_role.lambda.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

# resource "aws_lambda_function" "this" {
#   function_name = "virgo-mcp"
#   role          = aws_iam_role.lambda.arn
#   package_type  = "Image"
#   image_uri     = "${aws_ecr_repository.this.repository_url}:latest"
#   timeout       = 30
#   memory_size   = 512

#   depends_on = [aws_iam_role_policy_attachment.basic_execution]
# }

# output "function_name" {
#   value = aws_lambda_function.this.function_name
# }

# output "repository_url" {
#   value = aws_ecr_repository.this.repository_url
# }