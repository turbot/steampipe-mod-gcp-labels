locals {
  mandatory_tags = ["test", "test1"]
}

benchmark "mandatory" {
  title = "Mandatory"
  children = [
    control.storage_bucket_has_mandatory_tags,
  ]
}

control "storage_bucket_has_mandatory_tags" {
  title = "Storage buckets have mandatory tags"
  sql = <<EOT
    with input as (
      select array${replace(jsonencode(local.mandatory_tags), "\"", "'")} as mandatory_tags
    ),
    analysis as (
      select
        self_link,
        name,
        tags ?& (input.mandatory_tags) as has_mandatory_tags,
        to_jsonb(input.mandatory_tags) - array(select jsonb_object_keys(tags)) as missing_tags,
        location,
        project
      from
        gcp_storage_bucket,
        input
    )
    select
      name as resource,
      case
        when has_mandatory_tags then 'ok'
        else 'alarm'
      end as status,
      case
        when has_mandatory_tags then name || ' has all mandatory tags.'
        else name || ' is missing tags ' || missing_tags
      end as reason,
      name
    from
      analysis
  EOT
}
