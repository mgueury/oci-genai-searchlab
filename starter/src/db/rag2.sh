# See https://docs.oracle.com/en-us/iaas/Content/search-opensearch/Concepts/conversationalsearchwalkthrough.htm
export TF_VAR_compartment_ocid=`curl -s -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/ | jq -r .compartmentId`

curl -0 -v -X PUT https://${OPENSEARCH_HOST}:9200/_cluster/settings \
-H 'Content-Type: application/json; charset=utf-8' \
--data-binary @- << EOF
{
  "persistent": {
    "plugins": {
      "ml_commons": {
        "only_run_on_ml_node": "false",
        "model_access_control_enabled": "true",
        "native_memory_threshold": "99",
        "rag_pipeline_feature_enabled": "true",
        "memory_feature_enabled": "true",
        "allow_registering_model_via_local_file": "true",
        "allow_registering_model_via_url": "true",
        "model_auto_redeploy.enable":"true",
        "model_auto_redeploy.lifetime_retry_times": 10
      }
    }
  }
}
EOF

curl -0 -v -X POST https://${OPENSEARCH_HOST}:9200/_plugins/_ml/model_groups/_register \
-o 1_register.json -H 'Content-Type: application/json; charset=utf-8' \
--data-binary @- << EOF
{
   "name": "public OCI GenAI model group",
   "description": "OCI GenAI group for remote models"
}
EOF

export MODEL_GROUP_ID=`cat 1_register.json | jq -r .model_group_id`
echo "MODEL_GROUP_ID=$MODEL_GROUP_ID"

curl -X POST https://${OPENSEARCH_HOST}:9200/_plugins/_ml/connectors/_create \
-o 2_embed.json -H 'Content-Type: application/json; charset=utf-8' \
--data-binary @- << EOF
{
  "name": "OCI GenAI Chat Connector cohere-embed-v5",
  "description": "The connector to public Cohere model service for embed",
  "version": "2",
  "protocol": "oci_sigv1",
 
    "parameters": {
      "endpoint": "inference.generativeai.us-chicago-1.oci.oraclecloud.com",
      "auth_type": "resource_principal", 
      "model": "cohere.embed-english-v3.0",
      "input_type":"search_document",
      "truncate": "END"
    },
 
     "credential": {
     },
     "actions": [
         {
             "action_type": "predict",
             "method":"POST",
             "url": "https://\${parameters.endpoint}/20231130/actions/embedText",
             "request_body": "{ \"inputs\": [\"\${passage_text}\"], \"truncate\": \"\${parameters.truncate}\" ,\"compartmentId\": \"${TF_VAR_compartment_ocid}\", \"servingMode\": { \"modelId\": \"\${parameters.model}\", \"servingType\": \"ON_DEMAND\" } }",
            "pre_process_function": "connector.pre_process.cohere.embedding",
            "post_process_function": "connector.post_process.cohere.embedding"
         }
     ]
}
EOF
export CONNECTOR_ID=`cat 2_embed.json | jq -r .connector_id`
echo "CONNECTOR_ID=$CONNECTOR_ID"

curl -0 -v -X POST https://${OPENSEARCH_HOST}:9200/_plugins/_ml/models/_register \
-o 3_register.json -H 'Content-Type: application/json; charset=utf-8' \
--data-binary @- << EOF
{
   "name": "oci-genai-embed",
   "function_name": "remote",
   "model_group_id": "${MODEL_GROUP_ID}",
   "description": "test semantic",
   "connector_id": "${CONNECTOR_ID}"
}
EOF

export MODEL_ID=`cat 3_register.json | jq -r .model_id`
echo "MODEL_ID=$MODEL_ID"

curl -0 -v -X POST https://${OPENSEARCH_HOST}:9200/_plugins/_ml/models/${MODEL_ID}/_deploy \
-o 4_deploy.json -H 'Content-Type: application/json; charset=utf-8' 
cat 4_deploy.json

curl -0 -v -X PUT https://${OPENSEARCH_HOST}:9200/_search/pipeline/demo_rag_pipeline \
-o 5_pipeline.json -H 'Content-Type: application/json; charset=utf-8' \
--data-binary @- << EOF
{
  "response_processors": [
    {
      "retrieval_augmented_generation": {
        "tag": "genai_conversational_search_demo",
        "description": "Demo pipeline for conversational search Using Genai Connector",
        "model_id": "${MODEL_ID}",
        "context_field_list": ["text"],
        "system_prompt":"helpfull assistant",
        "user_instructions":"generate concise answer"
      }
    }
  ]
}
EOF
cat 5_pipeline.json

curl -X PUT https://${OPENSEARCH_HOST}:9200/_ingest/pipeline/search-pipeline \
-o 6_pipeline.json -H 'Content-Type: application/json; charset=utf-8' \
--data-binary @- << EOF
{
  "description": "pipeline for RAG demo index",
  "processors" : [
    {
      "text_embedding": {
        "model_id": "${MODEL_ID}",
        "field_map": {
           "content": "cohere_embed"
        }
      }
    }
  ]
}
EOF
cat 6_pipeline.json

curl -X DELETE https://${OPENSEARCH_HOST}:9200/oic

curl -0 -v -X PUT https://${OPENSEARCH_HOST}:9200/oic \
-o 7_index.json -H 'Content-Type: application/json; charset=utf-8' \
--data-binary @- << EOF
{
  "settings": {
    "index": {
       "knn": true,
        "default_pipeline": "search-pipeline"
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

# Create a pipeline for Hybrid Queries
curl -X PUT https://${OPENSEARCH_HOST}:9200/_search/pipeline/nlp-search-pipeline \
-H 'Content-Type: application/json; charset=utf-8' \
--data-binary @- << EOF
{
  "description": "Post processor for hybrid search",
  "phase_results_processors": [
    {
      "normalization-processor": {
        "normalization": {
          "technique": "l2"
        },
        "combination": {
          "technique": "arithmetic_mean",
          "parameters": {
            "weights": [
              0.3,
              0.7
            ]
          }
        }
      }
    }
  ]
}
EOF

## Insert Document
curl -X PUT https://${OPENSEARCH_HOST}:9200/oic/_doc/1 \
-H 'Content-Type: application/json; charset=utf-8' \
--data-binary @- << EOF
{
    "content": "Hello"
}
EOF
## Check if the embedding is done 
curl -X GET https://${OPENSEARCH_HOST}:9200/oic/_doc/1 

