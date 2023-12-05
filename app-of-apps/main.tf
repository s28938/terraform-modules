# Public Git repository
resource "argocd_repository" "deployment_repository" {
  repo    = var.app_of_apps.repo_url
  project = var.argocd_project
}


resource "argocd_application" "app_of_apps" {
  metadata {
    name      = "applications"
    namespace = var.application_namespace
    labels    = var.labels
  }
  wait = true
  timeouts {
    create = "20m"
    delete = "10m"
  }
  spec {
    project = var.argocd_project
    source {
      repo_url        = var.app_of_apps.repo_url
      path            = var.app_of_apps.path
      target_revision = var.app_of_apps.target_revision
    }

    destination {
      server    = var.destination_server
      namespace = var.destination_namespace
    }

    sync_policy {
      automated {
        prune       = true
        self_heal   = true
        allow_empty = true
      }

      sync_options = ["Validate=false", "createCustomResource=false"]
      retry {
        limit = "5"
        backoff {
          duration     = "30s"
          max_duration = "2m"
          factor       = "2"
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [metadata]
  }

  depends_on = [argocd_repository.deployment_repository]
}