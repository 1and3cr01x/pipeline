package com.advancedspark.streaming.rating.ml

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
import com.advancedspark.streaming.rating.core.Rating
import com.brkyvz.spark.recommendation.StreamingLatentMatrixFactorization
//import org.apache.spark.ml.recommendation.ALS.Rating
//import org.apache.spark.streaming.dstream.DStream

//val ratingStream: DStream[Rating[Long]] = ... // Your input stream of Ratings
// numUsers and numProducts are the number of users and products respectively
//val algorithm = new StreamingLatentMatrixFactorization(numUsers, numProducts)
//algorithm.trainOn(ratingStream)

//val testStream: DStream[(Long, Long)] = ... // stream of (user, product) pairs to predict on
//val predictions: DStream[Rating[Long]] = algorithm.predictOn(testStream)

object TrainALSIncremental {
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

    val brokers = "127.0.0.1:9092"
    val topics = Set("item_ratings")
    val kafkaParams = Map[String, String]("metadata.broker.list" -> brokers)
    val cassandraConfig = Map("keyspace" -> "advancedspark", "table" -> "item_ratings")
    
    val ratingsStream = KafkaUtils.createDirectStream[String, String, StringDecoder, StringDecoder](ssc, kafkaParams, topics)

    ratingsStream.foreachRDD {
      (message: RDD[(String, String)], batchTime: Time) => {
        message.cache()

        // Convert each RDD from the batch into a DataFrame
        val df = message.map(_._2.split(",")).map(rating => Rating(rating(0).trim.toInt, rating(1).trim.toInt, rating(2).trim.toInt, batchTime.milliseconds)).toDF("userId", "itemId", "rating", "timestamp")

        // Save the DataFrame to Cassandra
        // Note:  Cassandra has been initialized through spark-env.sh
        //        Specifically, export SPARK_JAVA_OPTS=-Dspark.cassandra.connection.host=127.0.0.1
        df.write.format("org.apache.spark.sql.cassandra")
          .mode(SaveMode.Append)
          .options(cassandraConfig)
          .save()

	message.unpersist()
      }
    }

    ssc.start()
    ssc.awaitTermination()
  }
}
