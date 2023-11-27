# Use the specified Ubuntu version as a build argument
ARG BASE_IMAGE_TAG=latest

# Stage 1: Build stage
FROM ubuntu:latest AS builder

ARG ROOT_LDAP_PASSWORD="rootpw"
ARG SUFFIX_ADMIN_LDAP_PASSWORD="adminpw"
ARG NUM_PEOPLE=100

# Install required packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils curl jq

RUN mkdir /scripts

# Apply additional configurations
COPY generate_backend.sh /scripts/
COPY generate_data.sh /scripts/

RUN /scripts/generate_backend.sh -d example.com -p $ROOT_LDAP_PASSWORD > /tmp/backend.ldif
RUN /scripts/generate_data.sh -a $SUFFIX_ADMIN_LDAP_PASSWORD -d "example.com" -u "ou=people" -n $NUM_PEOPLE > /tmp/data.ldif

# Copy prepare.sh script
COPY prepare.sh /prepare.sh
RUN chmod +x /prepare.sh

# Start slapd and apply configurations during container startup
RUN /prepare.sh

# Stage 2: Final stage
FROM srnjak/srnjak-dev-playground-mail:$BASE_IMAGE_TAG

# Install slapd in the final image
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils

# Copy the relevant directories from the builder stage
COPY --from=builder /etc/ldap /etc/ldap
COPY --from=builder /var/lib/ldap /var/lib/ldap
COPY --from=builder /tmp /tmp

# Expose LDAP port
EXPOSE 389

# Copy the modified start.sh script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Execute the modified start.sh script as the entry point
ENTRYPOINT ["/start.sh"]
