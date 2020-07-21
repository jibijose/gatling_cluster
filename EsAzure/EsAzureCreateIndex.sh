#!/bin/bash

ES_HOST=10.118.23.39
HTTP_MODE=http
ES_PORT=9200

curl -X DELETE "$HTTP_MODE://$ES_HOST:$ES_PORT/employee?pretty"
curl -X DELETE "$HTTP_MODE://$ES_HOST:$ES_PORT/employee-*?pretty"



curl -X PUT "$HTTP_MODE://$ES_HOST:$ES_PORT/employee?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 3,
      "number_of_replicas": 2
    }
  },
  "mappings": {
      "dynamic": false,
      "properties": {
        "orderId": {
          "type": "text",
          "index": false
        },
        "customerId": {
          "type": "text",
          "index": true
        },
        "orderedDate": {
          "type": "date",
          "index": false
        },
        "fulfilmentId": {
          "type": "text",
          "index": false
        },
        "orderedState": {
          "type": "text",
          "index": false
        },
        "products": {
          "type": "nested",
          "dynamic": false,
          "properties": {
            "productId": {
              "type": "text",
              "index": false
            },
            "productDescription": {
              "type": "text",
              "index": false
            },
            "productQty": {
              "type": "integer",
              "index": false
            }
          }
        }
      }
    
  }
}
'


curl -X PUT "$HTTP_MODE://$ES_HOST:$ES_PORT/_ilm/policy/my_policy?pretty" -H 'Content-Type: application/json' -d'
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {
            "max_size": "1MB",
            "max_docs": "1000",
            "max_age": "300s"
          }
        }
      },
      "delete": {
        "min_age": "300s",
        "actions": {
          "delete": {} 
        }
      }
    }
  }
}
'
curl -X PUT "$HTTP_MODE://$ES_HOST:$ES_PORT/_template/my_template?pretty" -H 'Content-Type: application/json' -d'
{
  "index_patterns": ["employee-*"], 
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1,
    "index.lifecycle.name": "my_policy", 
    "index.lifecycle.rollover_alias": "employee"
  },
  "mappings": {
    "_doc": {
      "dynamic": false,
      "properties": {
        "orderId": {
          "type": "text",
          "index": false
        },
        "customerId": {
          "type": "text",
          "index": true
        },
        "orderedDate": {
          "type": "date",
          "index": false
        },
        "fulfilmentId": {
          "type": "text",
          "index": false
        },
        "orderedState": {
          "type": "text",
          "index": false
        },
        "products": {
          "type": "nested",
          "dynamic": false,
          "properties": {
            "productId": {
              "type": "text",
              "index": false
            },
            "productDescription": {
              "type": "text",
              "index": false
            },
            "productQty": {
              "type": "integer",
              "index": false
            }
          }
        }
      }
    }
  }
}
'
curl -X PUT "$HTTP_MODE://$ES_HOST:$ES_PORT/employee-000001?pretty" -H 'Content-Type: application/json' -d'
{
  "aliases": {
    "employee":{
      "is_write_index": true 
    }
  }
}
'






