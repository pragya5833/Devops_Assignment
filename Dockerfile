# Install Tomcat    & openjdk 8 (openjdk has java and javac)
FROM tomcat:8-jre11
RUN rm -rf /usr/local/tomcat/webapps/* &&\
      rm -rf conf/context.xml

# Copy source files to tomcat folder structure
COPY $WAR_ARCHIVE /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
# CMD ["catalina.sh", "run"]