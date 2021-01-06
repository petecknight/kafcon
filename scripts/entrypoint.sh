#!/bin/bash -e

echo "Configuring and installing Connectors..."
echo "CONNECT_REST_HOST_NAME = $CONNECT_REST_HOST_NAME"
echo "CONNECT_REST_ADVERTISED_PORT = $CONNECT_REST_ADVERTISED_PORT"

HTTP_201_CREATED=201
HTTP_200_UPDATED=200

function push_config {

    until $(curl --output /dev/null --silent --head --fail http://$CONNECT_REST_HOST_NAME:$CONNECT_REST_ADVERTISED_PORT); do
        printf '.'
        sleep 5
    done

    export CONNECTOR_CONFIG_DIR="connector-config"

    for CONNECTOR in /"$CONNECTOR_CONFIG_DIR"/*

    do

        FILENAME=$(basename "$CONNECTOR")
        echo "Filename = $FILENAME"

        CONNECTOR_NAME="${FILENAME%.*}"
        echo "Connector Name = $CONNECTOR_NAME"

        CONNECTOR_ENDPOINT=http://$CONNECT_REST_HOST_NAME:$CONNECT_REST_ADVERTISED_PORT/connectors/$CONNECTOR_NAME/config
        echo "CONNECTOR_ENDPOINT = $CONNECTOR_ENDPOINT.."

        echo "Printing $CONNECTOR_NAME.json ...."

        HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X PUT $CONNECTOR_ENDPOINT -H 'Content-Type: application/json' -H 'Accept: application/json' --data '@/'"$CONNECTOR_CONFIG_DIR"'/'"$CONNECTOR_NAME"'.json')

        HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')

        HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

        if [[ "$HTTP_STATUS" == $HTTP_201_CREATED ]] ; then
            echo "Created $CONNECTOR_NAME successfully.. [HTTP status: $HTTP_STATUS]"
        elif [[ "$HTTP_STATUS" == $HTTP_200_UPDATED ]] ; then
            echo "Updated $CONNECTOR_NAME successfully.. [HTTP status: $HTTP_STATUS]"
        else
            echo "Unable to configure $CONNECTOR_NAME, [HTTP status: $HTTP_STATUS]"
        fi

        echo "$HTTP_BODY"

    done

}

# Install Kafka Connect in the background
push_config &
exec /etc/confluent/docker/run