resource "aws_ecr_repository" "this" {
  // toset() converts the list into a set so Terraform can loop through it.
  for_each = toset(var.repo_names)

  name = each.value
  // This decides if we can replace a tag later.

  # MUTABLE → you can push new builds with the same tag (good for dev).

  # IMMUTABLE → you cannot override an existing tag (good for production safety).
  image_tag_mutability = var.image_tag_mutability

  force_delete = true # allows destroy even when images exist


  // It checks for known vulnerabilities in images pushed to the repository
  image_scanning_configuration {
    scan_on_push = var.image_scan
  }

  // The encryption configuration for the repository
  // AES256
  // Safe at rest 
  encryption_configuration {
    encryption_type = var.encryption_type
  }

  tags = var.tags
}

// Keep the latest 10 tagged images.
// Delete untagged images older than 7 days.
resource "aws_ecr_lifecycle_policy" "this" {
  // Loop through each repository and attach one lifecycle policy per repository.
  for_each   = aws_ecr_repository.this
  repository = each.value.name

  policy = var.lifecycle_policy
}
