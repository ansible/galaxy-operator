![](images/logo_large.svg)

# Galaxy-Operator
This is the official operator for deploying [Galaxy-NG](https://github.com/ansible/galaxy_ng).  This project was formerly maintained under the ansible branch of the [pulp-operator repo](https://github.com/pulp/pulp-operator)

Galaxy-Operator uses the [Ansible Operator SDK](https://sdk.operatorframework.io/docs/building-operators/ansible/).

# Images
Galaxy-Operator images are automatically built by our CI and [hosted on quay.io](https://quay.io/repository/ansible/galaxy-operator).

Note that Galaxy-Operator requires three separate images (the operator, the main galaxy server, and the web interface):

|           | Operator | Main | Web |
| --------- | -------- | ---- | --- |
| **Image** | [galaxy-operator](https://quay.io/repository/ansible/galaxy-operator?tab=tags) |[galaxy-ng](https://quay.io/repository/ansible/galaxy-ng?tab=tags) | [galaxy-ui](https://quay.io/repository/ansible/galaxy-ui?tab=tags) |

# Galaxy
With Galaxy you can:

* Host your Ansible Collections
* Host execution environment (EE) and decision environments (DE)
* Locally mirror all of, or a subset of your collections, execution environments, and decision environments
* Manage content from multiple sources in one place
* Promote content through different repos in an organized way

If you have dozens, hundreds, or thousands of collections and execution environments and need a better way to manage them, Galaxy can help.

Galaxy is completely free and open-source!

* License: GPLv2+
* Documentation is currently in markdown files in this repo, but eventually we will have a docsite.
* Source: [https://github.com/ansible/galaxy_ng](https://github.com/ansible/galaxy_ng)
* Galaxy Bugs: [https://github.com/ansible/galaxy_ng/issues](https://github.com/ansible/galaxy_ng/issues)
* Galaxy-Operator Bugs: [https://github.com/ansible/galaxy-operator/issues](https://github.com/ansible/galaxy-operator/issues)

## Custom Resource Definitions
Galaxy-Operator currently provides three different kinds of [Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/#custom-resources): Galaxy, Galaxy Backup and Galaxy Restore.

### Galaxy (galaxies.galaxy.ansible.com)
Manages the Galaxy application and its deployments, services, etc.

### Galaxy Backup (galaxybackups.galaxy.ansible.com)
Manages Galaxy backups through the following ansible role:

### Galaxy Restore (galaxyrestores.galaxy.ansible.com)
Manages the restoration of a Galaxy backup through the following ansible role:

## Get Help

Documentation: [https://ansible.readthedocs.io/projects/galaxy-operator](https://ansible.readthedocs.io/projects/galaxy-operator)

Forum: [https://forum.ansible.com](https://forum.ansible.com/) - Create a topic with the `galaxy-ng` tag.

Issue Tracker: [https://github.com/ansible/galaxy-operator/issues](https://github.com/ansible/galaxy-operator/issues)