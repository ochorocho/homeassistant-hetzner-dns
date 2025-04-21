#!/usr/bin/with-contenv bashio

API_TOKEN="$(bashio::config 'token')"
ENTITY_ID="$(bashio::config 'ip_entity')"
API_URL="$(bashio::config 'url' | sed 's:/*$::')"
DOMAINS="$(bashio::config 'domains')"

get_ip() {
    curl -sSL -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
        -H "Content-Type: application/json" \
        http://supervisor/core/api/states/$ENTITY_ID | jq -r '.state'
}

get_dns_record() {
    curl -sSL -H "Auth-API-Token: $API_TOKEN" "$API_URL/records?zone_id=$1" | jq -r '.records[] | select(.type == "A" and .name == "'$2'")'
}

get_zone_id() {
    curl -sSL -H "Auth-API-Token: $API_TOKEN" "$API_URL/zones?name=$1&per_page=999" | jq -r '.zones[0].id'
}

get_record_post_data() {
    ip_address=$1
    record_name=$2
    zone_id=$3

    cat <<EOF
{
    "value": "$ip_address",
    "ttl": 60,
    "type": "A",
    "name": "$record_name",
    "zone_id": "$zone_id"
}
EOF
}

while true; do
    ENTITY_IP_ADDRESS="$(get_ip)"

    for domain in $DOMAINS; do
        record_name="${domain%%.*}"
        zone_name="${domain#*.}"
        zone_id="$(get_zone_id "$zone_name")"
        record_id=$(get_dns_record "$zone_id" "$record_name" | jq -r '.id')
        dns_ip=$(get_dns_record "$zone_id" "$record_name" | jq -r '.value')

        if [[ "$ENTITY_IP_ADDRESS" != "$dns_ip" ]]; then
            # Update DNS record
            data=$(get_record_post_data "$ENTITY_IP_ADDRESS" "$record_name" "$zone_id")
            response_code=$(curl -sSL -o /dev/null -w "%{http_code}" -X "PUT" \
                "$API_URL/records/$record_id" \
                -H 'Content-Type: application/json' \
                -H "Auth-API-Token: $API_TOKEN" \
                --data "$data")

            if [ "$response_code" == "404" ]; then
                # Create DNS record
                bashio::log.info "Record for $domain not found. Trying to create record ..."

                data=$(get_record_post_data "$ENTITY_IP_ADDRESS" "$record_name" "$zone_id")
                response_code_create=$(curl -sSL -o /dev/null -w "%{http_code}"  -X "POST" \
                    "$API_URL/records" \
                    -H 'Content-Type: application/json' \
                    -H "Auth-API-Token: $API_TOKEN" \
                    --data "$data")

                if [ "$response_code_create" == "200" ]; then
                    bashio::log.info "DNS record of $domain created with ip $ENTITY_IP_ADDRESS"
                else
                    bashio::log.error "Failed to create DNS record for $domain"
                fi
            fi

            if [ "$response_code" == "200" ]; then
                bashio::log.info "DNS record of $domain updated to $ENTITY_IP_ADDRESS"
            fi

            if [[ "$response_code" != "404" && "$response_code" != "200" ]]; then
                bashio::log.error "Failed to update DNS for $domain"
            fi
        else
            bashio::log.info "No update needed."
        fi
    done

    sleep 60
done
