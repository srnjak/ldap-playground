#!/bin/bash

# Start slapd
slapd -d 1 -h "ldap:///" &

# Execute the entry point of the base image
exec /entrypoint.sh "$@"
