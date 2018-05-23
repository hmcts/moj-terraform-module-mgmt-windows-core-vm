# Overview

This repository contains the source code of a single terraform module for provisoning Windows Server 2016 Core Datacentre

## TODO

- Create terraform code in the tests directory which makes use of the module
- Create a Jenkinsfile which runs terraform plan + apply in sandbox when a Pull Request is created
- Decide if the test can do a "plan" + "apply" + "destroy" so it does not charge for unused VMs ?