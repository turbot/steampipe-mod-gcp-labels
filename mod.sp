// Benchmarks and controls for specific services should override the "service" tag
locals {
  gcp_labels_common_tags = {
    category = "Tagging"
    plugin   = "gcp"
    service  = "GCP"
  }
}

mod "gcp_labels" {
  # hub metadata
  title         = "GCP Labels"
  description   = "Run label controls across all your GCP projects using Steampipe."
  color         = "#EA4335"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/gcp-labels.svg"
  categories    = ["gcp", "tags", "public cloud"]

  opengraph {
    title       = "Steampipe Mod for GCP Labels"
    description = "Run label controls across all your GCP projects using Steampipe."
    image       = "/images/mods/turbot/gcp-labels-social-graphic.png"
  }

  require {
    plugin "gcp" {
      version = "0.27.0"
    }
  }
}
