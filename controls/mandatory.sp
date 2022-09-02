variable "mandatory_labels" {
  type        = list(string)
  description = "A list of mandatory labels to check for."
  default     = ["Environment", "Owner"]
}

locals {
  mandatory_sql = <<-EOT
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
    control.bigquery_dataset_mandatory,
    control.bigquery_job_mandatory,
    control.bigquery_table_mandatory,
    control.bigtable_instance_mandatory,
    control.compute_disk_mandatory,
    control.compute_forwarding_rule_mandatory,
    control.compute_image_mandatory,
    control.compute_instance_mandatory,
    control.compute_snapshot_mandatory,
    control.dataproc_cluster_mandatory,
    control.dataproc_job_mandatory,
    control.dns_managed_zone_mandatory,
    control.pubsub_subscription_mandatory,
    control.pubsub_topic_mandatory,
    control.sql_database_instance_mandatory,
    control.storage_bucket_mandatory
  ]

  tags = merge(local.gcp_labels_common_tags, {
    type = "Benchmark"
  })
}

control "bigquery_dataset_mandatory" {
  title       = "BigQuery datasets should have mandatory labels"
  description = "Check if BigQuery datasets have mandatory labels."
  sql         = replace(local.mandatory_sql_location, "__TABLE_NAME__", "gcp_bigquery_dataset")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "bigquery_job_mandatory" {
  title       = "BigQuery jobs should have mandatory labels"
  description = "Check if BigQuery jobs have mandatory labels."
  sql         = replace(local.mandatory_sql_location, "__TABLE_NAME__", "gcp_bigquery_job")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "bigquery_table_mandatory" {
  title       = "BigQuery tables should have mandatory labels"
  description = "Check if BigQuery tables have mandatory labels."
  sql         = replace(local.mandatory_sql_location, "__TABLE_NAME__", "gcp_bigquery_table")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "compute_disk_mandatory" {
  title       = "Compute disks should have mandatory labels"
  description = "Check if Compute disks have mandatory labels."
  sql         = replace(local.mandatory_sql_location, "__TABLE_NAME__", "gcp_compute_disk")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "compute_forwarding_rule_mandatory" {
  title       = "Compute forwarding rules should have mandatory labels"
  description = "Check if Compute forwarding rules have mandatory labels."
  sql         = replace(local.mandatory_sql_location, "__TABLE_NAME__", "gcp_compute_forwarding_rule")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "compute_image_mandatory" {
  title       = "Compute images should have mandatory labels"
  description = "Check if Compute images have mandatory labels."
  sql         = <<EOT
    with analysis as (
      select
        self_link,
        title,
        labels ?& $1 as has_mandatory_labels,
        to_jsonb($1) - array(select jsonb_object_keys(labels)) as missing_labels,
        location,
        project
      from
        gcp_compute_image
      where
        source_project = project
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
      location,
      project
    from
      analysis
  EOT
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "compute_instance_mandatory" {
  title       = "Compute instances should have mandatory labels"
  description = "Check if Compute instances have mandatory labels."
  sql         = replace(local.mandatory_sql_location, "__TABLE_NAME__", "gcp_compute_instance")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "compute_snapshot_mandatory" {
  title       = "Compute snapshots should have mandatory labels"
  description = "Check if Compute snapshots have mandatory labels."
  sql         = replace(local.mandatory_sql_location, "__TABLE_NAME__", "gcp_compute_snapshot")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "dns_managed_zone_mandatory" {
  title       = "DNS managed zones should have mandatory labels"
  description = "Check if Dns managed zones have mandatory labels."
  sql         = replace(local.mandatory_sql_location, "__TABLE_NAME__", "gcp_dns_managed_zone")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "sql_database_instance_mandatory" {
  title       = "SQL database instances should have mandatory labels"
  description = "Check if Sql database instances have mandatory labels."
  sql         = replace(local.mandatory_sql_location, "__TABLE_NAME__", "gcp_sql_database_instance")
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

control "bigtable_instance_mandatory" {
  title       = "Bigtable instances should have mandatory labels"
  description = "Check if Storage bigtable instances have mandatory labels."
  sql         = replace(local.mandatory_sql_location, "__TABLE_NAME__", "gcp_bigtable_instance")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "dataproc_cluster_mandatory" {
  title       = "Dataproc clusters should have mandatory labels"
  description = "Check if dataproc clusters have mandatory labels."
  sql         = replace(local.mandatory_sql_location, "__TABLE_NAME__", "gcp_dataproc_cluster")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "dataproc_job_mandatory" {
  title       = "Dataproc jobs should have mandatory labels"
  description = "Check if dataproc jobs have mandatory labels."
  sql         = replace(local.mandatory_sql_location, "__TABLE_NAME__", "gcp_dataproc_job")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "pubsub_subscription_mandatory" {
  title       = "Pubsub subscriptions should have mandatory labels"
  description = "Check if pubsub subscriptions have mandatory labels."
  sql         = replace(local.mandatory_sql_location, "__TABLE_NAME__", "gcp_pubsub_subscription")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "pubsub_topic_mandatory" {
  title       = "Pubsub topics should have mandatory labels"
  description = "Check if pubsub topics have mandatory labels."
  sql         = replace(local.mandatory_sql_location, "__TABLE_NAME__", "gcp_pubsub_topic")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}
