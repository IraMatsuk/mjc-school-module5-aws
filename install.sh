#!/bin/bash
echo "install web server components"

# update packages
yum update -y

# copy jar file from S3 to my EC2 instance
mkdir -p /tmp/matsuk/
aws s3 cp s3://mjc-iramatsuk-jar/web-0.0.1-SNAPSHOT.jar /tmp/matsuk/

mkdir -p /usr/java/openjdk
cd /usr/java/openjdk

# download jdk 15
wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.java.net/openjdk/jdk15/ri/openjdk-15+36_linux-x64_bin.tar.gz

# unzip tar file
tar -xzvf openjdk-15+36_linux-x64_bin.tar.gz

#  setting path variable
echo "JAVA_HOME=/usr/java/openjdk/jdk-15
PATH=$PATH:$HOME/bin:$JAVA_HOME/bin
export JAVA_HOME
export PATH" >> /etc/profile

# update and add a group of alternatives to the system
update-alternatives --install "/usr/bin/java" "java" "/usr/java/openjdk/jdk-15/bin/java" 1

# Install Postgress to EC2 instance
amazon-linux-extras install -y postgresql14

# Run jar file on booting EC2 instance
echo "#!/bin/bash
java -Dspring.datasource.url=jdbc:postgresql://database-1.czdvsiejaswl.us-east-1.rds.amazonaws.com:5432/certificates -Dspring.datasource.username=postgres -Dspring.datasource.password=postgres -jar /tmp/matsuk/web-0.0.1-SNAPSHOT.jar" >> /var/lib/cloud/scripts/per-boot/run.sh

chmod 777 /var/lib/cloud/scripts/per-boot/run.sh

# Run jar file on EC2 instance
java -Dspring.datasource.url=jdbc:postgresql://database-1.czdvsiejaswl.us-east-1.rds.amazonaws.com:5432/certificates -Dspring.datasource.username=postgres -Dspring.datasource.password=postgres -jar /tmp/matsuk/web-0.0.1-SNAPSHOT.jar

echo "all components were installed"