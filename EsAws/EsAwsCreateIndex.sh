#!/bin/bash

ES_HOST=localhost
HTTP_MODE=http
ES_PORT=9200
AUTH="-u user:password"

curl -X DELETE $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/myordertest?pretty"
curl -X DELETE $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/myordertest-*?pretty"

curl -X PUT $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/myordertest?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "refresh_interval": "1s",
      "unassigned": {
        "node_left": {
          "delayed_timeout": "10m"
        }
      },
      "number_of_shards": "10",
      "translog": {
        "sync_interval": "100ms",
        "durability": "async"
      },
      "number_of_replicas": "1"
    }
  },
  "mappings": {
    "dynamic": false,
    "_routing": {
      "required": true
    },
    "_source": {
      "enabled": true
    },
    "properties": {
      "updatedTime": {
        "type": "date"
      },
      "orderNumber": {
        "type": "keyword"
      },
      "orderId": {
        "type": "keyword"
      },
      "legacyLocationId": {
        "type": "keyword"
      },
      "channel": {
        "type": "keyword"
      },
      "isTillTransferred": {
        "type": "keyword"
      },
      "clientIds": {
        "type": "keyword"
      },
      "orderState": {
        "type": "keyword"
      },
      "tags": {
        "type": "keyword"
      },
      "locationId": {
        "type": "keyword"
      },
      "amendInProgress": {
        "type": "keyword"
      },
      "customerId": {
        "type": "keyword"
      },
      "createdTime": {
        "type": "date"
      },
      "legacyOrderId": {
        "type": "keyword"
      }
    }
  }
}
'


curl -X POST $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/_reindex?pretty" -H 'Content-Type: application/json' -d'
{
  "source": {
    "index": "myorders"
  },
  "dest": {
    "index": "myordertest"
  }
}
'


curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/myordertest/_search?q=customerId:customerId1&routing=customerId1"


curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/myordertest/_search?routing=customerId1" -H 'Content-Type: application/json' -d'
{
  "size": 50,
  "query": {
    "bool": {
      "must": [
        {
          "range": {
            "updatedTime": {
              "from": null,
              "to": null,
              "include_lower": true,
              "include_upper": true,
              "boost": 1
            }
          }
        }
      ],
      "filter": [
        {
          "terms": {
            "customerId": [
              "customerId1"
            ],
            "boost": 1
          }
        }
      ],
      "adjust_pure_negative": true,
      "boost": 1
    }
  },
  "_source": {
    "includes": [
      "orderId",
      "orderNumber",
      "createdTime",
      "updatedTime",
      "orderState",
      "locationId",
      "legacyLocationId",
      "channel",
      "amendInProgress",
      "legacyOrderId",
      "isTillTransferred",
      "orderValue",
      "tags",
      "clientIds"
    ],
    "excludes": [
      
    ]
  },
  "sort": [
    {
      "updatedTime": {
        "order": "desc"
      }
    }
  ]
}
'
