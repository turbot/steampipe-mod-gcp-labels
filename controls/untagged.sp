benchmark "untagged" {
  title = "Untagged"
  children = [
    control.cloud_function_untagged,
    control.storage_bucket_untagged,
  ]
}

control "cloud_function_untagged" {
  title = "Cloud Functions Untagged"
  sql = <<EOT
    select
      name as resource,
      case
        when tags is not null then 'ok'
        else 'alarm'
      end as status,
      case
        when tags is not null then name || ' has tags.'
        else name || ' has no tags.'
      end as reason,
      location,
      project
    from
      gcp_cloudfunctions_function
    EOT
}

control "storage_bucket_untagged" {
  title = "Storage Buckets Untagged"
  sql = <<EOT
    select
      name as resource,
      case
        when tags is not null then 'ok'
        else 'alarm'
      end as status,
      case
        when tags is not null then name || ' has tags.'
        else name || ' has no tags.'
      end as reason,
      location,
      project
    from
      gcp_storage_bucket
    EOT
}
