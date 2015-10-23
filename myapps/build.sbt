val globalSettings = Seq(
  version := "1.0",
  scalaVersion := "2.10.4"
)

addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "0.14.0")

lazy val feeder = (project in file("feeder"))
                    .settings(name := "feeder")
                    .settings(globalSettings:_*)
                    .settings(libraryDependencies ++= feederDeps)

lazy val streaming = (project in file("streaming"))
                       .settings(name := "streaming")
                       .settings(globalSettings:_*)
                       .settings(libraryDependencies ++= streamingDeps)

lazy val datasource = (project in file("datasource"))
                       .settings(name := "datasource")
                       .settings(globalSettings:_*)
                       .settings(libraryDependencies ++= datasourceDeps)

lazy val tungsten = (project in file("tungsten"))
                    .settings(name := "tungsten")
                    .settings(globalSettings:_*)
                    .settings(libraryDependencies ++= tungstenDeps)

val akkaVersion = "2.3.11"
val sparkVersion = "1.5.1"
val sparkCassandraConnectorVersion = "1.4.0"
val sparkElasticSearchConnectorVersion = "2.2.0-m1"
val kafkaVersion = "0.8.2.1"
val scalaTestVersion = "2.2.4"
val jedisVersion = "2.4.2"
val sparkCsvVersion = "1.2.0"

lazy val feederDeps = Seq(
  "com.typesafe.akka" %% "akka-actor" % akkaVersion,
  "com.typesafe.akka" %% "akka-testkit" % akkaVersion % "test",
  "org.scalatest" %% "scalatest" % scalaTestVersion % "test",
  "org.apache.kafka" % "kafka_2.10" % kafkaVersion
    exclude("javax.jms", "jms")
    exclude("com.sun.jdmk", "jmxtools")
    exclude("com.sun.jmx", "jmxri")
)

lazy val streamingDeps = Seq(
  "com.datastax.spark" % "spark-cassandra-connector_2.10" % sparkCassandraConnectorVersion % "provided",
  "org.elasticsearch" % "elasticsearch-spark_2.10" % sparkElasticSearchConnectorVersion % "provided",
  "redis.clients" % "jedis" % jedisVersion % "provided",
  "com.databricks"    %% "spark-csv" % sparkCsvVersion % "provided",
  "org.apache.spark"  %% "spark-mllib"           % sparkVersion % "provided",
  "org.apache.spark"  %% "spark-graphx"          % sparkVersion % "provided",
  "org.apache.spark"  %% "spark-sql"             % sparkVersion % "provided",
  "org.apache.spark"  %% "spark-streaming"       % sparkVersion % "provided",
  "org.apache.spark"  %% "spark-streaming-kafka" % sparkVersion % "provided"
)

lazy val datasourceDeps = Seq(
  "org.apache.spark"  %% "spark-sql"             % sparkVersion % "provided"
)

lazy val tungstenDeps = Seq(
  "org.scalatest" %% "scalatest" % scalaTestVersion % "test",
  "org.apache.spark"  %% "spark-core" % sparkVersion
    exclude("commons-collections", "commons-collections")
    exclude("commons-beanutils", "commons-beanutils")
    exclude("org.apache.hadoop", "hadoop-yarn-api")
    exclude("org.apache.hadoop", "hadoop-yarn-common")
    exclude("com.google.guava", "guava")
    exclude("com.esotericsoftware.kryo", "kryo")
    exclude("com.esotericsoftware.kryo", "minlog")
    exclude("org.apache.spark", "spark-launcher-2.10")
    exclude("org.spark-project.spark", "unused")
    exclude("org.apache.spark", "spark-network-common_2.10")
    exclude("org.apache.spark", "spark-network-shuffle_2.10")
    exclude("org.apache.spark", "spark-unsafe_2.10")
)

