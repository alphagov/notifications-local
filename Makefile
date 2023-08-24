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

.PHONY: up
up:
	@${DC_ANTIVIRUS} docker-compose ${DC_PROFILES} up

.PHONY: stop
stop:
	docker-compose ${DC_PROFILES} stop
