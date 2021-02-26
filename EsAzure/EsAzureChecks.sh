#!/bin/bash

ES_HOST=10.118.23.39
HTTP_MODE=http
ES_PORT=9200
AUTH="-u user:password"

curl $AUTH $HTTP_MODE://$ES_HOST:$ES_PORT/_cluster/health?pretty
curl -XGET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT"
curl -XGET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/_cluster/settings?pretty"

curl $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/_cat/thread_pool?pretty"
curl $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/_cat/thread_pool/write?v&h=host,name,type,largest,min,max,keep_alive,size,queue,queue_size,active,rejected,completed"


curl $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/_cat/indices?v&pretty"
curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/_cat/shards/employee?v&pretty"
curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/employee/_settings?pretty"
curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/employee?include_type_name=false&pretty"
curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/employee/_count?q=customerId:*"

curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/_ilm/policy?pretty"

### Employee index search
curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/employee/_search?pretty=true&q=customerId:12345"
curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/employee/_doc/NP41hf7F5yM8LlLY?pretty"
curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/employee/_search?pretty=true&q=customerId:trn\:company\:uid\:uuid\:JBaAQ2"

curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/orders/_search?pretty=true&q=orderId:trn:company:order:storeuk:06021_081_12345_1234567890_123456"
curl -X GET $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/orders/_doc/gMubfm8B1ZFMpbnYW4Gn"




curl -X POST $AUTH "$HTTP_MODE://$ES_HOST:$ES_PORT/employee/_doc/jj1234?routing=cus1234" -H 'Content-Type: application/json' -d'
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
