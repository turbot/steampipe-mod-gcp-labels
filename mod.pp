mod "gcp_labels" {
  # Hub metadata
  title         = "GCP Labels"
  description   = "Run label controls across all your GCP projects using Powerpipe and Steampipe."
  color         = "#EA4335"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/gcp-labels.svg"
  categories    = ["gcp", "tags", "public cloud"]

  opengraph {
    title       = "Powerpipe Mod for GCP Labels"
    description = "Run label controls across all your GCP projects using Powerpipe and Steampipe."
    image       = "/images/mods/turbot/gcp-labels-social-graphic.png"
  }

  require {
    plugin "gcp" {
      min_version = "0.27.0"
    }
  }
}
