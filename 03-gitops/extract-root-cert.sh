#!/bin/bash

# Extract the root CA certificate from the cert-manager secret
NAMESPACE="cert-manager"
SECRET_NAME="ingress-tls"
OUTPUT_PATH="local-cluster-root-ca.crt"

mkdir -p $(dirname "$OUTPUT_PATH")

# Try to get ca.crt from the secret
CA_CRT=$(kubectl -n $NAMESPACE get secret $SECRET_NAME -o jsonpath='{.data.ca\.crt}' 2>/dev/null)

if [ -n "$CA_CRT" ]; then
  echo "$CA_CRT" | base64 -d > "$OUTPUT_PATH"
  echo "✅ CA certificate saved to $OUTPUT_PATH"
else
  echo "ℹ️ ca.crt not found in secret, falling back to tls.crt"
  TLS_CRT=$(kubectl -n $NAMESPACE get secret $SECRET_NAME -o jsonpath='{.data.tls\.crt}' 2>/dev/null)
  if [ -n "$TLS_CRT" ]; then
    echo "$TLS_CRT" | base64 -d > "$OUTPUT_PATH"
    echo "✅ TLS certificate (self-signed) saved to $OUTPUT_PATH"
  else
    echo "❌ Neither ca.crt nor tls.crt found in secret $SECRET_NAME"
    exit 1
  fi
fi