#!/bin/bash
set -e

# Set defaults
: ${KALABOX_UID:='1000'}
: ${KALABOX_GID:='50'}

# Correctly map users
echo "Remapping permissions for VB sharing compat..."
usermod -u "$KALABOX_UID" www-data
groupmod -g "$KALABOX_GID" www-data || usermod -G staff www-data

# Make sure we have correct ownership
chown -Rf www-data:www-data /code

# Run the NGINX
nginx "$@"
