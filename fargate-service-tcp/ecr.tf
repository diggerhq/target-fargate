/*
 * ecr.tf
 * Creates a Amazon Elastic Container Registry (ECR) for the application
 * https://aws.amazon.com/ecr/
 */

# create an ECR repo at the app/image level
resource "aws_ecr_repository" "app" {
  name                 = "${var.ecs_cluster.name}-${var.service_name}"
  image_tag_mutability = var.image_tag_mutability
  force_delete         = true
}

output "docker_registry" {
  value = aws_ecr_repository.app.repository_url
}

