[<img src="https://github.com/user-attachments/assets/0d406c41-ff61-41d7-a8de-249e9e652946" alt="https://sqlite.ai" width="110"/>](https://sqlite.ai)

# SQLite AI Search Action
    
Index your documentation files with SQLite AI-powered embeddings for intelligent search capabilities.

[![Test](https://github.com/sqliteai/sqlite-aisearch-action/actions/workflows/test.yaml/badge.svg?branch=main)](https://github.com/sqliteai/sqlite-aisearch-action/actions/workflows/test.yaml)
[![GitHub Release](https://img.shields.io/github/v/release/sqliteai/sqlite-aisearch-action?label=Version)](https://github.com/sqliteai/sqlite-aisearch-action/releases/latest)

## Overview

The SQLite AI Search Action automatically processes your documentation files and creates an AI-powered searchable database on SQLite Cloud. This action uses both embeddings to understand document content semantically and traditional full-text search, enabling more intelligent and contextual search results.

This action uses [sqlite-rag](https://github.com/sqliteai/sqlite-rag).

## How it works

1. **Downloads AI Model**: Retrieves the specified Hugging Face model to generate embeddings for semantic search
2. **Processes Documents**: Recursively scans and parses all documentation files in your repository  
3. **Creates Dual Index**: Generates both AI embeddings and traditional full-text search indices for comprehensive search capabilities
4. **Builds Database**: Creates a SQLite database containing documents, embeddings, and search indices
5. **Uploads to SQLite Cloud**: Transfers the complete database to your SQLite Cloud project
6. **Integrates with Edge Function**: Works out-of-the-box with the predefined SQLite Cloud Edge Function template ([aisearch-docs.js](search_edge_function_template/aisearch-docs.js)) for instant search functionality

> **Note**: the SQLite Cloud Search Edge Function supports only the default model. Do not change the model settings if you want to use our search edge function.

## Usage

### Setup your workflow

1. **Get your Connection String**: Ensure you have a project on [SQLite Cloud dashboard](https://dashboard.sqlitecloud.io). If not, sign up to [SQLite AI](https://sqlite.ai) to create one for free.

2. **Set GitHub Secret**: Add your connection string as `SQLITECLOUD_CONNECTION_STRING` in your repository secrets.

3. **Add to Workflow**: Create or update your GitHub workflow:

```yaml
name: AI Search Index

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  build-search:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build AI Search Database
        uses: sqliteai/sqlite-aisearch-action@v1
        with:
          connection_string: ${{ secrets.SQLITECLOUD_CONNECTION_STRING }}
          base_url: https://docs.yoursite.com
          database_name: aidocs_search.db
          source_files: ./path/to/documents
```

### Create the Search Edge Function

To enable search functionality on your indexed database, you need to create an Edge Function using the provided template:

1. Access your dashboard on https://dashboard.sqlitecloud.io
2. Enter the same project where the created database has been uploaded
3. Go to the **Edge Functions** section
4. Create a new `Javascript Function` and copy and paste the code from [aisearch-docs.js](search_edge_function_template/aisearch-docs.js) in the editor
5. Deploy and test

#### How to perform a search

1. Go in the **Detail** in the Edge Function panel and copy the **Function URL**
2. Execute a GET request and send a URL-econded query as `query` parameter. 
    
    Example: `GET
	    https://myproject.cloud/v2/functions/aisearch-docs?query=what%27s+Offsync%3F`

Response example:
```json
{
  "data": {
    "search": [
      {
        "id": "c41a6c2e-34e9-4e8e-92b9-41b8065047c7",
        "uri": "docs/sqlite-cloud/sdks/php/methods.mdx",
        "metadata": "{\"base_url\": \"https://docs.sqlitecloud.io/docs/\"}",
        "snippet": "---\ntitle: OffSync\ndescription: Enable local-first applications with automatic data synchronization between edge devices and SQLite Cloud...",
        "vec_rank": 1,
        "fts_rank": null,
        "combined_rank": 0.0163934426229508,
        "vec_distance": 0.581515073776245,
        "fts_score": null
      },
      ...
    ]
  }
}
```

## Support

- 📖 [SQLite Cloud Documentation](https://docs.sqlitecloud.io)
- 💬 [Community Support](https://github.com/orgs/sqlitecloud/discussions)