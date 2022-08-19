FROM openjdk:8u322-oraclelinux7
COPY ./mongoDemo*jar /opt/storage/
WORKDIR /opt/storage/
EXPOSE 8080
CMD /opt/storage/mongoDemo*.jar start
