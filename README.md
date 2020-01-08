# VMs for Bare Metal Kubernetes Example on Digital Ocean managed by Terraform

    2020 Ondrej Sika <ondrej@ondrejsika.com>
    https://github.com/ondrejsika/terraform-do-bare-metal-kubernetes-example

## Run

```
terraform init
terraform plan
terraform apply -auto-approve
```

## Infrastructure overview

Masters

- `m0.bm-vm.sikademo.com`

Nodes

- `n0.bm-vm.sikademo.com`
- `n1.bm-vm.sikademo.com`

Loadbalancer

- `bm-k8s.sikademo.com`
- `*.bm-k8s.sikademo.com`

## Destroy

```
terraform destroy -auto-approve
```
