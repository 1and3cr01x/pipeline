package com.advancedspark.mechanicalsympathy.thread

import java.util.concurrent.CountDownLatch
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

case class Counters(left: Int, right: Int)

object NaiveCaseClass2CounterIncrement {
  var counters = new Counters(0,0)
	
  val startLatch = new CountDownLatch(1)
  var finishLatch = new CountDownLatch(0) // This will be set to the # of threads 

  def getCounters(): Counters = {
    counters 
  }

  def increment(leftIncrement: Int, rightIncrement: Int): Counters = {
    counters.synchronized {
      counters = new Counters(counters.left + leftIncrement, counters.right + rightIncrement)
      counters   
    }
  }

  class IncrementTask(leftIncrement: Int, rightIncrement: Int) extends Runnable {
    @Override
    def run() : Unit = {
      startLatch.await()
        
      increment(leftIncrement, rightIncrement)

      finishLatch.countDown()
    }
  }
	
  def main(args: Array[String]) {
    val executor = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors())
    val numThreads = args(0).toInt
    val leftIncrement = args(1).toInt
    val rightIncrement = args(2).toInt

    finishLatch = new CountDownLatch(numThreads)

    // schedule all threads in the threadpool
    for (i <- 1 to numThreads) {
      executor.execute(new IncrementTask(leftIncrement, rightIncrement))
    }

    val startTime = System.currentTimeMillis

    // start all threads
    startLatch.countDown()

    // wait for all threads to finish
    finishLatch.await()

    val endTime = System.currentTimeMillis

    val counters = getCounters()

    System.out.println("leftInt OK? " + (counters.left == leftIncrement * numThreads))
    System.out.println("rightInt OK? " + (counters.right == rightIncrement * numThreads))
    System.out.println("runtime? " + (endTime - startTime))
  }
}
