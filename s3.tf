resource "aws_s3_bucket" "test_bucket" {
  bucket = "some.random.bucket.656565"

  tags = {
    Name = "s3 test bucket"
  }
}