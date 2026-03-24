# Create an S3 bucket
resource "aws_s3_bucket" "demo_bucket" {
  bucket = var.bucket_name
}

# Enable versioning for the bucket
resource "aws_s3_bucket_versioning" "demo_bucket_versioning" {
  bucket = aws_s3_bucket.demo_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Upload a file to the bucket
resource "aws_s3_object" "demo_object" {
  bucket = aws_s3_bucket.demo_bucket.id
  key    = "hello-world.txt"
  source = "./test-file.txt"
  etag   = filemd5("./test-file.txt")
}

resource "aws_s3_bucket_public_access_block" "allow_public" {
  bucket = aws_s3_bucket.demo_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.demo_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.allow_public]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.demo_bucket.arn}/*"
      },
    ]
  })
}

output "s3_public_url" {
  value = "https://${aws_s3_bucket.demo_bucket.bucket}.s3.amazonaws.com/hello-world.txt"
}