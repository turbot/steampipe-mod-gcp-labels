# GCP Labels Mod for Powerpipe

> [!IMPORTANT]
> [Powerpipe](https://powerpipe.io) is now the preferred way to run this mod! [Migrating from Steampipe →](https://powerpipe.io/blog/migrating-from-steampipe)
>
> All v0.x versions of this mod will work in both Steampipe and Powerpipe, but v1.0.0 onwards will be in Powerpipe format only.

A GCP labels checking tool that can be used to look for unlabeled resources, missing labels, resources with too many labels, and more.

Run checks in a dashboard:

![image](https://raw.githubusercontent.com/turbot/steampipe-mod-gcp-labels/main/docs/gcp_labels_dashboard.png)

Or in a terminal:

![image](https://raw.githubusercontent.com/turbot/steampipe-mod-gcp-labels/main/docs/gcp_labels_mod_terminal.png)

## Documentation

- **[Benchmarks and controls →](https://hub.powerpipe.io/mods/turbot/gcp_labels/controls)**

## Getting Started

### Installation

Install Powerpipe (https://powerpipe.io/downloads), or use Brew:

```sh
brew install turbot/tap/powerpipe
```

This mod also requires [Steampipe](https://steampipe.io) with the [GCP plugin](https://hub.steampipe.io/plugins/turbot/gcp) as the data source. Install Steampipe (https://steampipe.io/downloads), or use Brew:

```sh
brew install turbot/tap/steampipe
steampipe plugin install gcp
```

Steampipe will automatically use your default GCP credentials. Optionally, you can [setup multiple projects](https://hub.steampipe.io/plugins/turbot/gcp#multi-project-connections).

Finally, install the mod:

```sh
mkdir dashboards
cd dashboards
powerpipe mod init
powerpipe mod install github.com/turbot/steampipe-mod-gcp-labels
```

### Browsing Dashboards

Start Steampipe as the data source:

```sh
steampipe service start
```

Start the dashboard server:

```sh
powerpipe server
```

Browse and view your dashboards at **http://localhost:9033**.

### Running Checks in Your Terminal

Instead of running benchmarks in a dashboard, you can also run them within your
terminal with the `powerpipe benchmark` command:

List available benchmarks:

```sh
powerpipe benchmark list
```

Run a benchmark:

```sh
powerpipe benchmark run gcp_labels.benchmark.unlabeled
```

Different output formats are also available, for more information please see
[Output Formats](https://powerpipe.io/docs/reference/cli/benchmark#output-formats).

### Configure Variables

Several benchmarks have [input variables](https://powerpipe.io/docs/build/mod-variables#input-variables) that can be configured to better match your environment and requirements. Each variable has a default defined in its source file, e.g., `controls/limit.sp`, but these can be overridden in several ways:

It's easiest to setup your vars file, starting with the sample:

```sh
cp steampipe.spvars.example steampipe.spvars
vi steampipe.spvars
```
Alternatively you can pass variables on the command line:

```sh
powerpipe benchmark run gcp_labels.benchmark.mandatory --var 'mandatory_labels=["application", "environment", "department", "owner"]'
```

Or through environment variables:

```sh
export PP_VAR_mandatory_labels='["application", "environment", "department"]'
powerpipe benchmark run gcp_labels.benchmark.mandatory
```

These are only some of the ways you can set variables. For a full list, please see [Passing Input Variables](https://powerpipe.io/docs/build/mod-variables#passing-input-variables).

### Remediation

Using the control output and the gcloud CLI, you can remediate various label issues.

For instance, with the results of the `compute_instance_mandatory` control, you can add missing labels with the gcloud CLI:

```sh
#!/bin/bash

OLDIFS=$IFS
IFS='#'

INPUT=$(powerpipe control run compute_instance_mandatory --var 'mandatory_labels=["application"]' --output csv --header=false --separator '#' | grep 'alarm')
[ -z "$INPUT" ] && { echo "No instances in alarm, aborting"; exit 0; }

while read -r group_id title description control_id control_title control_description reason resource status location project
do
  # Get the instance name from the self-link, e.g., https://www.googleapis.com/compute/v1/projects/my-project/zones/us-central1-a/instances/my-instance
  instance_name=$(echo "$resource" | rev | cut -d "/" -f1 | rev)
  gcloud compute instances add-labels "$instance_name" --labels=application=my_application --zone=${location}
done <<< "$INPUT"

IFS=$OLDIFS
```

To remove prohibited labels from Compute instances:
```sh
#!/bin/bash

OLDIFS=$IFS
IFS='#'

INPUT=$(powerpipe control run compute_instance_mandatory --var 'prohibited_labels=["password"]' --output csv --header=false --separator '#' | grep 'alarm')
[ -z "$INPUT" ] && { echo "No instances in alarm, aborting"; exit 0; }

while read -r group_id title description control_id control_title control_description reason resource status location project
do
  # Get the instance name from the self-link, e.g., https://www.googleapis.com/compute/v1/projects/my-project/zones/us-central1-a/instances/my-instance
  instance_name=$(echo "$resource" | rev | cut -d "/" -f1 | rev)
  gcloud compute instances remove-labels ${instance_name} --labels=password --zone=${location}
done <<< "$INPUT"
```

## Open Source & Contributing

This repository is published under the [Apache 2.0 license](https://www.apache.org/licenses/LICENSE-2.0). Please see our [code of conduct](https://github.com/turbot/.github/blob/main/CODE_OF_CONDUCT.md). We look forward to collaborating with you!

[Steampipe](https://steampipe.io) and [Powerpipe](https://powerpipe.io) are products produced from this open source software, exclusively by [Turbot HQ, Inc](https://turbot.com). They are distributed under our commercial terms. Others are allowed to make their own distribution of the software, but cannot use any of the Turbot trademarks, cloud services, etc. You can learn more in our [Open Source FAQ](https://turbot.com/open-source).

## Get Involved

**[Join #powerpipe on Slack →](https://turbot.com/community/join)**

Want to help but don't know where to start? Pick up one of the `help wanted` issues:

- [Powerpipe](https://github.com/turbot/powerpipe/labels/help%20wanted)
- [GCP Labels Mod](https://github.com/turbot/steampipe-mod-gcp-labels/labels/help%20wanted)
