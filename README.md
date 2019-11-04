# Terraform source code



## Installation

Bootstrapping code should have created the service accounts and downloaded keys
into the parent `keys` subdirectory. It should also have created the bucket
that Terraform needs to maintain state (local state directory isn't going to
help you much if you're in a team). Last, it should have enabled the necessary
API into your project.

If not you will have to do those manually, then see Notes.

You can then use Terraform. As a Go binary you can install it by downloading it
into a PATH enabled directory and chmoding it the execution bits.

Afterwards run `terraform init`. This will read source code, finds necessary
plugins, download and install them.

Then use a combination of `terraform validate`, `terraform plan` and `terraform
apply` to achieve your goal.

## Notes

### Remote state bucket

Ensure the bucket you plan to use is not already taken (buckets have globally
unique names). And that it has no dot in it (otherwise considered as a domain
name and must be verified).

### Projects' API accesses

You may have to enable API to the project: Kubernetes and Compute Engine say.
Simplest way to do this is to go the corresponding console tab and wait 1
minute.

### Service accounts and keys

In the AMI console tab.

## Troubleshooting

### Terraform locking issue

If your tfstate backend supports it (and Google Storage does) you may enter in
a race condition when you lose network between state lock acquiring and state
lock release.

The lock release will timeout with this kind of message:

```
Releasing state lock. This may take a few moments...
 
Error releasing the state lock!

Error message: 2 error(s) occurred:

* Delete https://www.googleapis.com/storage/v1/b/be-production-operations-tfstate/o/state%2Fdefault.tflock?alt=json&ifGenerationMatch=1555311004665506: dial tcp 216.58.201.234:443: i/o timeout
* Get https://storage.googleapis.com/be-production-operations-tfstate/state/default.tflock: dial tcp 216.58.209.240:443: i/o timeout

Terraform acquires a lock when accessing your state to prevent others
running Terraform to potentially modify the state at the same time. An
error occurred while releasing this lock. This could mean that the lock
did or did not release properly. If the lock didn't release properly,
Terraform may not be able to run future commands since it'll appear as if
the lock is held.

In this scenario, please call the "force-unlock" command to unlock the
state manually. This is a very dangerous operation since if it is done
erroneously it could result in two people modifying state at the same time.
Only call this command if you're certain that the unlock above failed and
that no one else is holding a lock.
```

The explanatory message is describeful enough, the GenerationMatch URL query
argument is the lock id.

If lock is still present you won't be able to run further commands with
Terraform on your infrastructure, instead you will be welcomed with a message
of the kind:

```
Acquiring state lock. This may take a few moments...

Error: Error locking state: Error acquiring the state lock: writing "gs://be-production-operations-tfstate/state/default.tflock" failed: googleapi: Error 412: Precondition Failed, conditionNotMet
Lock Info:
  ID:        1555311004665506
  Path:      gs://be-production-operations-tfstate/state/default.tflock
  Operation: OperationTypeApply
  Who:       raphael@tibert.home
  Version:   0.11.13
  Created:   2019-04-15 06:50:04.549939 +0000 UTC
  Info:      


Terraform acquires a state lock to protect the state from being written
by multiple users at the same time. Please resolve the issue above and try
again. For most commands, you can disable locking with the "-lock=false"
flag, but this is not recommended.
```

You must be sure that noone is at the moment running Terraform commands really.
If sure then you can copy the `ID` lock info field and paste it as an argument
to the `terraform force-unlock` command like shown below:

```
$ terraform force-unlock 1555311004665506
Do you really want to force-unlock?
  Terraform will remove the lock on the remote state.
  This will allow local Terraform commands to modify this state, even though it
  may be still be in use. Only 'yes' will be accepted to confirm.

  Enter a value: yes

Terraform state has been successfully unlocked!

The state has been unlocked, and Terraform commands should now be able to
obtain a new lock on the remote state.
```

## Caveats

### DNS peering zones (2019-04-19)

Peering and non-peering zones, despite using the same API call, are not the
same kind of resources. Once created you cannot "migrate" them from one kind to
the other. If you want to do so, you'll have to comment out the zone, run
`terraform apply` to delete it, uncomment it and make the change, then finally
run `terraform apply` again to create a new one of the right kind.
=======
# Base infrastructure's devops source code

The base infrastructure managed by the source code in that repository is for
now exclusively present on Google Cloud. Here follows the actual list of
projects:

   - `be-production-operations` : Services for running the operations. It is a
     production project however the services are used to manage non-production
     environments as well.
   - `be-production-applications` : The applications themselves, e.g. web sites,
     databases, etc.
   - `be-no-production-applications` : Still applications but under non
     production environments.
   - `be-no-production-sandbox` : A test and play project that will be cleared
     every night.

Source code is organized in subdirectories each targeting a tool :

   - `terraform` : Maintains the infrastructure under a described / defined
     state.
   - `packer` : Builds an image for the cloud.
   - `kubernetes` : Operates services' containers.

## Setup

To use most of the tools you will need credentials over the Google Cloud
projects.

## Prerequisites

To use the Terraform external data gatherers you will need a recent Git version
(more recent than 2.11.0).

## Appendix

### Regions and Zones

From [online list](https://cloud.google.com/compute/docs/regions-zones/) read
on Nov 23 2018.

| Region                  | Zones      | Location
| ----------------------- | ---------- | -------------------------------------
| asia-east1              | a, b, c    | Changhua County, Taiwan
| asia-east2              | a, b, c    | Hong Kong
| asia-northeast1         | a, b, c    | Tokyo, Japan
| asia-south1             | a, b, c    | Mumbai, India
| asia-southeast1         | a, b, c    | Jurong West, Singapore
| australia-southeast1    | a, b, c    | Sydney, Australia
| europe-north1           | a, b, c    | Hamina, Finland
| europe-west1            | b, c, d    | St. Ghislain, Belgium
| europe-west2            | a, b, c    | London, England, UK
| europe-west3            | a, b, c    | Frankfurt, Germany
| europe-west4            | a, b, c    | Eemshaven, Netherlands
| northamerica-northeast1 | a, b, c    | Montréal, Québec, Canada
| southamerica-east1      | a, b, c    | São Paulo, Brazil
| us-central1             | a, b, c, f | Council Bluffs, Iowa, USA
| us-east1                | b, c, d    | Moncks Corner, South Carolina, USA
| us-east4                | a, b, c    | Ashburn, Northern Virginia, USA
| us-west1                | a, b, c    | The Dalles, Oregon, USA
| us-west2                | a, b, c    | Los Angeles, California, USA

