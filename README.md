# Ezmeral Container Platform Demo

## on AWS and Azure (Vmware and KVM to follow)

Automated installation for Ezmeral Container Platform and MLOps on AWS/Azure for demo purpose.

You need docker to run the container. It should work on any docker runtime.

## Usage

Download the [start script](https://raw.githubusercontent.com/hpe-container-platform-community/ezdemo/main/start.sh), or copy/paste below to start the container.

```bash
#!/usr/bin/env bash
VOLUMES=()
CONFIG_FILES=("aws_config.json" "azure_config.json" "vmware_config.json" "kvm_config.json")
for file in "${CONFIG_FILES[@]}"
do
  target="${file%_*}"
  # [[ -f "./${file}" ]] && VOLUMES="--mount=type=bind,source="$(pwd)"/${file},target=/app/server/${target}/config.json ${VOLUMES}"
  [[ -f "./${file}" ]] && VOLUMES+=("$(pwd)/${file}:/app/server/${target}/config.json:rw")
done
printf -v joined ' -v %s' "${VOLUMES[@]}"
docker run -d -p 4000:4000 -p 8443:8443 ${joined} erdincka/ezdemo:latest
```

Create "aws_config.json" or "azure_config.json" in the same folder with your settings and credentials. Template provided below:

AWS Template;

```json
{
  "aws_access_key": "",
  "aws_secret_key": "",
  "project_id": "",
  "user": "",
  "admin_password": "ChangeMe!",
  "is_mlops": false,
  "is_mapr": false,
  "is_gpu": false,
  "is_ha": false
}
```

Azure Template;

```json
{
  "subscription": "",
  "appId": "",
  "password": "",
  "tenant": "",
  "project_id": "",
  "user": "",
  "admin_password": "ChangeMe!",
  "is_mlops": false,
  "is_mapr": false,
  "is_gpu": false,
  "is_ha": false
}
```

Once the container starts, you can either use the WebUI on <http://localhost:4000/> or run scripts manually within the container.

## Advanced Usage

Exec into the container and use scripts provided.

```bash
docker exec -it "$(docker ps -f "status=running" -f "ancestor=erdincka/ezdemo" -q)" /bin/bash
```

### Run all

```./00-run_all.sh aws|azure|vmware|kvm```

### Run Individaully

At any stage if script fails or if you wish to update your environment, you can restart the process wherever needed;

- `./01-init.sh aws|azure|vmware|kvm`
- `./02-apply.sh aws|azure|vmware|kvm`
- `./03-install.sh aws|azure|vmware|kvm`
- `./04-configure.sh aws|azure|vmware|kvm`

Deployed resources will be available in ./server/ansible/inventory.ini file

- All access to the environment is possible only through the gateway

- Use `ssh centos@10.1.0.xx` to access hosts within the container, using their internal IP address (~/.ssh/config setup for jump host via gateway)

- You can copy "./generated/controller.prv_key" and "~/.ssh/config" to your host to use them to access hosts directly

- Copy "./generated/*/minica.pem" to local folder and install into your browser to prevent SSL certificate errors

## Reference

### Utilities used in the container (or you need if you are running locally)

- AWS CLI - Download from [AWS](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Azure-CLI - Download from [Azure](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Terraform - Download from [Terraform](https://www.terraform.io/downloads.html)
- Ansible - Install from [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) or simply via pip (sudo pip3 install ansible)
- python3 (apt/yum/brew install python3)
- jq (apt/yum/brew install jq)
- hpecp (pip3 install hpecp)
- kubectl from [K8s](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

### Scripts

- 00-run_all.sh: Runs all scripts at once (unattended install)
- 01-init.sh: Initialize Terraform, create SSH keys & certificates
- 02-apply.sh: Runs `terraform apply` to deploy resources
- 03-install.sh: Run Ansible scripts to install ECP
- 04-configure.sh: Run Ansible scripts to configure ECP for demo
- 99-destroy.sh: Destroy all created resources on AWS (**DANGER**: All resources will be destroyed, except the generated keys and certificates)

### Ansible Scripts

Courtesy of Dirk Derichsweiler (<https://github.com/dderichswei>).

- prepare_centos: Updates packages and requirements for ECP installation
- install_falco: Updates kernel and install falco service
- install_ecp: Initial installation and setup for ECP
- import_hosts: Collects node information and update them as ECP worker nodes
- create_k8s: Installs Kubernetes Cluster (if MLOps is not selected)
- create_picasso: Installs Kubernetes Cluster and Picasso (Data Fabric on Kubernetes)
- configure_picasso: Enables Picasso (Data Fabric on Kubernetes) for all tenants
- configure_mlops: Configures MLOps tenant and life-cycle tools (Kubeflow, Minio, Jupyter NB etc)

## TO-DO

[X] External DF deployment (single node)

[X] Use GPU workers

[X] Dockerfile to containerise this tool

[X] Add Azure deployment capability

[ ] Add Vmware deployment capability

[ ] Add KVM deployment capability

## Notes

Deployment uses EU-WEST-2 region on AWS, UK South region on Azure.

Region change in AWS is available by manually changing region and az variables in "aws/variables.tf"

```yaml
variable "region" { default = "eu-west-1" }
variable "az" { default = "eu-west-1a" }
```

These regions can be selected for deployment;

us-east-1
us-east-2
us-west-1
us-west-2
ap-southeast-1
eu-central-1
eu-west-1
eu-west-2
eu-west-3
eu-north-1
ca-central-1

For AWS:
Edit ./aws/variables.tf to update region, and az parameters.

For Azure:
Edit ./azure/variables.tf to update region parameter.
