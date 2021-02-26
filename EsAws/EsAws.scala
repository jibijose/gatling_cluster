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

    private val baseUrl = "http://localhost:9200";
    private val contentType = "application/json"
    private val reqBodyWrite=ElFileBody("EsAwsWrite.json")
    private val reqBodySearch=ElFileBody("EsAwsSearch.json")
    val httpProtocol: HttpProtocol = http.baseUrl(baseUrl).inferHtmlResources().contentTypeHeader(contentType)
    //.shareConnections
    val random = new Random

    val scnWRITE: ScenarioBuilder = scenario("WriteSimulation")
        .exec(session => session.set("randomProductId", randomStr(3)))
        .exec(session => session.set("randomCustomerId", randomStr(6)))
        .exec(session => session.set("randomOrderId", UUID.randomUUID().toString))
        .exec(session => session.set("randomDate", getRandomDate()))
        .exec(session => session.set("randomQuantity", randomInt()))
        .exec(session => session.set("randomCustomerId", getRandomCustomerId()))
        .exec(http("es_write_namesuffix")
        .post(session => s"/myordertest/_doc/" + session("randomOrderId").as[String] + "?routing=" + session("randomCustomerId").as[String])
        .body(reqBodyWrite).asJson
        .basicAuth("user", "password")
        .header("Content-Type",session => contentType)
        .check(status.is(201)))
  
    val scnSEARCH: ScenarioBuilder = scenario("SearchSimulation")
        .exec(session => session.set("randomCustomerId", getRandomCustomerId()))
        .exec(http("es_search_namesuffix")
        .get(session => s"/myordertest/_search?routing=" + session("randomCustomerId").as[String])
        .body(reqBodySearch).asJson
        .basicAuth("user", "password")
        .check(status.is(200)))

    setUp(
      /*scnWRITE.inject(
        constantUsersPerSec(1) during (2 seconds)
        ,incrementUsersPerSec(10)
        .times(10)
        .eachLevelLasting(10 seconds)
        .separatedByRampsLasting(10 seconds)
        .startingFrom(0)
        ,constantUsersPerSec(100) during (10 minutes)
        ,incrementUsersPerSec(1)
        .times(100)
        .eachLevelLasting(10 seconds)
        .separatedByRampsLasting(10 seconds)
        .startingFrom(1500)
      )
      .protocols(httpProtocol)
      ,*/
      scnSEARCH.inject(
        constantUsersPerSec(1) during (10 seconds)
        ,incrementUsersPerSec(20)
        .times(10)
        .eachLevelLasting(10 seconds)
        .separatedByRampsLasting(10 seconds)
        .startingFrom(0)
        ,constantUsersPerSec(200) during (10 minutes)
        /*,incrementUsersPerSec(5)
        .times(20)
        .eachLevelLasting(10 seconds)
        .separatedByRampsLasting(10 seconds)
        .startingFrom(300)*/
      )
      .protocols(httpProtocol)
    )
    .maxDuration(10 minutes);




    def getRandomDate () : String = {
      return LocalDate.of(2019-Random.nextInt(2),1+Random.nextInt(11),1+Random.nextInt(27)).toString
    }
    

    def randomStr(length: Int) = scala.util.Random.alphanumeric.take(length).mkString
    def randomInt() = scala.util.Random.nextInt()

    def getRandomCustomerId () : String = {
      return customerIdList(random.nextInt(customerIdList.length))
    }

    val customerIdList = Seq(
      "customerId1",
      "customerId2",
      "customerId3"
    )
}
