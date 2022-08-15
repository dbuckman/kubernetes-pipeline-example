FROM amazoncorretto:11
USER 1000
VOLUME /tmp
COPY target/mobile-deposit-api-*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]