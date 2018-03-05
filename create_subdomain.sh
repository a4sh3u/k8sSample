#!/bin/bash

PARENT_ZONE_ID=$(aws route53 list-hosted-zones | grep -w '"etc.com."' -B 1 | grep -i id | awk -F '"' '{print $4}')
aws route53 create-hosted-zone --name zen.etc.com --caller-reference zen
NAME_SERVERS=$(aws route53 get-hosted-zone --id $(aws route53 list-hosted-zones | grep zen.etc.com -B 1 | grep -i id | awk -F '"' '{print $4}') | jq -r ."DelegationSet"."NameServers")
NS1=$(echo $NAME_SERVERS| awk -F '"' '{print $2}')
NS2=$(echo $NAME_SERVERS| awk -F '"' '{print $4}')
NS3=$(echo $NAME_SERVERS| awk -F '"' '{print $6}')
NS4=$(echo $NAME_SERVERS| awk -F '"' '{print $8}')
cat > ./nameservers.json <<EOL
{
  "Comment": "Create a subdomain NS record in the parent domain",
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "zen.etc.com",
        "Type": "NS",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "${NS1}"
          },
          {
            "Value": "${NS2}"
          },
          {
            "Value": "${NS3}"
          },
          {
            "Value": "${NS4}"
          }
        ]
      }
    }
  ]
}
EOL
aws route53 change-resource-record-sets --hosted-zone-id ${PARENT_ZONE_ID} --change-batch file://nameservers.json
