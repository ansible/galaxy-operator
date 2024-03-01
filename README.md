<p align="center">
  <img src="https://raw.githubusercontent.com/ansible/galaxy-operator/main/docs/images/logo_large.svg" style="width: 55%" />
</p>

# Galaxy-Operator
The official operator for [Galaxy](https://github.com/ansible/galaxy_ng).

Latest Release: [github.com/ansible/galaxy-operator/releases/latest](https://github.com/ansible/galaxy-operator/releases/latest)

Galaxy-Operator uses the [Ansible Operator SDK](https://sdk.operatorframework.io/docs/building-operators/ansible/).

* Documentation: [galaxy-operator.readthedocs.io](https://galaxy-operator.readthedocs.io)
* Forum: [forum.ansible.com/tag/galaxy-ng](https://forum.ansible.com/tag/galaxy-ng)
* Issues: [github.com/ansible/galaxy-operator/issues](https://github.com/ansible/galaxy-operator/issues)
* Source: [github.com/ansible/galaxy-operator](https://github.com/ansible/galaxy-operator)
* License: GPLv2+

(This project was formerly maintained under the ansible branch of the [pulp-operator repo](https://github.com/pulp/pulp-operator))

# Images
Galaxy-Operator images are automatically built by our CI and [hosted on quay.io](https://quay.io/repository/ansible/galaxy-operator).

Note that Galaxy-Operator requires three separate images (the operator, the main galaxy service, and the web interface):

| Operator | Service | UI |
| -------- | ---- | --- |
| [galaxy-operator](https://quay.io/repository/ansible/galaxy-operator?tab=tags) |[galaxy-ng](https://quay.io/repository/ansible/galaxy-ng?tab=tags) | [galaxy-ui](https://quay.io/repository/ansible/galaxy-ui?tab=tags) |

## Custom Resource Definitions
Galaxy-Operator currently provides three different kinds of [Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/#custom-resources): Galaxy, Galaxy Backup and Galaxy Restore.

### Galaxy (galaxies.galaxy.ansible.com)
Manages the Galaxy application and its deployments, services, etc.

### Galaxy Backup (galaxybackups.galaxy.ansible.com)
Manages Galaxy backups through the following ansible role

### Galaxy Restore (galaxyrestores.galaxy.ansible.com)
Manages the restoration of a Galaxy backup through the following ansible role

# Galaxy
With Galaxy you can:

* Host your Ansible Collections
* Host execution environment (EE) and decision environments (DE)
* Locally mirror all of, or a subset of your collections, execution environments, and decision environments
* Manage content from multiple sources in one place
* Promote content through different repos in an organized way

If you have dozens, hundreds, or thousands of collections and execution environments and need a better way to manage them, Galaxy can help.

Galaxy is completely free and open-source!

* Source: [github.com/ansible/galaxy_ng](https://github.com/ansible/galaxy_ng)
* Source (ui): [github.com/ansible/ansible-hub-ui](https://github.com/ansible/ansible-hub-ui)
* Galaxy Bugs: [github.com/ansible/galaxy_ng/issues](https://github.com/ansible/galaxy_ng/issues)

## Get Help

Documentation: [galaxy-operator.readthedocs.io](https://galaxy-operator.readthedocs.io)

Forum: [forum.ansible.com](https://forum.ansible.com/)

Issues: [github.com/ansible/galaxy-operator/issues](https://github.com/ansible/galaxy-operator/issues)