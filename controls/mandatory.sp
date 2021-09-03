variable "mandatory_labels" {
  type        = list(string)
  description = "A list of mandatory labels to check for."
}

locals {
  mandatory_sql = <<EOT
    with analysis as (
      select
        self_link,
        title,
        labels ?& $1 as has_mandatory_labels,
        to_jsonb($1) - array(select jsonb_object_keys(labels)) as missing_labels,
        __DIMENSIONS__
      from
        __TABLE_NAME__
    )
    select
      self_link as resource,
      case
        when has_mandatory_labels then 'ok'
        else 'alarm'
      end as status,
      case
        when has_mandatory_labels then title || ' has all mandatory labels.'
        else title || ' is missing labels: ' || array_to_string(array(select jsonb_array_elements_text(missing_labels)), ', ') || '.'
      end as reason,
      __DIMENSIONS__
    from
      analysis
  EOT
}

locals {
  mandatory_sql_project  = replace(local.mandatory_sql, "__DIMENSIONS__", "project")
  mandatory_sql_location = replace(local.mandatory_sql, "__DIMENSIONS__", "location, project")
}

benchmark "mandatory" {
  title       = "Mandatory"
  description = "Resources should all have a standard set of labels applied for functions like resource organization, automation, cost control, and access control."
  children = [
    control.compute_instance_mandatory,
    control.storage_bucket_mandatory,
  ]
}

control "compute_instance_mandatory" {
  title       = "Compute instances should have mandatory labels"
  description = "Check if Compute instances have mandatory labels."
  sql         = replace(local.mandatory_sql_location, "__TABLE_NAME__", "gcp_compute_instance")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "storage_bucket_mandatory" {
  title       = "Storage buckets should have mandatory labels"
  description = "Check if Storage buckets have mandatory labels."
  sql         = replace(local.mandatory_sql_location, "__TABLE_NAME__", "gcp_storage_bucket")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}
