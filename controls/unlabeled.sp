locals {
  unlabeled_sql = <<EOT
    select
      self_link as resource,
      case
        when labels is not null then 'ok'
        else 'alarm'
      end as status,
      case
        when labels is not null then title || ' has labels.'
        else title || ' has no labels.'
      end as reason,
      __DIMENSIONS__
    from
      __TABLE_NAME__
  EOT
}

locals {
  unlabeled_sql_project  = replace(local.unlabeled_sql, "__DIMENSIONS__", "project")
  unlabeled_sql_location = replace(local.unlabeled_sql, "__DIMENSIONS__", "location, project")
}

benchmark "unlabeled" {
  title    = "Unlabeled"
  description = "Unlabeled resources are difficult to monitor and should be identified and remediated."
  children = [
    control.compute_instance_unlabeled,
    control.storage_bucket_unlabeled,
  ]
}

control "compute_instance_unlabeled" {
  title       = "Compute instances should be labeled"
  description = "Check if Compute instances have at least 1 label."
  sql         = replace(local.unlabeled_sql_location, "__TABLE_NAME__", "gcp_compute_instance")
}

control "storage_bucket_unlabeled" {
  title       = "Storage buckets should be labeled"
  description = "Check if Storage buckets have at least 1 label."
  sql         = replace(local.unlabeled_sql_location, "__TABLE_NAME__", "gcp_storage_bucket")
}
