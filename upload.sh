#!/bin/bash


# === Inputs ===
# CONNECTION_STRING: The SQLite Cloud project connection string.
# DATABASE: The name of the database to use on SQLite Cloud.
# DATABASE_PATH: The path to the SQLite database file to upload.

echo "Database: $DATABASE"



if [[ ! "${CONNECTION_STRING}" =~ ^sqlitecloud:// ]]; then
    echo "${CONNECTION_STRING} incorrect project connection string"
    exit 1
fi

if [[ -z "${DATABASE}" ]]; then
    echo "database input is empty"
    exit 1
fi

API_BASE="https:$(echo ${CONNECTION_STRING} | awk -F ':' '{print $2}')"
# Extract the apikey from the project string
API_KEY=$(echo "${CONNECTION_STRING}" | awk -F 'apikey=' '{print $2}' | awk -F '&' '{print $1}')

if [[ -z "${API_KEY}" ]]; then
    echo "API key not found in project connection string"
    exit 1
fi

# --- 1. Get upload URL from v2/storage/databases/singlepart ---
STORAGE_URL="${API_BASE}/v2/storage/databases/singlepart"
STORAGE_RES=$(curl "${STORAGE_URL}" \
    -H "Authorization: Bearer ${API_KEY}" \
    -H 'accept: application/json')

# --- 2. Extract data.url from JSON response ---
if command -v jq >/dev/null 2>&1; then
    UPLOAD_URL=$(echo "${STORAGE_RES}" | jq -r '.data.url')
fi

if [[ -z "${UPLOAD_URL}" || "${UPLOAD_URL}" == "null" ]]; then
    echo "Failed to get upload URL: ${STORAGE_RES}"
    exit 1
fi

# --- 3. Upload the database file ---
PUT_RES=$(curl -s -X PUT --data-binary @"${DATABASE_PATH}" \
    -H 'Content-Type: application/octet-stream' \
    "${UPLOAD_URL}")
if [[ $? -ne 0 ]]; then
    echo "Failed to upload database file"
    exit 1
fi

# --- 4. Add or replace the database via Weblite ---
PATCH_URL="${API_BASE}/v2/weblite/${DATABASE}"
PATCH_BODY="{\"location\":\"${UPLOAD_URL}\"}"
PATCH_RES=$(curl --compressed -s -X PATCH "${PATCH_URL}" \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer ${API_KEY}" \
    -H 'accept: application/json' \
    -d "${PATCH_BODY}")

echo "${PATCH_RES}"
if [[ "${PATCH_RES}" =~ error ]]; then
    echo "Error updating SQLite Cloud database: ${PATCH_RES}"
    exit 1
fi

echo "Database uploaded successfully."
