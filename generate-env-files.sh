#!/bin/bash

echo -n "Enter the full path to your local checkout of \`notifications-credentials\`: "
read PASSWORD_STORE_DIR
export PASSWORD_STORE_DIR

echo -n "Enter your local development AWS SQS queue prefix (eg \`local_dev_sam\`): "
read TMPL_NOTIFICATIONS_QUEUE_PREFIX
export TMPL_NOTIFICATIONS_QUEUE_PREFIX="${TMPL_NOTIFICATIONS_QUEUE_PREFIX}"

echo -n "Enter your local development user's aws_access_key_id: "
read TMPL_AWS_ACCESS_KEY_ID
export TMPL_AWS_ACCESS_KEY_ID="${TMPL_AWS_ACCESS_KEY_ID}"

echo -n "Enter your local development user's aws_secret_access_key: "
read TMPL_AWS_SECRET_ACCESS_KEY
export TMPL_AWS_SECRET_ACCESS_KEY="${TMPL_AWS_SECRET_ACCESS_KEY}"

echo -n "Reading secrets from \`notifications-credentials\` ... "
export TMPL_MMG_API_KEY=$(pass credentials/mmg | tail -n 6 | grep "API key" | cut -d" " -f3)
export TMPL_FIRETEXT_API_KEY=$(pass credentials/firetext | tail -n 6 | grep "API key" | cut -d" " -f3)
export TMPL_ZENDESK_API_KEY=$(pass credentials/preview/paas/environment-variables|grep ZENDESK_API_KEY|cut -d" " -f2|tr -d '"')
echo -e "Done.\n"

mkdir -p private

echo -n "Generating private/local-aws-creds.env ... "
cat local-aws-creds.env.tmpl | envsubst > private/local-aws-creds.env
echo "Done."

for service in \
  "antivirus-api" \
  "document-download-api" \
  "document-download-frontend" \
  "notify-admin" \
  "notify-api" \
  "template-preview-api"
do
  echo -n "Generating private/${service}.env ... "
  cat ${service}.env.tmpl | envsubst > private/${service}.env
  echo "Done."
done
