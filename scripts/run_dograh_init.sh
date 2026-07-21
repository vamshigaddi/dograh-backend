#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${DOGRAH_INIT_WORKSPACE_DIR:-/workspace}"
OUTPUT_ROOT="${DOGRAH_INIT_OUTPUT_ROOT:-/generated}"
NGINX_OUTPUT_DIR="$OUTPUT_ROOT/nginx"
COTURN_OUTPUT_DIR="$OUTPUT_ROOT/coturn"
CERTS_DIR="${DOGRAH_INIT_CERTS_DIR:-/certs}"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/lib/setup_common.sh"

DOGRAH_DEPLOY_PROJECT_DIR="$WORKSPACE_DIR"

mkdir -p "$NGINX_OUTPUT_DIR" "$COTURN_OUTPUT_DIR"

if [[ "${ENVIRONMENT:-local}" == "production" ]]; then
    dograh_validate_remote_runtime_env
    mkdir -p "$CERTS_DIR"
    if [[ ! -f "$CERTS_DIR/local.crt" || ! -f "$CERTS_DIR/local.key" ]]; then
        dograh_info "Generating self-signed SSL certificates in $CERTS_DIR..."
        openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
          -keyout "$CERTS_DIR/local.key" \
          -out "$CERTS_DIR/local.crt" \
          -subj "/CN=${PUBLIC_HOST:-localhost}"
    fi

    export TURN_EXTERNAL_IP="$SERVER_IP"
    dograh_render_remote_nginx_conf "$WORKSPACE_DIR" "$NGINX_OUTPUT_DIR/default.conf"
    dograh_render_remote_turn_conf "$WORKSPACE_DIR" "$COTURN_OUTPUT_DIR/turnserver.conf"
    dograh_success "✓ dograh-init rendered remote nginx and coturn config"
    exit 0
fi

if [[ -n "${TURN_SECRET:-}" && -n "${TURN_HOST:-}" ]]; then
    export TURN_EXTERNAL_IP="$TURN_HOST"
    dograh_render_remote_turn_conf "$WORKSPACE_DIR" "$COTURN_OUTPUT_DIR/turnserver.conf"
    dograh_success "✓ dograh-init rendered local TURN config"
    exit 0
fi

dograh_success "✓ dograh-init no-op for current profile"
