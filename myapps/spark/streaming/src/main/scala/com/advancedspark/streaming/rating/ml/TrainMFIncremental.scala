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
import com.brkyvz.spark.recommendation.StreamingLatentMatrixFactorization
import com.brkyvz.spark.recommendation.LatentMatrixFactorizationParams
import org.apache.spark.ml.recommendation.ALS.Rating
import org.apache.spark.streaming.dstream.ConstantInputDStream

// TODO:  Look at Sean Owen's Oryx:  
//https://github.com/OryxProject/oryx/blob/91004a03413eef0fdfd6e75a61b68248d11db0e5/app/oryx-app/src/main/java/com/cloudera/oryx/app/speed/als/ALSSpeedModelManager.java#L193

object TrainMFIncremental {
  def main(args: Array[String]) {
    val conf = new SparkConf()

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
    val trainTopics = Set("item_ratings")
    val predictTopics = Set("predict_item_ratings")

    val kafkaParams = Map[String, String]("metadata.broker.list" -> brokers)
    
    //////////////
    // Training //
    //////////////
    val trainInputStream = KafkaUtils.createDirectStream[String, String, StringDecoder, StringDecoder](ssc, kafkaParams, trainTopics)

    // We need to inject a dummy rating in order to avoid this defect:
    //   https://github.com/brkyvz/streaming-matrix-factorization/issues/1
    val dummyRating = ("0", "0,0,0.0")
    val dummyRatingRDD = sc.parallelize(dummyRating :: Nil)
    val dummyStream = new ConstantInputDStream(ssc, dummyRatingRDD)

    val unionedStreams = ssc.union(List(trainInputStream, dummyStream))

    val rank = 20 // suggested number of latent factors
    val maxIterations = 5 // static number of iterations
    val lambdaRegularization = 0.1 // prevent overfitting

    val streamingMFParams = new LatentMatrixFactorizationParams()
      .setRank(rank)
      .setIter(maxIterations)
      .setLambda(lambdaRegularization)
      .setMinRating(0)
      .setMaxRating(1)

    val streamingMF = new StreamingLatentMatrixFactorization(streamingMFParams)

    val trainStream = unionedStreams.map(message => {
      val tokens = message._2.split(",")

      val userId = tokens(0).trim.toLong
      val itemId = tokens(1).trim.toLong
      val rating = tokens(2).trim.toFloat
      
      Rating(userId, itemId, rating)      
    })

    val streamingMFModel = streamingMF.trainOn(trainStream)

    trainStream.print()

    
    /////////////////
    // Predictions //
    /////////////////

    // Note:  there is a race condition where the model needs to be built before we can predict    //        this job currently fails because of this race condition.
    //        possibily serialize the model and read it in a separate predict job?
    //        then we'd have to place the prediction back on a kafka queue that the caller
    //          is listening on (clunky)  

//    val predictInputStream = KafkaUtils.createDirectStream[String, String, StringDecoder, StringDecoder](ssc, kafkaParams, predictTopics)
//    val predictStream = predictInputStream.map(message => {
//      val tokens = message._2.split(",")
//      val userId = tokens(0).trim.toLong
//      val itemId = tokens(1).trim.toLong
//      (userId, itemId)
//    })

//    val predictedStream = streamingMF.predictOn(predictStream)

//    predictedStream.print()

    ssc.start()
    ssc.awaitTermination()
  }
}
