package com.fluxcapacitor.pipeline.spark.streaming

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
import redis.clients.jedis.Jedis
import redis.clients.jedis.Transaction

object RatingsExact {
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

    // Cassandra Config
    val cassandraConfig = Map("keyspace" -> "fluxcapacitor", "table" -> "ratings")

    // Kafka Config    
    val brokers = "localhost:9092"
    val kafkaParams = Map[String, String]("metadata.broker.list" -> brokers)
    val topics = Set("ratings")
 
    // Create Kafka Direct Stream Receiver
    val ratingsStream = KafkaUtils.createDirectStream[String, String, StringDecoder, StringDecoder](ssc, kafkaParams, topics)

    ratingsStream.foreachRDD {
      (message: RDD[(String, String)], batchTime: Time) => {
        message.cache()

        // Split each _2 element of the RDD (String,String) tuple into a RDD[Seq[String]]
        val tokens = message.map(_._2.split(","))

	// convert messageTokens into RDD[Ratings]
        val ratings = tokens.map(token => Rating(token(0).trim.toInt,token(1).trim.toInt,token(2).trim.toInt,batchTime.milliseconds))

        // save the DataFrame to Cassandra
        // Note:  Cassandra has been initialized through spark-env.sh
        //        Specifically, export SPARK_JAVA_OPTS=-Dspark.cassandra.connection.host=127.0.0.1
        val ratingsDF = ratings.toDF("fromuserid", "touserid", "rating", "batchtime")

        ratingsDF.write.format("org.apache.spark.sql.cassandra")
          .mode(SaveMode.Append)
          .options(cassandraConfig)
          .save()

	// increment the exact count for touserid in Redis
        ratings.foreachPartition(ratingsPartitionIter => {
          // TODO:  Fix this.  
	  // 	    1) This obviously only works when everything is running on 1 node.
	  //        2) This should be using a Jedis Singleton/Pooled connection
 	  //        3) Explore the spark-redis package (RedisLabs:spark-redis:0.1.0+)
          val jedis = new Jedis("127.0.0.1", 6379)
          val t = jedis.multi()
          ratingsPartitionIter.foreach(rating => t.incr("exact:" + rating.touserid))
	  t.exec()
	  jedis.close()
	})

	message.unpersist()
      }
    }

    ssc.start()
    ssc.awaitTermination()
  }
}
