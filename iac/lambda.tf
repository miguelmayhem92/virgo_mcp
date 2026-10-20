resource "aws_ecr_repository" "this" {
  name = "virgo-mcp"
}

resource "aws_iam_role" "lambda" {
  name = "virgo-mcp-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# CloudWatch Logs only
resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Read one object from one bucket
resource "aws_iam_role_policy" "s3_read_specific_object" {
  name = "s3-read-specific-object"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "ReadSpecificObject"
      Effect   = "Allow"
      Action   = "s3:GetObject"
      Resource = "arn:aws:s3:::virgo-data/edge_models/*"
    }]
  })
}

resource "aws_lambda_function" "this" {
  function_name = "virgo-mcp"
  role          = aws_iam_role.lambda.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.this.repository_url}:virgo_mcp.latest"
  timeout       = 600
  memory_size   = 2048

  depends_on = [aws_iam_role_policy_attachment.basic_execution]
}

output "function_name" {
  value = aws_lambda_function.this.function_name
}

output "repository_url" {
  value = aws_ecr_repository.this.repository_url
}