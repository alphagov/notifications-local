# DC_PROFILES ?= ${DC_PROFILES}
# DC_ENV ?= ${DC_ENV}
DC_ANTIVIRUS ?= ANTIVIRUS_ENABLED=0

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: beat
beat:
	$(eval export DC_PROFILES=${DC_PROFILES} --profile beat)
	@true

.PHONY: antivirus
antivirus:
	$(eval export DC_ANTIVIRUS=ANTIVIRUS_ENABLED=1)
	$(eval export DC_PROFILES=${DC_PROFILES} --profile antivirus)
	@true

.PHONY: sms-provider-stub
sms-provider-stub:
	$(eval export DC_SMS_PROVIDER_STUB_MMG=MMG_URL=http://host.docker.internal:6300/mmg)
	$(eval export DC_SMS_PROVIDER_STUB_FIRETEXT=FIRETEXT_URL=http://host.docker.internal:6300/firetext)
	$(eval export DC_PROFILES=${DC_PROFILES} --profile sms-provider-stub)
	@true

ZSCALER_CERT=./docker/zscaler-fix/zscaler-root-ca.pem

.PHONY: export-zscaler-cert
export-zscaler-cert:
	security find-certificate \
		-c "Zscaler Root CA" \
		-p \
		/Library/Keychains/System.keychain \
		> $(ZSCALER_CERT)

.PHONY: verify-zscaler-cert
verify-zscaler-cert:
	openssl x509 \
		-in $(ZSCALER_CERT) \
		-noout \
		-subject \
		-issuer

.PHONY: local-bootstrap
local-bootstrap: export-zscaler-cert verify-zscaler-cert

.PHONY: up
up: local-bootstrap ## Build and start containers after bootstrapping
	${DC_SMS_PROVIDER_STUB_MMG} \
	${DC_SMS_PROVIDER_STUB_FIRETEXT} \
	${DC_ANTIVIRUS} \
	docker compose ${DC_PROFILES} up

.PHONY: stop
stop: beat antivirus sms-provider-stub ## Stop containers without tearing down compose set up
	docker compose ${DC_PROFILES} stop

.PHONY: down
down: beat antivirus sms-provider-stub ## Stop containers and tear down docker compose set up
	docker compose ${DC_PROFILES} down

.PHONY: generate-local-dev-db-fixtures
generate-local-dev-db-fixtures:
	docker exec -it notify-api flask command functional-test-fixtures
	docker cp notify-api:/tmp/functional_test_env.sh ../notifications-functional-tests/environment_local.sh

.PHONY: update-repos
update-repos:
	sh ./update-and-bootstrap-repos.sh

.PHONY: update-repos-and-build
update-repos-and-build: ## Pull repos and rebuild containers from them
	sh ./update-and-bootstrap-repos.sh --build
