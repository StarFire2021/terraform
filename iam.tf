resource "aws_iam_user" "test_user" {
  name = "test_user"
  path = "/system/"

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_access_key" "test_user" {
  user = "${aws_iam_user.test_user.name}"
}

resource "aws_iam_user_policy" "general_user" {
  name = "test"
  user = "${aws_iam_user.test_user.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "ec2:*",
                "s3:ListBucket"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

