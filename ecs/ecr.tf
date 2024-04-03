resource "aws_ecr_repository" "vacgom-ecr" {
  name = "vacgom-ecr"
  image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecr_lifecycle_policy" "vacgom-ecr-policy" {
  depends_on = [aws_ecr_repository.vacgom-ecr]
  repository = aws_ecr_repository.vacgom-ecr.name

  policy = <<-EOT
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep latest",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": [
            "latest"
          ],
          "countType": "imageCountMoreThan",
          "countNumber": 1
        },
        "action": {
          "type": "expire"
        }
      },
      {
        "rulePriority": 2,
        "description": "keep last 3 images",
        "selection": {
          "tagStatus": "any",
          "countType": "imageCountMoreThan",
          "countNumber": 3
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
  EOT
}
