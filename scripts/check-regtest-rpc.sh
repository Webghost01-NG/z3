#!/usr/bin/env bash
set -euo pipefail

RPC_URL="${Z3_REGTEST_RPC_URL:-http://127.0.0.1:29232}"

echo "Checking Zebra regtest RPC: $RPC_URL"

response=$(curl --fail --silent --show-error \
  --connect-timeout 5 \
  --max-time 15 \
  -H 'Content-Type: application/json' \
  --data-binary \
  '{"jsonrpc":"2.0","id":1,"method":"getblockcount","params":[]}' \
  "$RPC_URL")

RPC_RESPONSE="$response" python3 - <<'PY'
import json
import os
import sys

data = json.loads(os.environ["RPC_RESPONSE"])

if data.get("error") is not None:
    sys.exit(f"RPC error: {data['error']}")

height = data.get("result")

if not isinstance(height, int) or isinstance(height, bool):
    sys.exit("Unexpected RPC response")

print("Zebra RPC: OK")
print(f"Current block height: {height}")
PY
