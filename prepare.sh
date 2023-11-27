#!/bin/bash

service slapd start
ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/backend.ldif
slapadd -l /tmp/data.ldif
service slapd stop
