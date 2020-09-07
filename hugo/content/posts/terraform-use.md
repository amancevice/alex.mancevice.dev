---
title: Switching Between Terraform Versions in Bash
date: 2019-11-20
draft: false
toc: false
images:
tags:
  - Terraform
---

Switching between versions of Terraform on macOS is simple using bash.

Add the following to your bash profile:

```bash
function terraform-use {
  vsn=$1
  pkg="terraform_${vsn}_darwin_amd64.zip"
  url="https://releases.hashicorp.com/terraform/${vsn}/${pkg}"
  tf="$(which terraform || echo /usr/local/bin/terraform)"
  if [ -e "${tf}-${vsn}" ]; then
    ln -Fs "${tf}-${vsn}" "${tf}"
  elif curl --head --fail "${url}" 2> /dev/null; then
    wget -O "/tmp/${pkg}" "${url}"
    (
      cd /tmp/
      unzip -o "/tmp/${pkg}"
      rm "/tmp/${pkg}"
      mv terraform "${tf}-${vsn}"
    )
    ln -Fs "${tf}-${vsn}" "${tf}"
  else
    echo "ERROR \`${url}\` not found"
    return 1
  fi
  terraform -version
}
```

Usage:

```bash
$ terraform-use x.y.z
```
