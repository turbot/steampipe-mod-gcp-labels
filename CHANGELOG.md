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
