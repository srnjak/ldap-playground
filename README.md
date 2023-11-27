# LDAP Testing Playground Docker Setup

This Dockerfile is tailored for creating a test environment for LDAP commands and scripts. It sets up an OpenLDAP server with initial configurations, allowing you to interactively test LDAP functionality.

## Building the Docker Image

To build the Docker image, use the following command:

```bash
docker build -t ldap-playground .
```

## Running the Docker Container

Run the container interactively with bash for LDAP testing:

```bash
docker run -it -p 389:389 --name ldap-container ldap-playground
```

## Configuration

### Environment Variables

- **ROOT_LDAP_PASSWORD:** Password for the LDAP root user.
- **SUFFIX_ADMIN_LDAP_PASSWORD:** Password for the admin user suffix.
- **NUM_PEOPLE:** Number of people to generate in the LDAP directory.

### Scripts

- **generate_backend.sh:** Generates LDAP backend configuration.
- **generate_data.sh:** Generates sample data for LDAP.
- **prepare.sh:** Starts slapd and applies configurations during container startup.

## Exposed Ports

- **389:** LDAP port.

## Customization

Feel free to modify the Dockerfile and associated scripts to suit your specific LDAP testing requirements.

## Docker Hub
The Docker image is available on Docker Hub:
- [srnjak/srnjak-dev-playground](https://hub.docker.com/r/srnjak/ldap-playground)

## License

This project is licensed under the [MIT License](LICENSE).