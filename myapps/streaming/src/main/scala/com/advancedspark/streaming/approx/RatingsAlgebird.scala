package com.advancedspark.spark.streaming.approx

import org.apache.spark.streaming.kafka.KafkaUtils
import org.apache.spark.streaming.Seconds
import org.apache.spark.streaming.StreamingContext
import org.apache.spark.SparkContext
import org.apache.spark.sql.SQLContext
import org.apache.spark.SparkConf
import kafka.serializer.StringDecoder
import org.apache.spark.sql.SaveMode
import org.apache.spark.sql.Row
import org.apache.spark.rdd.RDD
import org.apache.spark.streaming.Time

// Redis Client including HyperLogLog Support
import redis.clients.jedis.Jedis
import redis.clients.jedis.Transaction

// Twitter Algebird HyperLogLog Impl
import com.twitter.algebird._
import com.twitter.algebird.Operators._
import HyperLogLog._
import com.advancedspark.spark.streaming.core.Rating

object RatingsAlgebird {
  def main(args: Array[String]) {
    val conf = new SparkConf()
      .set("spark.cassandra.connection.host", "127.0.0.1")
    
    val sc = SparkContext.getOrCreate(conf)

    def createStreamingContext(): StreamingContext = {
      @transient val newSsc = new StreamingContext(sc, Seconds(2))
      println(s"Creating new StreamingContext $newSsc")

      newSsc
    }
    val ssc = StreamingContext.getActiveOrCreate(createStreamingContext)

    val sqlContext = SQLContext.getOrCreate(sc)
    import sqlContext.implicits._

    // Kafka Config
    val brokers = "127.0.0.1:9092"
    val kafkaParams = Map[String, String]("metadata.broker.list" -> brokers)
    val topics = Set("item_ratings")

    // Setup the Algebird HyperLogLog data struct using 14 bits
    // Note:  this is the same as the Redis implementation
    //        2^14 = 16,384 registers, 0.81% standard error
    val algebirdHLL = new HyperLogLogMonoid(14) 

    //TODO
    //def uniqueValues(sc:SparkContext,csvFile:String, colNum:Int):Long = {
    //  val hll = new HyperLogLogMonoid(12) // ~ 1% probability of error with 2^12 bits
    //  val rdd:RDD[Row] = SparkUtils.rddFromCSVFile(sc,csvFile, false)
    //  val approxCount = rdd
    //    .map {r => r(colNum).toString}
    //    .map {c => hll(c.hashCode)} // HLL (defines zero and plus)
    //    .reduce(_ + _)
    //  approxCount.estimatedSize.toLong
    //}
    
    // Create Kafka Direct Stream Receiver
    val ratingsStream = KafkaUtils.createDirectStream[String, String, StringDecoder, StringDecoder](ssc, kafkaParams, topics)

    ratingsStream.foreachRDD {
      (message: RDD[(String, String)], batchTime: Time) => {
        message.cache()

        // Split each _2 element of the RDD (String,String) tuple into a RDD[Seq[String]]
        val tokens = message.map(_._2.split(","))

	// convert messageTokens into RDD[Ratings]
        val ratings = tokens.map(token => Rating(token(0).trim.toInt,token(1).trim.toInt,token(2).trim.toInt,batchTime.milliseconds))

        val jedis = new Jedis("127.0.0.1", 6379)

	// increment the HyperLogLog distinct count for each fromuserid that chooses the touserid in Redis
        ratings.foreachPartition(ratingsPartitionIter => {
          // TODO:  Fix this.  
	  // 	    1) This obviously only works when everything is running on 1 node.
	  //        2) This should be using a Jedis Singleton/Pooled connection
 	  //        3) Explore the spark-redis package (RedisLabs:spark-redis:0.1.0+)
          val jedis = new Jedis("127.0.0.1", 6379)
          val t = jedis.multi()
          ratingsPartitionIter.foreach(rating => {
            val key = s"""hll:${rating.userId}"""
	    val value = s"""${rating.itemId}"""
   	    t.pfadd(key, value)
	  })
          t.exec()
        })
	jedis.close()

	message.unpersist()
      }
    }

    ssc.start()
    ssc.awaitTermination()
  }
}
