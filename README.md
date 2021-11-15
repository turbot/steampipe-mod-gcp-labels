# GCP Labels Tool

A GCP labels checking tool that can be used to look for unlabeled resources, missing labels, resources with too many labels, and more.

![image](https://raw.githubusercontent.com/turbot/steampipe-mod-gcp-labels/main/docs/gcp_labels_mod_terminal.png)

## Getting started

### Installation

1) Download and install Steampipe (https://steampipe.io/downloads). Or use Brew:

```shell
brew tap turbot/tap
brew install steampipe

steampipe -v
steampipe version 0.8.0
```

2) Install the GCP plugin:
```shell
steampipe plugin install gcp
```

3) Clone this repo:
```sh
git clone https://github.com/turbot/steampipe-mod-gcp-labels.git
cd steampipe-mod-gcp-labels
```

### Usage

#### Running benchmarks

Preview running all benchmarks:
```shell
steampipe check all --dry-run
```

Run all benchmarks:
```shell
steampipe check all
```

Use Steampipe introspection to view all current benchmarks:
```shell
steampipe query "select resource_name, title, description from steampipe_benchmark;"
```

Run an individual benchmark:
```shell
steampipe check benchmark.unlabeled
```

#### Running controls

Use Steampipe introspection to view all current controls:
```shell
steampipe query "select resource_name, title, description from steampipe_control;"
```

Run a specific control:
```shell
steampipe check control.storage_bucket_unlabeled
```

### Configuration

Several benchmarks have [input variables](https://steampipe.io/docs/using-steampipe/mod-variables) that can be configured to better match your environment and requirements. Each variable has a default defined in `steampipe.spvars`, but these can be overriden in several ways:

- Modify the `steampipe.spvars` file
- Remove or comment out the value in `steampipe.spvars`, after which Steampipe will prompt you for a value when running a query or check
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
```

## Contributing

If you have an idea for additional label controls, or just want to help maintain and extend this mod ([or others](https://github.com/topics/steampipe-mod)) we would love you to join the community and start contributing. (Even if you just want to help with the docs.)

- **[Join our Slack community →](https://join.slack.com/t/steampipe/shared_invite/zt-oij778tv-lYyRTWOTMQYBVAbtPSWs3g)** and hang out with other Mod developers.
- **[Mod developer guide →](https://steampipe.io/docs/steampipe-mods/writing-mods.md)**

Please see the [contribution guidelines](https://github.com/turbot/steampipe/blob/main/CONTRIBUTING.md) and our [code of conduct](https://github.com/turbot/steampipe/blob/main/CODE_OF_CONDUCT.md). All contributions are subject to the [Apache 2.0 open source license](https://github.com/turbot/steampipe-mod-gcp-labels/blob/main/LICENSE).

`help wanted` issues:
- [Steampipe](https://github.com/turbot/steampipe/labels/help%20wanted)
- [GCP Labels Mod](https://github.com/turbot/steampipe-mod-gcp-labels/labels/help%20wanted)
