FROM confluentinc/cp-kafka-connect:5.2.1

RUN apt-get update; apt-get install nano -y --force-yes

# Copy connector templates
COPY connector-config /connector-config

# Copy libraries
COPY build/mysql/ /usr/share/java/kafka-connect-jdbc/

# Copy custom connector scripts
COPY scripts/entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
COPY scripts/updateConnectorPlugin.sh updateConnectorPlugin.sh
RUN chmod +x updateConnectorPlugin.sh

# Setup prometheus exporter configuration
RUN mkdir -p /prometheus-config
COPY config/prometheus-config.yml /prometheus-config/prometheus-config.yml
COPY config/prometheus-logging.properties /prometheus-config/prometheus-logging.properties
COPY config/jmx_prometheus_javaagent.jar /tmp/jmx_prometheus_javaagent.jar

# Configure kafka-connect
ENV CONNECT_BOOTSTRAP_SERVERS 192.168.0.38:9092
ENV CONNECT_GROUP_ID kafcon-consumer-group
ENV CONNECT_CONFIG_STORAGE_TOPIC configs
ENV CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR 1
ENV CONNECT_CONFIG_STORAGE_PARTITIONS 1
ENV CONNECT_OFFSET_STORAGE_TOPIC offset
ENV CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR 1
ENV CONNECT_OFFSET_STORAGE_PARTITIONS 1
ENV CONNECT_STATUS_STORAGE_TOPIC status
ENV CONNECT_STATUS_STORAGE_REPLICATION_FACTOR 1
ENV CONNECT_STATUS_STORAGE_PARTITIONS 1
ENV CONNECT_KEY_CONVERTER org.apache.kafka.connect.json.JsonConverter
ENV CONNECT_VALUE_CONVERTER org.apache.kafka.connect.json.JsonConverter
ENV CONNECT_INTERNAL_KEY_CONVERTER org.apache.kafka.connect.json.JsonConverter
ENV CONNECT_INTERNAL_VALUE_CONVERTER org.apache.kafka.connect.json.JsonConverter
ENV CONNECT_REST_ADVERTISED_HOST_NAME localhost
ENV CONNECT_REST_HOST_NAME localhost
ENV CONNECT_REST_ADVERTISED_PORT 8083
ENV CONNECT_KEY_CONVERTER_SCHEMAS_ENABLE false
ENV CONNECT_VALUE_CONVERTER_SCHEMAS_ENABLE false
ENV CONNECT_PRODUCER_ACKS all
ENV KAFKA_HEAP_OPTS "-Xms512m -Xmx512m"
ENV KAFKA_JMX_OPTS "-Djava.util.logging.config.file=/prometheus-config/prometheus-logging.properties -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -javaagent:/tmp/jmx_prometheus_javaagent.jar=5181:/prometheus-config/prometheus-config.yml"
ENV CONNECT_PLUGIN_PATH "/usr/share/java,/usr/share/confluent-hub-components"

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8083