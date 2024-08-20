variable "expected_label_values" {
  type        = map(list(string))
  description = "Map of expected values for various labels, e.g., {\"environment\": [\"Prod\", \"Staging\", \"Dev%\"]}. SQL wildcards '%' and '_' can be used for matching values. These characters must be escaped for exact matches, e.g., {\"created_by\": [\"test\\_user\"]}."

  default = {
    "environment" : ["dev", "staging", "prod"]
  }
}

locals {
  expected_label_values_sql = <<-EOQ
    with raw_data as
    (
      select
        self_link,
        title,
        labels,
        row_to_json(json_each($1)) as expected_label_values,
        location,
        project,
        _ctx
      from
        __TABLE_NAME__
      where
        labels is not null
    ),
    exploded_expected_label_values as
    (
      select
        self_link,
        title,
        expected_label_values ->> 'key' as label_key,
        jsonb_array_elements_text((expected_label_values ->> 'value')::jsonb) as expected_values,
        labels ->> (expected_label_values ->> 'key') as current_value,
        location,
        project,
        _ctx
      from
        raw_data
    ),
    analysis as
    (
      select
        self_link,
        title,
        current_value like expected_values as has_appropriate_value,
        case
          when current_value is null then true
          else false
        end as has_no_matching_labels,
        label_key,
        current_value,
        location,
        project,
        _ctx
      from
        exploded_expected_label_values
    ),
    status_by_label as
    (
      select
        self_link,
        title,
        bool_or(has_appropriate_value) as status,
        label_key,
        case
          when bool_or(has_appropriate_value) then ''
          else label_key
        end as reason,
        bool_or(has_no_matching_labels) as can_skip,
        current_value,
        location,
        project,
        _ctx
      from
        analysis
      group by
        self_link,
        title,
        label_key,
        current_value,
        location,
        project,
        _ctx
    )
    select
      self_link as resource,
      case
        when bool_and(can_skip) then 'skip'
        when bool_and(status) then 'ok'
        else 'alarm'
      end as status,
      case
        when bool_and(can_skip) then title || ' has no matching label keys.'
        when bool_and(status) then title || ' has expected label values for labels: ' || array_to_string(array_agg(label_key) filter(where status), ', ') || '.'
        else title || ' has unexpected label values for labels: ' || array_to_string(array_agg(label_key) filter(where not status), ', ') || '.'
      end as reason
      ${local.tag_dimensions_sql}
      ${local.common_dimensions_sql}
    from
      status_by_label
    group by
      self_link,
      title,
        location,
        project,
        _ctx
    union all
    select
      self_link as resource,
      'skip' as status,
      title || ' has no labels.' as reason
      ${local.tag_dimensions_sql}
      ${local.common_dimensions_sql}
    from
      __TABLE_NAME__
    where
      labels is null
    union all
    select
      self_link as resource,
      'skip' as status,
      title || ' has labels but no expected label values are set.' as reason
      ${local.tag_dimensions_sql}
      ${local.common_dimensions_sql}
    from
      __TABLE_NAME__
    where
      $1::text = '{}'
      and labels is not null
  EOQ
}

benchmark "expected_label_values" {
  title       = "Expected Label Values"
  description = "Resources should have specific values for some labels."
  children = [
    control.bigquery_dataset_expected_label_values,
    control.bigquery_job_expected_label_values,
    control.bigquery_table_expected_label_values,
    control.bigtable_instance_expected_label_values,
    control.compute_disk_expected_label_values,
    control.compute_forwarding_rule_expected_label_values,
    control.compute_image_expected_label_values,
    control.compute_instance_expected_label_values,
    control.compute_snapshot_expected_label_values,
    control.dataproc_cluster_expected_label_values,
    control.dns_managed_zone_expected_label_values,
    control.pubsub_subscription_expected_label_values,
    control.pubsub_topic_expected_label_values,
    control.sql_database_instance_expected_label_values,
    control.storage_bucket_expected_label_values
  ]

  tags = merge(local.gcp_labels_common_tags, {
    type = "Benchmark"
  })
}

control "bigquery_dataset_expected_label_values" {
  title       = "BigQuery datasets should have appropriate label values"
  description = "Check if BigQuery datasets have appropriate label values."
  sql         = replace(local.expected_label_values_sql, "__TABLE_NAME__", "gcp_bigquery_dataset")
  param "expected_label_values" {
    default = var.expected_label_values
  }
}

control "bigquery_job_expected_label_values" {
  title       = "BigQuery jobs should have appropriate label values"
  description = "Check if BigQuery jobs have appropriate label values."
  sql         = replace(local.expected_label_values_sql, "__TABLE_NAME__", "gcp_bigquery_job")
  param "expected_label_values" {
    default = var.expected_label_values
  }
}

control "bigquery_table_expected_label_values" {
  title       = "BigQuery tables should have appropriate label values"
  description = "Check if BigQuery tables have appropriate label values."
  sql         = replace(local.expected_label_values_sql, "__TABLE_NAME__", "gcp_bigquery_table")
  param "expected_label_values" {
    default = var.expected_label_values
  }
}

control "compute_disk_expected_label_values" {
  title       = "Compute disks should have appropriate label values"
  description = "Check if Compute disks have appropriate label values."
  sql         = replace(local.expected_label_values_sql, "__TABLE_NAME__", "gcp_compute_disk")
  param "expected_label_values" {
    default = var.expected_label_values
  }
}

control "compute_forwarding_rule_expected_label_values" {
  title       = "Compute forwarding rules should have appropriate label values"
  description = "Check if Compute forwarding rules have appropriate label values."
  sql         = replace(local.expected_label_values_sql, "__TABLE_NAME__", "gcp_compute_forwarding_rule")
  param "expected_label_values" {
    default = var.expected_label_values
  }
}

