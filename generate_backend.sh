#!/bin/bash

# Default values
domain=""
root_pw=""

# Function to display script usage
printUsage() {
  echo "Usage: $0 -d <domain> -p <rootPW>"
  echo ""
  echo "Options:"
  echo "  -d, --domain        Domain name (e.g., example.com)"
  echo "  -p, --root-pw       Root password for LDAP directory"
  echo "  -h, --help          Display this help message"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--domain)
      domain="$2"
      shift 2
      ;;
    -p|--root-pw)
      root_pw="$2"
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
if [ -z "$domain" ] || [ -z "$root_pw" ]; then
  echo "Error: Missing required arguments"
  printUsage
  exit 1
fi

# Generate suffix from the domain
suffix="dc=$(echo $domain | sed 's/\./,dc=/g')"

# Construct root DN
root_dn="cn=admin,$suffix"

# Generate hashed root password using slappasswd
hashed_root_pw=$(slappasswd -s "$root_pw")

cat << EOF
dn: olcDatabase={1}mdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: $suffix

dn: olcDatabase={1}mdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: $root_dn

dn: olcDatabase={1}mdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: $hashed_root_pw
EOF
