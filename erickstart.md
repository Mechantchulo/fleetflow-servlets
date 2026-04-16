```
mvn clean package -DskipTests
sudo cp target/FleetflowServlets-1.0-SNAPSHOT.war /opt/tomcat/webapps/
sudo /opt/tomcat/bin/shutdown.sh
sudo CATALINA_OPTS="-DDB_HOST=localhost -DDB_PORT=5435 -DDB_NAME=academic_trip_db -DDB_USER=erick -DDB_PASSWORD=fleetflow2026 -DAUTH_DEBUG=true" /opt/tomcat/bin/startup.sh
```

```
docker compose --profile localdb up -d
```