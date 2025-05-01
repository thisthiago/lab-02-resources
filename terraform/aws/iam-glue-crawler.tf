data "aws_iam_policy_document" "glue_crawler_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "glue_crawler_role" {
  name               = "${terraform.workspace}-glue-crawler-role"
  description        = "Role used by Glue Crawlers"
  assume_role_policy = data.aws_iam_policy_document.glue_crawler_assume_role_policy.json
}

resource "aws_iam_policy" "glue_crawler_policy" {
  name        = "${terraform.workspace}-glue-crawler-policy"
  description = "Provides write permissions to Glue Crawler"
  policy      = file("policies/iam-policy-glue-crawler.json")
}

resource "aws_iam_policy_attachment" "glue_crawler_attachment" {
  name       = "${terraform.workspace}-glue-crawler-attachment"
  roles      = [aws_iam_role.glue_crawler_role.name]
  policy_arn = aws_iam_policy.glue_crawler_policy.arn
}

output "glue_crawler_role_arn" {
  value = aws_iam_role.glue_crawler_role.arn
}