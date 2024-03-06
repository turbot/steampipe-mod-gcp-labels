// Benchmarks and controls for specific services should override the "service" tag
locals {
  gcp_labels_common_tags = {
    category = "Tagging"
    plugin   = "gcp"
    service  = "GCP"
  }
}