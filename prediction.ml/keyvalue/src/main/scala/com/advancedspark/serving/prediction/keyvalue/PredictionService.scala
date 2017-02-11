package com.advancedspark.serving.prediction.keyvalue

import scala.collection.JavaConversions._
import scala.collection.JavaConverters._
import scala.collection.immutable.HashMap

import scala.collection.JavaConverters.asScalaBufferConverter
import scala.collection.JavaConverters.mapAsJavaMapConverter
import scala.util.parsing.json.JSON

import org.springframework.beans.factory.annotation.Value
import org.springframework.boot._
import org.springframework.boot.autoconfigure._
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.cloud.context.config.annotation._
import org.springframework.cloud.netflix.eureka.EnableEurekaClient
import org.springframework.cloud.netflix.hystrix.EnableHystrix
import org.springframework.context.annotation._
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation._

import redis.clients.jedis._
import io.prometheus.client.spring.boot.EnablePrometheusEndpoint

@SpringBootApplication
@RestController
@EnableHystrix
@EnablePrometheusEndpoint
class PredictionService {
  val namespace = ""

  val version = "" 

  val redisHostname = "redis-master"

  val redisPort = 6379
  
  val jedisPool = new JedisPool(new JedisPoolConfig(), redisHostname, redisPort);

  @RequestMapping(path=Array("/prediction/{userId}/{itemId}"),
                  produces=Array("application/json; charset=UTF-8"))
  def prediction(@PathVariable("userId") userId: String, @PathVariable("itemId") itemId: String): String = {
    try {
      val result = new UserItemPredictionCommand("keyvalue_useritem", 25, 5, 10, -1.0d, userId, itemId)           
        .execute()

      s"""{"result":${result}}"""
    } catch {
       case e: Throwable => {
         throw e
       }
    }
  }
  
  @RequestMapping(path=Array("/batch-prediction/{userId}/{itemId}"),
                  produces=Array("application/json; charset=UTF-8"))
  def batchPrediction(@PathVariable("userId") userId: String, @PathVariable("itemId") itemId: String): String = {
    try {
      val result = new UserItemBatchPredictionCollapser("keyvalue_useritem_batch", 25, 5, 10, -1.0d, userId, itemId)
        .execute()

      s"""{"result":${result}}"""
    } catch {
       case e: Throwable => {
         throw e
       }
    }
  }
  
  

  @RequestMapping(path=Array("/recommendations/{userId}/{startIdx}/{endIdx}"), 
                  produces=Array("application/json; charset=UTF-8"))
  def recommendations(@PathVariable("userId") userId: String, @PathVariable("startIdx") startIdx: Int, 
      @PathVariable("endIdx") endIdx: Int): String = {
    try{
      
      // TODO:  try (Jedis jedis = pool.getResource()) { }; pool.destroy();

      val results = new RecommendationsCommand(jedisPool.getResource, namespace, version, userId, startIdx, endIdx)
       .execute()
      s"""{"results":[${results.mkString(",")}]}"""
    } catch {
       case e: Throwable => {
         throw e
       }
    }
  }

  @RequestMapping(path=Array("/similars/{itemId}/{startIdx}/{endIdx}"),
                  produces=Array("application/json; charset=UTF-8"))
  def similars(@PathVariable("itemId") itemId: String, @PathVariable("startIdx") startIdx: Int, 
      @PathVariable("endIdx") endIdx: Int): String = {
    try {
       val results = new ItemSimilarsCommand(jedisPool.getResource, namespace, version, itemId, startIdx, endIdx)
         .execute()
       s"""{"results":[${results.mkString(",")}]}"""
    } catch {
       case e: Throwable => {
         throw e
       }
    }
  }
}

object PredictionServiceMain {
  def main(args: Array[String]): Unit = {
    SpringApplication.run(classOf[PredictionService])
  }
}
