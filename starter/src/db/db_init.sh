#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

export OPENSEARCH_HOST=${DB_URL}
echo OPENSEARCH_HOST=$OPENSEARCH_HOST

curl -0 -v -X PUT https://${OPENSEARCH_HOST}:9200/oic \
-H 'Content-Type: application/json; charset=utf-8' \
--data-binary @- << EOF
{
  "settings": {
    "index": {
       "knn": true
    }
  },
  "mappings": {
    "properties": {
      "applicationName": {
        "type": "text"
      },
      "author": {
        "type": "text"
      },
      "translation": {
        "type": "text"
      },
      "cohere_embed": {
        "type": "knn_vector",
        "dimension": 1024,
        "method": {
            "name": "hnsw",
            "space_type": "l2",
            "engine": "lucene",
            "parameters": {
              "ef_construction": 128,
              "m": 24
            }
        }        
      },
      "content": {
        "type": "text"
      },
      "contentType": {
        "type": "keyword"
      },
      "creationDate": {
        "type": "date"
      },
      "date": {
        "type": "date"
      },
      "modified": {
        "type": "date"
      },
      "other1": {
        "type": "text"
      },
      "other2": {
        "type": "text"
      },
      "other3": {
        "type": "text"
      },
      "parsedBy": {
        "type": "text"
      },
      "filename": {
        "type": "keyword"
      },
      "path": {
        "type": "keyword"
      },
      "publisher": {
        "type": "text"
      },
      "region": {
        "type": "keyword"
      },
      "context": {
        "type": "text"
      }
    }
  }
}
EOF

curl https://${OPENSEARCH_HOST}:9200/oic/_search?size=1000&scroll=1m&pretty=true
