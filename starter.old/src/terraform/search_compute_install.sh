echo OIC_HOST=${OIC_HOST}
# echo OIC_CLIENT_ID=${OIC_CLIENT_ID} 
# echo OIC_CLIENT_SECRET=${OIC_CLIENT_SECRET}
echo OPENSEARCH_HOST=${OPENSEARCH_HOST}

export OIC_NAME=`echo $OIC_HOST | sed 's#https://##' | sed 's/\..*//'`
export OIC_DOMAIN=`echo $OIC_HOST | sed 's/.*integration\.//'`

echo OIC_NAME=$OIC_NAME
echo OIC_DOMAIN=$OIC_DOMAIN
echo IDCS_HOST=$IDCS_HOST


# curl -X DELETE https://${OPENSEARCH_HOST}:9200/oic

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
        "type": "text",
        "enabled": false
      }
    }
  }
}
EOF

