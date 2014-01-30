http://kuhnza.com/2013/03/27/docker-makes-creating-secure-sandboxes-easier-than-ever/

Process:

Vagrantfile provides the top-level virtual machine. From there, docker is
used to create containers that the various services run in.

There is a "shipyard" docker instance that provides shipyard.

mail2json-smtp is it's own project, because that allows for creation of a
"trusted" automatically built docker image on the docker index (silarsis/mail2json-smtp).
All the other docker images are currently loaded from various pre-built third
party images off the index, but can be reverted to being github repos if we
need to modify them.

