# DC_PROFILES ?= ${DC_PROFILES}
# DC_ENV ?= ${DC_ENV}
DC_ANTIVIRUS ?= ANTIVIRUS_ENABLED=0

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

.PHONY: up
up:
	${DC_SMS_PROVIDER_STUB_MMG} ${DC_SMS_PROVIDER_STUB_FIRETEXT} ${DC_ANTIVIRUS} docker compose ${DC_PROFILES} up

.PHONY: stop
stop: beat antivirus sms-provider-stub
	docker compose ${DC_PROFILES} stop

.PHONY: down
down: beat antivirus sms-provider-stub
	docker compose ${DC_PROFILES} down
