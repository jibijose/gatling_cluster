#!/bin/bash

ES_HOST=localhost
HTTP_MODE=http
ES_PORT=9200
AUTH="-u user:password"

curl $AUTH $HTTP_MODE://$ES_HOST:$ES_PORT/_cluster/health?pretty
curl -XGET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT"
curl -XGET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/_cluster/settings?pretty"

curl $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/_cat/thread_pool?pretty"
curl $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/_cat/thread_pool/write?v&h=host,name,type,largest,min,max,keep_alive,size,queue,queue_size,active,rejected,completed"


curl $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/_cat/indices?v&pretty"
curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/_cat/shards/myordertest?v&pretty"
curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/myordertest/_settings?pretty"
curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/myordertest?include_type_name=false&pretty"
curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/myordertest/_count?q=customerId:*"

curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/_ilm/policy?pretty"

### myordertest index search
curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/myordertest/_search?pretty=true&q=customerId:customerId1"
curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/myordertest/_doc/orderId1?pretty"
curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/myordertest/_search?pretty=true&q=customerId:customerId1"

curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/myordertest/_search?pretty=true&q=customerId:customerId1"
curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/myordertest/_doc/orderId1"




curl -v -X POST $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/myordertest/_doc/orderId1?routing=customerId1" -H 'Content-Type: application/json' -d'
{
    "orderId": "jj1234",
    "customerId": "cus1234",
    "orderedDate": "2018-06-01T10:10:00+05:30",
    "fulfilmentId": "fulfilled",
    "orderedState": "closed",
    "products": [
        {
        "productId": "trn:company:product:uuid:o8U",
        "productDescription": "ProductDescription-o8U",
        "productQty": "1234"
        },
        {
        "productId": "trn:company:product:uuid:4321",
        "productDescription": "ProductDescription-4321",
        "productQty": "4321"
        }
    ]
}
'
