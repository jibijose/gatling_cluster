import java.util.UUID

import io.gatling.core.Predef._
import io.gatling.core.structure.ScenarioBuilder
import io.gatling.http.Predef._
import io.gatling.http.protocol.HttpProtocol
import scala.util.Random
import java.util.UUID.randomUUID
import java.time.LocalDate

import scala.concurrent.duration._

class EsAzure extends Simulation {

    private val baseUrl = "http://10.118.23.39:9200";
    private val contentType = "application/json"
    private val reqBodyRTS=ElFileBody("EsAzure.json")
    val httpProtocol: HttpProtocol = http.baseUrl(baseUrl).inferHtmlResources().contentTypeHeader(contentType)
    //.shareConnections

    val scnWRITE: ScenarioBuilder = scenario("WriteSimulation")
        .exec(session => session.set("randomProductId", randomStr(3)))
        .exec(session => session.set("randomCustomerId", randomStr(6)))
        .exec(session => session.set("randomOrderId", UUID.randomUUID().toString))
        .exec(session => session.set("randomDate", getRandomDate()))
        .exec(session => session.set("randomQuantity", randomInt()))
        .exec(http("es_write_namesuffix")
        .post(session => s"/orders/_doc/" + session("randomOrderId").as[String] + "?routing=" + session("randomCustomerId").as[String])
        //.post(session => s"/orders/_doc/" + session("randomOrderId").as[String])
        //.post(session => s"/orders/_doc")
        .body(reqBodyRTS).asJson
        .header("Content-Type",session => contentType)
        .check(status.is(201)))
  
    val scnSEARCH: ScenarioBuilder = scenario("SearchSimulation")
        .exec(session => session.set("randomCustomerId", randomStr(6)))
        .exec(http("es_search_namesuffix")
        .get(session => s"/orders/_search?q=customerId:" + session("randomCustomerId").as[String] + "&routing=" + session("randomCustomerId").as[String])
        .check(status.is(200)))

    setUp(
      scnWRITE.inject(
        constantUsersPerSec(1) during (2 seconds)
        ,incrementUsersPerSec(10)
        .times(10)
        .eachLevelLasting(10 seconds)
        .separatedByRampsLasting(10 seconds)
        .startingFrom(0)
        ,constantUsersPerSec(100) during (60 minutes)
        /*,incrementUsersPerSec(1)
        .times(100)
        .eachLevelLasting(10 seconds)
        .separatedByRampsLasting(10 seconds)
        .startingFrom(1500)*/
      )
      .protocols(httpProtocol)
      /*,scnSEARCH.inject(
        constantUsersPerSec(1) during (10 seconds)
        ,incrementUsersPerSec(200)
        .times(10)
        .eachLevelLasting(10 seconds)
        .separatedByRampsLasting(10 seconds)
        .startingFrom(0)
        ,constantUsersPerSec(2000) during (10 minutes)
        ,incrementUsersPerSec(5)
        .times(20)
        .eachLevelLasting(10 seconds)
        .separatedByRampsLasting(10 seconds)
        .startingFrom(300)
      )
      .protocols(httpProtocol)*/
    )
    .maxDuration(60 minutes);




    def getRandomDate () : String = {
      return LocalDate.of(2019-Random.nextInt(2),1+Random.nextInt(11),1+Random.nextInt(27)).toString
    }

    def randomStr(length: Int) = scala.util.Random.alphanumeric.take(length).mkString
    def randomInt() = scala.util.Random.nextInt()

}
