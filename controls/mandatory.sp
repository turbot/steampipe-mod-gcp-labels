variable "mandatory_labels" {
  type        = list(string)
  description = "A list of mandatory labels to check for."
  default     = ["Environment", "Owner"]
}

locals {
  mandatory_sql = <<-EOQ
    with analysis as (
      select
        self_link,
        title,
        labels ?& $1 as has_mandatory_labels,
        to_jsonb($1) - array(select jsonb_object_keys(labels)) as missing_labels,
        location,
        labels,
        project,
        _ctx
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
      end as reason
      ${local.tag_dimensions_sql}
      ${local.common_dimensions_sql}
    from
      analysis
  EOQ
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
  sql         = replace(local.mandatory_sql, "__TABLE_NAME__", "gcp_bigquery_dataset")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "bigquery_job_mandatory" {
  title       = "BigQuery jobs should have mandatory labels"
  description = "Check if BigQuery jobs have mandatory labels."
  sql         = replace(local.mandatory_sql, "__TABLE_NAME__", "gcp_bigquery_job")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "bigquery_table_mandatory" {
  title       = "BigQuery tables should have mandatory labels"
  description = "Check if BigQuery tables have mandatory labels."
  sql         = replace(local.mandatory_sql, "__TABLE_NAME__", "gcp_bigquery_table")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "compute_disk_mandatory" {
  title       = "Compute disks should have mandatory labels"
  description = "Check if Compute disks have mandatory labels."
  sql         = replace(local.mandatory_sql, "__TABLE_NAME__", "gcp_compute_disk")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "compute_forwarding_rule_mandatory" {
  title       = "Compute forwarding rules should have mandatory labels"
  description = "Check if Compute forwarding rules have mandatory labels."
  sql         = replace(local.mandatory_sql, "__TABLE_NAME__", "gcp_compute_forwarding_rule")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "compute_image_mandatory" {
  title       = "Compute images should have mandatory labels"
  description = "Check if Compute images have mandatory labels."
  sql         = <<-EOQ
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
  EOQ
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "compute_instance_mandatory" {
  title       = "Compute instances should have mandatory labels"
  description = "Check if Compute instances have mandatory labels."
  sql         = replace(local.mandatory_sql, "__TABLE_NAME__", "gcp_compute_instance")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "compute_snapshot_mandatory" {
  title       = "Compute snapshots should have mandatory labels"
  description = "Check if Compute snapshots have mandatory labels."
  sql         = replace(local.mandatory_sql, "__TABLE_NAME__", "gcp_compute_snapshot")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "dns_managed_zone_mandatory" {
  title       = "DNS managed zones should have mandatory labels"
  description = "Check if Dns managed zones have mandatory labels."
  sql         = replace(local.mandatory_sql, "__TABLE_NAME__", "gcp_dns_managed_zone")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "sql_database_instance_mandatory" {
  title       = "SQL database instances should have mandatory labels"
  description = "Check if SQL database instances have mandatory labels."
  sql         = replace(local.mandatory_sql, "__TABLE_NAME__", "gcp_sql_database_instance")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "storage_bucket_mandatory" {
  title       = "Storage buckets should have mandatory labels"
  description = "Check if Storage buckets have mandatory labels."
  sql         = replace(local.mandatory_sql, "__TABLE_NAME__", "gcp_storage_bucket")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "bigtable_instance_mandatory" {
  title       = "Bigtable instances should have mandatory labels"
  description = "Check if Bigtable instances have mandatory labels."
  sql         = replace(local.mandatory_sql, "__TABLE_NAME__", "gcp_bigtable_instance")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "dataproc_cluster_mandatory" {
  title       = "Dataproc clusters should have mandatory labels"
  description = "Check if Dataproc clusters have mandatory labels."
  sql         = replace(local.mandatory_sql, "__TABLE_NAME__", "gcp_dataproc_cluster")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "pubsub_subscription_mandatory" {
  title       = "Pub/Sub subscriptions should have mandatory labels"
  description = "Check if Pub/Sub subscriptions have mandatory labels."
  sql         = replace(local.mandatory_sql, "__TABLE_NAME__", "gcp_pubsub_subscription")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}

control "pubsub_topic_mandatory" {
  title       = "Pubsub topics should have mandatory labels"
  description = "Check if Pub/Sub topics have mandatory labels."
  sql         = replace(local.mandatory_sql, "__TABLE_NAME__", "gcp_pubsub_topic")
  param "mandatory_labels" {
    default = var.mandatory_labels
  }
}
