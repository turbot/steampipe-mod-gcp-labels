## v0.6 [2022-09-09]

_What's new?_

- New controls added to the `Limit` benchmark:([#18](https://github.com/turbot/steampipe-mod-gcp-labels/pull/18))(Thanks to [@leegin](https://github.com/leegin) for the contribution!)
  - `bigtable_instance_label_limit`
  - `dataproc_cluster_label_limit`
  - `pubsub_subscription_label_limit`
  - `pubsub_topic_label_limit`
- New controls added to the `Mandatory` benchmark:([#18](https://github.com/turbot/steampipe-mod-gcp-labels/pull/18))  
  - `bigtable_instance_mandatory`
  - `dataproc_cluster_mandatory`
  - `pubsub_subscription_mandatory`
  - `pubsub_topic_mandatory`
- New controls added to the `Prohibited` benchmark:([#18](https://github.com/turbot/steampipe-mod-gcp-labels/pull/18))  
  - `bigtable_instance_prohibited`
  - `dataproc_cluster_prohibited`
  - `pubsub_subscription_prohibited`
  - `pubsub_topic_prohibited`
- New controls added to the `Unlabeled` benchmark:([#18](https://github.com/turbot/steampipe-mod-gcp-labels/pull/18))  
  - `bigtable_instance_unlabeled`
  - `dataproc_cluster_unlabeled`
  - `pubsub_subscription_unlabeled`
  - `pubsub_topic_unlabeled`

_Dependencies_

- GCP plugin `v0.27.0` or higher is now required. ([#20](https://github.com/turbot/steampipe-mod-gcp-labels/pull/20))

## v0.5 [2022-05-09]

_Enhancements_

- Updated docs/index.md and README with new dashboard screenshots and latest format. ([#15](https://github.com/turbot/steampipe-mod-gcp-labels/pull/15))

## v0.4 [2022-05-02]

_Enhancements_

- Added `category`, `service`, and `type` tags to benchmarks and controls. ([#12](https://github.com/turbot/steampipe-mod-gcp-labels/pull/12))

## v0.3 [2022-03-29]

_What's new?_

- Added default values to all variables (set to the same values in `steampipe.spvars.example`)
- Added `*.spvars` and `*.auto.spvars` files to `.gitignore`
- Renamed `steampipe.spvars` to `steampipe.spvars.example`, so the variable default values will be used initially. To use this example file instead, copy `steampipe.spvars.example` as a new file `steampipe.spvars`, and then modify the variable values in it. For more information on how to set variable values, please see [Input Variable Configuration](https://hub.steampipe.io/mods/turbot/gcp_labels#configuration).

## v0.2 [2021-11-15]

_Enhancements_

- `README.md` and `docs/index.md` files now include the console output image

## v0.1 [2021-09-09]

_What's new?_

New control types:
- Unlabeled: Find resources with no label.
- Prohibited: Find prohibited label names.
- Mandatory: Ensure mandatory labels are set.
- Limit: Detect when the label limit is nearly met.

For the resource types:
- bigquery_dataset
- bigquery_job
- bigquery_table
- compute_disk
- compute_forwarding_rule
- compute_image
- compute_instance
- compute_snapshot
- dns_managed_zone
- sql_database_instance
- storage_bucket
