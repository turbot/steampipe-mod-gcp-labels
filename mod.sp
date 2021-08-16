mod "gcp_tags" {
  # hub metadata
  title         = "GCP Tags"
  description   = "Run tagging controls across all your GCP projects using Steampipe."
  color         = "#FF9900"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/gcp-tags.svg"
  categories    = ["gcp", "tags", "public cloud"]

  opengraph {
    title        = "Steampipe Mod for GCP Tags"
    description  = "Run tagging controls across all your GCP projects using Steampipe."
    image        = "/images/mods/turbot/gcp-tags-social-graphic.png"
  }
}