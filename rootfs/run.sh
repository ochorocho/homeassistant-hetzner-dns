#!/usr/bin/with-contenv bashio
# vim: ft=bash
# shellcheck shell=bash
# ==============================================================================
# Runs hetzner-dns-update.sh
# ==============================================================================

bashio::log.info "Starting Hetzner DNS service..."

# Start DNS service
. /hetzner-dns-update.sh
