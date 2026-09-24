# Containers

## Galaxy-NG

An all-in-one [galaxy](https://github.com/ansible/galaxy_ng) image that can assume each of the following types of service:

- **pulpcore-api** - serves the Galaxy (v3) API. The number of instances of this service should be scaled as demand requires.  _Administrators and users of all of the APIs put demand on this service_.

- **pulpcore-content** - serves content to clients. pulpcore-api redirects clients to pulpcore-content to download content. When content is being mirrored from a remote source, this service can download that content and stream it to the client the first time the content is requested. The number of instances of this service should be scaled as demand requires. _Content consumers put demands on this service_.

- **pulpcore-worker** - performs syncing, importing of content, and other asynchronous operations that require resource locking. The number of instances of this service should be scaled as demand requires. _Administrators and content importers put demands on this service_.

[https://quay.io/repository/ansible/galaxy-ng?tab=tags](https://quay.io/repository/ansible/galaxy-ng?tab=tags)


## Galaxy-UI

An Nginx image with galaxy specific configuration.

### Tags


[https://quay.io/repository/ansible/galaxy-ui?tab=tags](https://quay.io/repository/ansible/galaxy-ui?tab=tags)


## Galaxy-Operator

[Ansible Operator](https://www.ansible.com/blog/ansible-operator) image, with the following ansible roles:

* [Galaxy API](roles/galaxy-api.md)
* [Galaxy Content](roles/galaxy-content.md)
* [Galaxy Route](roles/galaxy-route.md)
* [Galaxy Worker](roles/galaxy-worker.md)
* [Galaxy Web](roles/galaxy-web.md)
* [Galaxy Status](roles/galaxy-status.md)
* [Galaxy Backup](roles/galaxybackup.md)
* [Galaxy Restore](roles/galaxyrestore.md)
* [Postgres](roles/postgres.md)
* [Redis](roles/redis.md)

### Tags

* `latest`: Latest released version [galaxy-operator](https://github.com/ansible/galaxy-operator).
* `main`:  Built from main (development) branch.

[https://quay.io/repository/ansible/galaxy-operator?tab=tags](https://quay.io/repository/ansible/galaxy-operator?tab=tags)