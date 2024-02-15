![Galaxy Operator CI](https://github.com/ansible/galaxy-operator/workflows/Galaxy%20Operator%20CI/badge.svg)

# Galaxy
Galaxy is a web application for managing repositories of anisble content such as collections, roles, and execution environments, and can be used to make them available to a large number of consumers.

This is an ansible operator which used to be maintained out of the [pulp-operator repo](https://github.com/pulp/pulp-operator). We have decided to have a dedicated codebase for the Galaxy Operator using the ansible operator sdk. 

With Galaxy you can:

* Host your Ansible Collections
* Host execution environment (EE) and decision environments (DE)
* Locally mirror all of, or a subset of your collections, execution environments, and decision environments
* Manage content from multiple sources in one place
* Promote content through different repos in an organized way

If you have dozens, hundreds, or thousands of collections and execution environmetns and need a better way to manage them, Galaxy can help.

Galaxy is completely free and open-source!

* License: GPLv2+
* Documentation is currently in markdown files in this repo, but eventually we will have a docsite.
* Source: [https://github.com/ansible/galaxy_ng](https://github.com/ansible/galaxy_ng)
* Galaxy Bugs: [https://github.com/ansible/galaxy_ng/issues](https://github.com/ansible/galaxy_ng/issues)
* Galaxy Operator Bugs: [https://github.com/ansible/galaxy-operator/issues](https://github.com/ansible/galaxy-operator/issues)

For more information, check out the project website: [https://pulpproject.org](https://pulpproject.org)


## Galaxy Operator
An [Ansible Operator](https://www.ansible.com/blog/ansible-operator) for Galaxy.

Galaxy Operator is under active development, with the goal to provide a scalable and robust cluster for Galaxy.

Note that Galaxy Operator works with three different types of service containers (the operator itself, the main service and the web service):

|           | Operator | Main | Web |
| --------- | -------- | ---- | --- |
| **Image** | [pulp-operator](https://quay.io/repository/pulp/pulp-operator?tab=tags) |[pulp](https://quay.io/repository/pulp/pulp?tab=tags) | [pulp-web](https://quay.io/repository/pulp/pulp-web?tab=tags) |
| **Image** | [pulp-operator](https://quay.io/repository/pulp/pulp-operator?tab=tags) |[galaxy](https://quay.io/repository/pulp/galaxy?tab=tags) | [galaxy-web](https://quay.io/repository/pulp/galaxy-web?tab=tags) |

<br>Galaxy Operator is manually built and [hosted on quay.io](https://quay.io/repository/pulp/pulp-operator). Read more about the container images [here](https://docs.pulpproject.org/pulp_operator/container/).

## Custom Resource Definitions
Galaxy Operator currently provides three different kinds of [Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/#custom-resources): Galaxy, Galaxy Backup and Galaxy Restore.

### Galaxy
Manages the Galaxy application and its deployments, services, etc. Through the following ansible roles:

* [API](https://docs.pulpproject.org/pulp_operator/roles/pulp-api/)
* [Content](https://docs.pulpproject.org/pulp_operator/roles/pulp-content/)
* [Routes](https://docs.pulpproject.org/pulp_operator/roles/pulp-routes/)
* [Worker](https://docs.pulpproject.org/pulp_operator/roles/pulp-worker/)
* [Web](https://docs.pulpproject.org/pulp_operator/roles/pulp-web/)
* [Status](https://docs.pulpproject.org/pulp_operator/roles/pulp-status/)
* [Postgres](https://docs.pulpproject.org/pulp_operator/roles/postgres/)
* [Redis](https://docs.pulpproject.org/pulp_operator/roles/redis/)

### Galaxy Backup
Manages pulp backup through the following ansible role:

* [Backup](https://docs.pulpproject.org/pulp_operator/roles/backup/)

### Galaxy Restore
Manages the restoration of a pulp backup through the following ansible role:

* [Restore](https://docs.pulpproject.org/pulp_operator/roles/restore/)

## Get Help

Documentation: [https:/github.com/ansible/galaxy-operator](https:/github.com/ansible/galaxy-operator)

Issue Tracker: [https:/github.com/ansible/galaxy-operator/issues](https:/github.com/ansible/galaxy-operator/issues)

Forum: [https://forum.ansible.com](https://forum.ansible.com/) - Create a topic with the `galaxy-ng` tag.

## Maintainers Docs

Maintainers of this repo need to carry out releases, triage issues, etc. There are docs for those types of administrative tasks in the `docs/maintainer/` directory.

To release the EDA Server Operator, see these docs:
* [Release Operator](./docs/maintainers/release.md)
