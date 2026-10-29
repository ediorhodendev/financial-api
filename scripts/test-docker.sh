#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Isolated project/volume and ports: never remove the evaluator's local database.
export API_PORT=15080
export POSTGRES_PORT=15432
export POSTGRES_PASSWORD=ci-docker-demo-only
cleanup() { docker compose -p financial-docker-ci down -v; }
trap cleanup EXIT
docker compose -p financial-docker-ci up --build -d
python3 - <<'PY'
import json, time, urllib.request, urllib.error
base = 'http://localhost:15080'
for attempt in range(60):
    try:
        with urllib.request.urlopen(base + '/health/ready', timeout=2) as r:
            if r.status == 200: break
    except (OSError, urllib.error.URLError): pass
    time.sleep(1)
else: raise SystemExit('Docker API did not become ready')
def request(path, data=None, token=None, key=None):
    headers = {'Content-Type': 'application/json'}
    if token: headers['Authorization'] = 'Bearer ' + token
    if key: headers['Idempotency-Key'] = key
    req = urllib.request.Request(base + path, data=json.dumps(data).encode() if data is not None else None, headers=headers)
    with urllib.request.urlopen(req, timeout=15) as r: return r.status, json.load(r)
_, demo = request('/demo/access', {})
account = demo['accountId']; token = demo['operatorToken']
path = '/api/accounts/' + account
status, credit = request(path + '/movements', {'type':'Credit','amount':100}, token, 'docker-credit')
assert status == 201
status, replay = request(path + '/movements', {'type':'Credit','amount':100}, token, 'docker-credit')
assert status == 200 and credit['id'] == replay['id']
status, debit = request(path + '/movements', {'type':'Debit','amount':30}, token, 'docker-debit')
assert status == 201
_, balance = request(path + '/balance', token=token)
assert balance['balance'] == 70, balance
print('Docker smoke passed: migrations, demo JWT, credit, idempotency, debit, balance 70.')
PY