control "compute_image_expected_label_values" {
  title       = "Compute images should have appropriate label values"
  description = "Check if Compute images have appropriate label values."
  sql         = <<-EOQ
    with raw_data as
    (
      select
        self_link,
        title,
        labels,
        row_to_json(json_each($1)) as expected_label_values,
        location,
        project
      from
        gcp_compute_image
      where
        labels is not null
        and source_project = project
    ),
    exploded_expected_label_values as
    (
      select
        self_link,
        title,
        expected_label_values ->> 'key' as label_key,
        jsonb_array_elements_text((expected_label_values ->> 'value')::jsonb) as expected_values,
        labels ->> (expected_label_values ->> 'key') as current_value,
        location,
        project
      from
        raw_data
    ),
    analysis as
    (
      select
        self_link,
        title,
        current_value like expected_values as has_appropriate_value,
        case
          when current_value is null then true
          else false
        end as has_no_matching_labels,
        label_key,
        current_value,
        location,
        project
      from
        exploded_expected_label_values
    ),
    status_by_label as
    (
      select
        self_link,
        title,
        bool_or(has_appropriate_value) as status,
        label_key,
        case
          when bool_or(has_appropriate_value) then ''
          else label_key
        end as reason,
        bool_or(has_no_matching_labels) as can_skip,
        current_value,
        location,
        project
      from
        analysis
      group by
        self_link,
        title,
        label_key,
        current_value,
        location,
        project
    )
    select
      self_link as resource,
      case
        when bool_and(can_skip) then 'skip'
        when bool_and(status) then 'ok'
        else 'alarm'
      end as status,
      case
        when bool_and(can_skip) then title || ' has no matching label keys.'
        when bool_and(status) then title || ' has expected label values for labels: ' || array_to_string(array_agg(label_key) filter(where status), ', ') || '.'
        else title || ' has unexpected label values for labels: ' || array_to_string(array_agg(label_key) filter(where not status), ', ') || '.'
      end as reason,
      location,
      project
    from
      status_by_label
    group by
      self_link,
      title,
      location,
      project
    union all
    select
      self_link as resource,
      'skip' as status,
      title || ' has no labels.' as reason,
      location,
      project
    from
      gcp_compute_image
    where
      labels is null
      and source_project = project
    union all
    select
      self_link as resource,
      'skip' as status,
      title || ' has labels but no expected label values are set.' as reason,
      location,
      project
    from
      gcp_compute_image
    where
      $1::text = '{}'
      and labels is not null
      and source_project = project
  EOQ
  param "expected_label_values" {
    default = var.expected_label_values
  }
}

control "compute_instance_expected_label_values" {
  title       = "Compute instances should have appropriate label values"
  description = "Check if Compute instances have appropriate label values."
  sql         = replace(local.expected_label_values_sql, "__TABLE_NAME__", "gcp_compute_instance")
  param "expected_label_values" {
    default = var.expected_label_values
  }
}

control "compute_snapshot_expected_label_values" {
  title       = "Compute snapshots should have appropriate label values"
  description = "Check if Compute snapshots have appropriate label values."
  sql         = replace(local.expected_label_values_sql, "__TABLE_NAME__", "gcp_compute_snapshot")
  param "expected_label_values" {
    default = var.expected_label_values
  }
}

control "dns_managed_zone_expected_label_values" {
  title       = "DNS managed zones should have appropriate label values"
  description = "Check if DNS managed zones have appropriate label values."
  sql         = replace(local.expected_label_values_sql, "__TABLE_NAME__", "gcp_dns_managed_zone")
  param "expected_label_values" {
    default = var.expected_label_values
  }
}

control "sql_database_instance_expected_label_values" {
  title       = "SQL database instances should have appropriate label values"
  description = "Check if SQL database instances have appropriate label values."
  sql         = replace(local.expected_label_values_sql, "__TABLE_NAME__", "gcp_sql_database_instance")
  param "expected_label_values" {
    default = var.expected_label_values
  }
}

control "storage_bucket_expected_label_values" {
  title       = "Storage buckets should have appropriate label values"
  description = "Check if Storage buckets have appropriate label values."
  sql         = replace(local.expected_label_values_sql, "__TABLE_NAME__", "gcp_storage_bucket")
  param "expected_label_values" {
    default = var.expected_label_values
  }
}

control "bigtable_instance_expected_label_values" {
  title       = "Bigtable instances should have appropriate label values"
  description = "Check if Bigtable instances have appropriate label values."
  sql         = replace(local.expected_label_values_sql, "__TABLE_NAME__", "gcp_bigtable_instance")
  param "expected_label_values" {
    default = var.expected_label_values
  }
}

control "dataproc_cluster_expected_label_values" {
  title       = "Dataproc clusters should have appropriate label values"
  description = "Check if Dataproc clusters have appropriate label values."
  sql         = replace(local.expected_label_values_sql, "__TABLE_NAME__", "gcp_dataproc_cluster")
  param "expected_label_values" {
    default = var.expected_label_values
  }
}

control "pubsub_subscription_expected_label_values" {
  title       = "Pub/Sub subscriptions should have appropriate label values"
  description = "Check if Pub/Sub subscriptions have appropriate label values."
  sql         = replace(local.expected_label_values_sql, "__TABLE_NAME__", "gcp_pubsub_subscription")
  param "expected_label_values" {
    default = var.expected_label_values
  }
}

control "pubsub_topic_expected_label_values" {
  title       = "Pub/Sub topics should have appropriate label values"
  description = "Check if Pub/Sub topics have appropriate label values."
  sql         = replace(local.expected_label_values_sql, "__TABLE_NAME__", "gcp_pubsub_topic")
  param "expected_label_values" {
    default = var.expected_label_values
  }
}
