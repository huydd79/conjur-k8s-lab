FROM docker.io/library/tomcat:9.0.58-jdk17-openjdk-slim
MAINTAINER huy.do@cyberark.com
ADD target/*.war /usr/local/tomcat/webapps/
EXPOSE 8080
CMD ["catalina.sh", "run"]