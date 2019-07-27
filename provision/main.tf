data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_iam_role" "LambdaAlexaCloudControlEc2StateActionIamRole" {
  name        = "LambdaAlexaCloudControlEc2StateActionIamRole"
  path        = "/"
  description = "IAM role for Lambda function, created by terraform"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Project = "Alexa Cloud Control"
    Name = "LambdaAlexaCloudControlEc2StateActionIamRole"
    Env = "${var.environment}"
    Purpose = "IAM role for Lambda"
  }
}

resource "aws_iam_policy" "LambdaAlexaCloudControlEc2StateActionIamPolicy" {
  name = "LambdaAlexaCloudControlEc2StateActionIamPolicy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "IamRolePolicyAttachement" {
  role       = "${aws_iam_role.LambdaAlexaCloudControlEc2StateActionIamRole.name}"
  policy_arn = "${aws_iam_policy.LambdaAlexaCloudControlEc2StateActionIamPolicy.arn}"
}

resource "aws_cloudwatch_log_group" "AlexaCloudControlEc2StateActionLogGroup" {
  name              = "/aws/lambda/AlexaCloudControlEc2StateAction"
  retention_in_days = 3

  tags = {
    Project = "Alexa Cloud Control"
    Name    = "AlexaCloudControlEc2StateAction"
    Env     = "${var.environment}"
    Purpose = "Cloudwatch logs group"
  }
}

# resource "aws_lambda_function" "AlexaCloudControlEc2StateAction" {
#   function_name    = "cloud_control_state_action_ec2"
#   role             = "${aws_iam_role.LambdaAlexaCloudControlEc2StateActionIamRole.arn}"
#   description      = " Alexa EC2 - change state of EC2"
#   s3_bucket        = "${var.artifacts_bucket_name}"
#   s3_key           = "cloud_control_state_action_ec2.zip"
#   handler          = "cloud_control_state_action_ec2.cloud_control_state_action_ec2"
#   runtime          = "python3.6"
#   memory_size      = 128
#   timeout          = 3

#   tags = {
#     Project = "Alexa Cloud Control"
#     Name    = "AlexaCloudControlEc2StateAction"
#     Env     = "${var.environment}"
#     Purpose = "Lambda function"
#   }

# }