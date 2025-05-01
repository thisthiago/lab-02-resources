data "archive_file" "lambda_zip_servidores" {
  type        = "zip"
  source_file = "${local.lambda_function_root_path}fetch_servidores_senado.py"
  output_path = "${path.root}/zip/fetch_servidores_senado.zip"
}


resource "aws_lambda_function" "fetch_servidores" {
  function_name    = "fetch-senado-servidores"
  timeout          = 30
  role             = aws_iam_role.lambda_role.arn
  handler          = "fetch_servidores_senado.lambda_handler" #Alterar
  runtime          = "python3.10"
  filename         = data.archive_file.lambda_zip_servidores.output_path
  source_code_hash = data.archive_file.lambda_zip_servidores.output_base64sha256

}

# Trigger agendado (opcional - descomente se precisar)
# resource "aws_cloudwatch_event_rule" "daily_trigger" {
#   name                = "trigger-${var.lambda_function_name}"
#   schedule_expression = "rate(1 day)"
# }

# resource "aws_lambda_permission" "allow_cloudwatch" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.fetch_servidores.function_name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
# }