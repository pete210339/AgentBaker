#!/bin/bash -e

required_env_vars=(
    "SUBSCRIPTION_ID"
    "RESOURCE_GROUP_NAME"
    "CREATE_TIME"
    "LOCATION"
    "OS_TYPE"
)


for v in "${required_env_vars[@]}"
do
    if [ -z "${!v}" ]; then
        echo "$v was not set!"
        exit 1
    fi
done

sig_resource_id="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP_NAME}/providers/Microsoft.Compute/galleries/PackerSigGallery/images/1804Gen2/versions/1.0.${CREATE_TIME}"
disk_resource_id="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP_NAME}/providers/Microsoft.Compute/disks/1.0.${CREATE_TIME}"

az resource create --id $disk_resource_id  --is-full-object --location $LOCATION --properties "{\"location\": \"$LOCATION\", \
  \"properties\": { \
    \"osType\": \"$OS_TYPE\", \
    \"creationData\": { \
      \"createOption\": \"FromImage\", \
      \"galleryImageReference\": { \
        \"id\": \"${sig_resource_id}\" \
      } \
    } \
  } \
}"

echo "COPY ME ---> "

cat <<EOF > vhd-publishing-info.json
{
    "sig_resource_id": "${sig_resource_id}",
    "disk_resource_id": "${disk_resource_id}",
    "location":"$location"
}
EOF

cat vhd-publishing-info.json