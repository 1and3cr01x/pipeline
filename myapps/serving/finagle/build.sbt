val globalSettings = Seq(
  version := "1.0",
  scalaVersion := sys.env("SCALA_VERSION") 
)

addSbtPlugin("com.eed3si9n" % "sbt-assembly" % sys.env("SBT_ASSEMBLY_PLUGIN_VERSION"))

lazy val settings = (project in file("."))
                    .settings(name := "finagle")
                    .settings(globalSettings:_*)
                    .settings(libraryDependencies ++= deps)
		    .settings(javaOptions += "-Xmx10G")

val sparkVersion = sys.env("SPARK_VERSION") 
val scalaTestVersion = sys.env("SCALATEST_VERSION") 
val finagleVersion = sys.env("FINAGLE_VERSION")
val jblasVersion = sys.env("JBLAS_VERSION")
val hystrixVersion = sys.env("HYSTRIX_VERSION")

lazy val deps = Seq(
  "com.twitter"          %% "finagle-http"    	% finagleVersion,
  "org.jblas" 	         % "jblas" 		% jblasVersion,
  "com.netflix.hystrix"  % "hystrix-core"       % hystrixVersion
)

