# SSH
echo ...Configuring SSH...
service ssh start 
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa 
mkdir -p ~/.ssh 
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys 
chmod 600 ~/.ssh/authorized_keys 
chmod 600 ~/.ssh/id_rsa 
service ssh stop

# Apache Httpd
echo ...Configuring Apache Httpd...
a2enmod proxy 
a2enmod proxy_http 
a2dissite 000-default
mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf.orig 
ln -s $PIPELINE_HOME/config/apache2/apache2.conf /etc/apache2 

# Datasets
echo ...Configuring Datasets...
bzip2 -d -k datasets/dating/gender.json.bz2
bzip2 -d -k datasets/dating/gender.csv.bz2
bzip2 -d -k datasets/dating/ratings.json.bz2
bzip2 -d -k datasets/dating/ratings.csv.bz2

# Sample WebApp
echo ...Configuring Sample WebApp...
ln -s $PIPELINE_HOME/config/sparkafterdark/sparkafterdark.conf /etc/apache2/sites-available 
a2ensite sparkafterdark 
ln -s $PIPELINE_HOME/datasets $PIPELINE_HOME/html/sparkafterdark.com 
# Every parent of /html is required to serve up the html
chmod -R a+rx ~ 

# Ganglia
echo ...Configuring Ganglia...
ln -s $PIPELINE_HOME/config/ganglia/ganglia.conf /etc/apache2/sites-available 
a2ensite ganglia 
mv /etc/ganglia/gmetad.conf /etc/ganglia/gmetad.conf.orig 
mv /etc/ganglia/gmond.conf /etc/ganglia/gmond.conf.orig 
ln -s $PIPELINE_HOME/config/ganglia/gmetad.conf /etc/ganglia 
ln -s $PIPELINE_HOME/config/ganglia/gmond.conf /etc/ganglia 

# MySQL (Required by HiveQL Exercises)
echo ...Configurating MySQL...
service mysql start 
mysqladmin -u root password "password"
nohup service mysql stop 
#export MYSQL_CONNECTOR_JAR=/usr/share/java/mysql-connector-java-5.1.28.jar

# Cassandra
echo ...Configuring Cassandra...

# Spark 
echo ...Configuring Spark...
ln -s $PIPELINE_HOME/config/spark/spark-defaults.conf $SPARK_HOME/conf 
ln -s $PIPELINE_HOME/config/spark/spark-env.sh $SPARK_HOME/conf 
ln -s $PIPELINE_HOME/config/spark/metrics.properties $SPARK_HOME/conf 
ln -s $PIPELINE_HOME/config/hadoop/hive-site.xml $SPARK_HOME/conf 
ln -s $MYSQL_CONNECTOR_JAR $SPARK_HOME/lib 

# Kafka
echo ...Configuring Kafka...

# ZooKeeper
echo ...Configuring ZooKeeper...

# ElasticSearch 
echo ...Configuring ElasticSearch...

# Logstash
echo ...Configuring Logstash...

# Kibana
echo ...Configuring Kibana...

# Hadoop HDFS
echo ...Configuring Hadoop HDFS...

# Redis
echo ...Configuring Redis...

# Tachyon
echo ...Configuring Tachyon...
ln -s $PIPELINE_HOME/config/tachyon/tachyon-env.sh $TACHYON_HOME/conf

# SBT
echo ...Configuring SBT...

# Zeppelin
echo ...Configuring Zeppelin...
ln -s $PIPELINE_HOME/config/zeppelin/zeppelin-env.sh $ZEPPELIN_HOME/conf 
ln -s $PIPELINE_HOME/config/zeppelin/zeppelin-site.xml $ZEPPELIN_HOME/conf 
ln -s $PIPELINE_HOME/config/zeppelin/interpreter.json $ZEPPELIN_HOME/conf 
ln -s $PIPELINE_HOME/config/hadoop/hive-site.xml $ZEPPELIN_HOME/conf 
ln -s $MYSQL_CONNECTOR_JAR $ZEPPELIN_HOME/lib 

# Spark-Notebook
echo ...Configuring Spark-Notebook...
