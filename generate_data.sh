#!/bin/bash

# Default values
admin_password=""
domain=""
users_dn=""
num_persons=""

# Function to display script usage
printUsage() {
  echo "Usage: $0 -a <adminPassword> -d <domain> -u <usersDN> -n <num_persons>"
  echo ""
  echo "Options:"
  echo "  -a, --admin-password    Admin password for LDAP domain suffix"
  echo "  -d, --domain            Domain name (e.g., example.com)"
  echo "  -u, --users-dn          Users DN for the LDAP directory (e.g., ou=people)"
  echo "  -n, --num-persons       Number of persons to generate"
  echo "  -h, --help              Display this help message"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -a|--admin-password)
      admin_password="$2"
      shift 2
      ;;
    -d|--domain)
      domain="$2"
      shift 2
      ;;
    -u|--users-dn)
      users_dn="$2"
      shift 2
      ;;
    -n|--num-persons)
      num_persons="$2"
      shift 2
      ;;
    -h|--help)
      printUsage
      exit 0
      ;;
    *)
      echo "Invalid argument: $1"
      printUsage
      exit 1
      ;;
  esac
done

# Validate required arguments
if [ -z "$admin_password" ] || [ -z "$domain" ] || [ -z "$users_dn" ] || [ -z "$num_persons" ]; then
  echo "Error: Missing required arguments"
  printUsage
  exit 1
fi

# Extract base domain
domain_base=$(echo $domain | cut -d'.' -f1)

# Generate Root DN from the domain
root_dn="dc=$(echo $domain | sed 's/\./,dc=/g')"

# Generate hashed admin password using slappasswd
hashed_admin_password=$(slappasswd -s "$admin_password")

cat << EOF
dn: $root_dn
objectClass: top
objectClass: dcObject
objectClass: organization
o: Example Organization
dc: $domain_base

dn: cn=admin,$root_dn
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
userPassword: $hashed_admin_password

dn: $users_dn,$root_dn
objectClass: organizationalUnit
${users_dn/ou=/ou: }

EOF

for ((i=1; i<=num_persons; i++)); do
    # Fetch random user data from the API
    user_data=$(curl -s https://randomuser.me/api/)

    # Extract username from the JSON response
    username=$(echo "$user_data" | jq -r '.results[0].login.username')

    # Extract name and surname from the JSON response
    name=$(echo "$user_data" | jq -r '.results[0].name.first')
    surname=$(echo "$user_data" | jq -r '.results[0].name.last')

    # Print LDIF entry
    cat << EOF
dn: cn=$username,$users_dn,$root_dn
objectClass: inetOrgPerson
cn: $username
sn: $surname
givenName: $name

EOF
done
