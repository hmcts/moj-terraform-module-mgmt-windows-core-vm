# Overview
This repository contains the source code of a single terraform module which
has been migrated from the terraform-infrastructure repository:
https://git.reform.hmcts.net/devops/terraform-infrastructure/tree/master/main-environment/modules/mgmt-windows-vm

# TODO
  * Create terraform code in the tests directory which makes use of the module
  * Create a Jenkinsfile which runs terraform plan + apply in sandbox when a Pull Request is created
  * Decide if the test can do a "plan" + "apply" + "destroy" so it does not charge for unused VMs ?
