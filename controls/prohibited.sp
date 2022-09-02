variable "prohibited_labels" {
  type        = list(string)
  description = "A list of prohibited labels to check for."
  default     = ["Password", "Key"]
}

locals {
  prohibited_sql = <<-EOT
    with analysis as (
      select
        self_link,
        array_agg(k) as prohibited_labels
      from
        __TABLE_NAME__,
        jsonb_object_keys(labels) as k,
        unnest($1::text[]) as prohibited_key
      where
        k = prohibited_key
      group by
        self_link
    )
    select
      r.self_link as resource,
      case
        when a.prohibited_labels <> array[]::text[] then 'alarm'
        else 'ok'
      end as status,
      case
        when a.prohibited_labels <> array[]::text[] then r.title || ' has prohibited labels: ' || array_to_string(a.prohibited_labels, ', ') || '.'
        else r.title || ' has no prohibited labels.'
      end as reason,
      __DIMENSIONS__
    from
      __TABLE_NAME__ as r
    full outer join
      analysis as a on a.self_link = r.self_link
  EOT
}

locals {
  prohibited_sql_project  = replace(local.prohibited_sql, "__DIMENSIONS__", "r.project")
  prohibited_sql_location = replace(local.prohibited_sql, "__DIMENSIONS__", "r.location, r.project")
}

benchmark "prohibited" {
  title       = "Prohibited"
  description = "Prohibited labels may contain sensitive, confidential, or otherwise unwanted data and should be removed."
  children = [
    control.bigquery_dataset_prohibited,
    control.bigquery_job_prohibited,
    control.bigquery_table_prohibited,
    control.compute_disk_prohibited,
    control.compute_forwarding_rule_prohibited,
    control.compute_image_prohibited,
    control.compute_instance_prohibited,
    control.compute_snapshot_prohibited,
    control.dns_managed_zone_prohibited,
    control.sql_database_instance_prohibited,
    control.storage_bucket_prohibited,
    control.bigtable_instance_prohibited,
    control.dataproc_cluster_prohibited,
    control.dataproc_job_prohibited,
    control.pubsub_subscription_prohibited,
    control.pubsub_topic_prohibited
  ]

  tags = merge(local.gcp_labels_common_tags, {
    type = "Benchmark"
  })
}

control "bigquery_dataset_prohibited" {
  title       = "BigQuery datasets should not have prohibited labels"
  description = "Check if BigQuery datasets have any prohibited labels."
  sql         = replace(local.prohibited_sql_location, "__TABLE_NAME__", "gcp_bigquery_dataset")
  param "prohibited_labels" {
    default = var.prohibited_labels
  }
}

control "bigquery_job_prohibited" {
  title       = "BigQuery jobs should not have prohibited labels"
  description = "Check if BigQuery jobs have any prohibited labels."
  sql         = replace(local.prohibited_sql_location, "__TABLE_NAME__", "gcp_bigquery_job")
  param "prohibited_labels" {
    default = var.prohibited_labels
  }
}

control "bigquery_table_prohibited" {
  title       = "BigQuery tables should not have prohibited labels"
  description = "Check if BigQuery tables have any prohibited labels."
  sql         = replace(local.prohibited_sql_location, "__TABLE_NAME__", "gcp_bigquery_table")
  param "prohibited_labels" {
    default = var.prohibited_labels
  }
}

control "compute_disk_prohibited" {
  title       = "Compute disks should not have prohibited labels"
  description = "Check if Compute disks have any prohibited labels."
  sql         = replace(local.prohibited_sql_location, "__TABLE_NAME__", "gcp_compute_disk")
  param "prohibited_labels" {
    default = var.prohibited_labels
  }
}

control "compute_forwarding_rule_prohibited" {
  title       = "Compute forwarding rules should not have prohibited labels"
  description = "Check if Compute forwarding rules have any prohibited labels."
  sql         = replace(local.prohibited_sql_location, "__TABLE_NAME__", "gcp_compute_forwarding_rule")
  param "prohibited_labels" {
    default = var.prohibited_labels
  }
}

