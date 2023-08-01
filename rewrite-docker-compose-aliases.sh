sed -i.bak "s/notify-api.localhost/${TMPL_NOTIFY_API_HOSTNAME}/g" docker-compose.yml
sed -i.bak "s/notify.localhost/${TMPL_NOTIFY_ADMIN_HOSTNAME}/g" docker-compose.yml
sed -i.bak "s/template-preview-api.localhost/${TMPL_NOTIFY_TEMPLATE_PREVIEW_HOSTNAME}/g" docker-compose.yml
sed -i.bak "s/document-download-api.localhost/${TMPL_DOCUMENT_DOWNLOAD_API_HOSTNAME}/g" docker-compose.yml
sed -i.bak "s/document-download-frontend.localhost/${TMPL_DOCUMENT_DOWNLOAD_FRONTEND_HOSTNAME}/g" docker-compose.yml
sed -i.bak "s/antivirus-api.localhost/${TMPL_NOTIFY_ANTIVIRUS_API_HOSTNAME}/g" docker-compose.yml

rm -f docker-compose.yml.bak
