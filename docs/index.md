---
repository: "https://github.com/turbot/steampipe-mod-gcp-labels"
---

# GCP Labels Mod

Run label controls across all your GCP projects to look for unlabeled resources, missing labels , resources with too many labels, and more.

<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-gcp-labels/main/docs/gcp_labels_dashboard.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-gcp-labels/main/docs/gcp_labels_mandatory_dashboard.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-gcp-labels/main/docs/gcp_labels_mod_terminal.png" width="50%" type="thumbnail"/>

## References

[GCP](https://cloud.google.com) provides on-demand cloud computing platforms and APIs to authenticated customers on a metered pay-as-you-go basis.

[Steampipe](https://steampipe.io) is an open source CLI to instantly query cloud APIs using SQL.

[Steampipe Mods](https://steampipe.io/docs/reference/mod-resources#mod) are collections of `named queries`, and codified `controls` that can be used to test current configuration of your cloud resources against a desired configuration.

## Documentation

- **[Benchmarks and controls →](https://hub.steampipe.io/mods/turbot/gcp_labels/controls)**

## Getting started

### Installation

Download and install Steampipe (https://steampipe.io/downloads). Or use Brew:

```sh
brew tap turbot/tap
brew install steampipe
```

Install the GCP plugin with [Steampipe](https://steampipe.io):

```sh
steampipe plugin install gcp
```

Clone:

```sh
git clone https://github.com/turbot/steampipe-mod-gcp-labels.git
cd steampipe-mod-gcp-labels
```

### Usage

Start your dashboard server to get started:

```sh
steampipe dashboard
```

By default, the dashboard interface will then be launched in a new browser
window at http://localhost:9194. From here, you can run benchmarks by
selecting one or searching for a specific one.

Instead of running benchmarks in a dashboard, you can also run them within your
terminal with the `steampipe check` command:

Run all benchmarks:

```sh
steampipe check all
```

Run a single benchmark:

```sh
steampipe check benchmark.unlabeled
```

Run a specific control:

```sh
steampipe check control.storage_bucket_unlabeled
```

Different output formats are also available, for more information please see
[Output Formats](https://steampipe.io/docs/reference/cli/check#output-formats).

### Credentials

This mod uses the credentials configured in the [Steampipe GCP plugin](https://hub.steampipe.io/plugins/turbot/gcp).

### Configuration

Several benchmarks have [input variables](https://steampipe.io/docs/using-steampipe/mod-variables) that can be configured to better match your environment and requirements. Each variable has a default defined in its source file, e.g., `controls/limit.sp`, but these can be overriden in several ways:

- Copy and rename the `steampipe.spvars.example` file to `steampipe.spvars`, and then modify the variable values inside that file
- Pass in a value on the command line:
  ```shell
  steampipe check benchmark.mandatory --var 'mandatory_labels=["application", "environment", "department", "owner"]'
  ```
- Set an environment variable:
  ```shell
  SP_VAR_mandatory_labels='["application", "environment", "department", "owner"]' steampipe check control.compute_instance_mandatory
  ```
  - Note: When using environment variables, if the variable is defined in `steampipe.spvars` or passed in through the command line, either of those will take precedence over the environment variable value. For more information on variable definition precedence, please see the link below.

These are only some of the ways you can set variables. For a full list, please see [Passing Input Variables](https://steampipe.io/docs/using-steampipe/mod-variables#passing-input-variables).

## Advanced usage

### Remediation

Using the control output and the gcloud CLI, you can remediate various label issues.

For instance, with the results of the `compute_instance_mandatory` control, you can add missing labels with the gcloud CLI:

```bash
#!/bin/bash

OLDIFS=$IFS
IFS='#'

INPUT=$(steampipe check control.compute_instance_mandatory --var 'mandatory_labels=["application"]' --output csv --header=false --separator '#' | grep 'alarm')
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
```bash
#!/bin/bash

OLDIFS=$IFS
IFS='#'

INPUT=$(steampipe check control.compute_instance_mandatory --var 'prohibited_labels=["password"]' --output csv --header=false --separator '#' | grep 'alarm')
[ -z "$INPUT" ] && { echo "No instances in alarm, aborting"; exit 0; }

while read -r group_id title description control_id control_title control_description reason resource status location project
do
  # Get the instance name from the self-link, e.g., https://www.googleapis.com/compute/v1/projects/my-project/zones/us-central1-a/instances/my-instance
  instance_name=$(echo "$resource" | rev | cut -d "/" -f1 | rev)
  gcloud compute instances remove-labels ${instance_name} --labels=password --zone=${location}
done <<< "$INPUT"

IFS=$OLDIFS
```


## Contributing

If you have an idea for additional controls or just want to help maintain and extend this mod ([or others](https://github.com/topics/steampipe-mod)) we would love you to join the community and start contributing.

- **[Join our Slack community →](https://steampipe.io/community/join)** and hang out with other Mod developers.

Please see the [contribution guidelines](https://github.com/turbot/steampipe/blob/main/CONTRIBUTING.md) and our [code of conduct](https://github.com/turbot/steampipe/blob/main/CODE_OF_CONDUCT.md). All contributions are subject to the [Apache 2.0 open source license](https://github.com/turbot/steampipe-mod-gcp-labels/blob/main/LICENSE).

Want to help but not sure where to start? Pick up one of the `help wanted` issues:

- [Steampipe](https://github.com/turbot/steampipe/labels/help%20wanted)
- [GCP Labels Mod](https://github.com/turbot/steampipe-mod-gcp-labels/labels/help%20wanted)