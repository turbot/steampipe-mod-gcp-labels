variable "label_limit" {
  type        = number
  description = "Number of labels allowed on a resource. GCP allows up to 64 labels per resource."
}

locals {
  limit_sql = <<EOT
    with analysis as (
      select
        self_link,
        title,
        cardinality(array(select jsonb_object_keys(labels))) as num_label_keys,
        __DIMENSIONS__
      from
        __TABLE_NAME__
    )
    select
      self_link as resource,
      case
        when num_label_keys > $1::integer then 'alarm'
        else 'ok'
      end as status,
      title || ' has ' || num_label_keys || ' label(s).' as reason,
      __DIMENSIONS__
    from
      analysis
  EOT
}

locals {
  limit_sql_project  = replace(local.limit_sql, "__DIMENSIONS__", "project")
  limit_sql_location = replace(local.limit_sql, "__DIMENSIONS__", "location, project")
}

benchmark "limit" {
  title       = "Limit"
  description = "The number of labels on each resource should be monitored to avoid hitting the limit unexpectedly."
  children = [
    control.compute_instance_label_limit,
    control.storage_bucket_label_limit
  ]
}

control "compute_instance_label_limit" {
  title       = "Compute instances should not exceed label limit"
  description = "Check if the number of labels on Compute instances do not exceed the limit."
  sql         = replace(local.limit_sql_location, "__TABLE_NAME__", "gcp_compute_instance")
  param "label_limit" {
    default = var.label_limit
  }
}

control "storage_bucket_label_limit" {
  title       = "Storage buckets should not exceed label limit"
  description = "Check if the number of labels on Storage buckets do not exceed the limit."
  sql         = replace(local.limit_sql_location, "__TABLE_NAME__", "gcp_storage_bucket")
  param "label_limit" {
    default = var.label_limit
  }
}