control "compute_image_prohibited" {
  title       = "Compute images should not have prohibited labels"
  description = "Check if Compute images have any prohibited labels."
  sql         = <<-EOT
    with analysis as (
      select
        self_link,
        array_agg(k) as prohibited_labels
      from
        gcp_compute_image,
        jsonb_object_keys(labels) as k,
        unnest($1::text[]) as prohibited_key
      where
        k = prohibited_key
        and source_project = project
      group by
        self_link
    )
    select
      r.self_link as resource,
      case
        when a.prohibited_labels <> array[]::text[] then 'alarm'
        else 'ok'
      end as status,
      case
        when a.prohibited_labels <> array[]::text[] then r.title || ' has prohibited labels: ' || array_to_string(a.prohibited_labels, ', ') || '.'
        else r.title || ' has no prohibited labels.'
      end as reason,
      location,
      project
    from
      gcp_compute_image as r
    full outer join
      analysis as a on a.self_link = r.self_link
    where source_project = project
  EOT
  param "prohibited_labels" {
    default = var.prohibited_labels
  }
}

control "compute_instance_prohibited" {
  title       = "Compute instances should not have prohibited labels"
  description = "Check if Compute instances have any prohibited labels."
  sql         = replace(local.prohibited_sql_location, "__TABLE_NAME__", "gcp_compute_instance")
  param "prohibited_labels" {
    default = var.prohibited_labels
  }
}

control "compute_snapshot_prohibited" {
  title       = "Compute snapshots should not have prohibited labels"
  description = "Check if Compute snapshots have any prohibited labels."
  sql         = replace(local.prohibited_sql_location, "__TABLE_NAME__", "gcp_compute_snapshot")
  param "prohibited_labels" {
    default = var.prohibited_labels
  }
}

control "dns_managed_zone_prohibited" {
  title       = "DNS managed zones should not have prohibited labels"
  description = "Check if DNS managed zones have any prohibited labels."
  sql         = replace(local.prohibited_sql_location, "__TABLE_NAME__", "gcp_dns_managed_zone")
  param "prohibited_labels" {
    default = var.prohibited_labels
  }
}

control "sql_database_instance_prohibited" {
  title       = "SQL database instances should not have prohibited labels"
  description = "Check if SQL database instances have any prohibited labels."
  sql         = replace(local.prohibited_sql_location, "__TABLE_NAME__", "gcp_sql_database_instance")
  param "prohibited_labels" {
    default = var.prohibited_labels
  }
}

control "storage_bucket_prohibited" {
  title       = "Storage buckets should not have prohibited labels"
  description = "Check if Storage buckets have any prohibited labels."
  sql         = replace(local.prohibited_sql_location, "__TABLE_NAME__", "gcp_storage_bucket")
  param "prohibited_labels" {
    default = var.prohibited_labels
  }
}

control "bigtable_instance_prohibited" {
  title       = "Bigtable instances should not have prohibited labels"
  description = "Check if bigtable instances have any prohibited labels."
  sql         = replace(local.prohibited_sql_location, "__TABLE_NAME__", "gcp_bigtable_instance")
  param "prohibited_labels" {
    default = var.prohibited_labels
  }
}

control "dataproc_cluster_prohibited" {
  title       = "Dataproc clusters should not have prohibited labels"
  description = "Check if dataproc clusters have any prohibited labels."
  sql         = replace(local.prohibited_sql_location, "__TABLE_NAME__", "gcp_dataproc_cluster")
  param "prohibited_labels" {
    default = var.prohibited_labels
  }
}

control "dataproc_job_prohibited" {
  title       = "Dataproc jobs should not have prohibited labels"
  description = "Check if dataproc jobs have any prohibited labels."
  sql         = replace(local.prohibited_sql_location, "__TABLE_NAME__", "gcp_dataproc_job")
  param "prohibited_labels" {
    default = var.prohibited_labels
  }
}

control "pubsub_subscription_prohibited" {
  title       = "Pubsub subscriptions should not have prohibited labels"
  description = "Check if pubsub subscriptions have any prohibited labels."
  sql         = replace(local.prohibited_sql_location, "__TABLE_NAME__", "gcp_pubsub_subscription")
  param "prohibited_labels" {
    default = var.prohibited_labels
  }
}

control "pubsub_topic_prohibited" {
  title       = "Pubsub topics should not have prohibited labels"
  description = "Check if pubsub topics have any prohibited labels."
  sql         = replace(local.prohibited_sql_location, "__TABLE_NAME__", "gcp_pubsub_topic")
  param "prohibited_labels" {
    default = var.prohibited_labels
  }
}
