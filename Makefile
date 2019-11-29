SHELL=bash
SOURCE_DIR = $(shell pwd)
BIN_DIR = ${SOURCE_DIR}/bin
COMPOSER = composer

define printSection
	@printf "\033[36m\n==================================================\n\033[0m"
	@printf "\033[36m $1 \033[0m"
	@printf "\033[36m\n==================================================\n\033[0m"
endef
define replaceDotenv
	test -f .env.dev.local || cp .env.dev .env.dev.local
	TEMPFILE="$(shell mktemp)" && \
	sed -e 's@^$1=.*@$1=$2@' .env.dev.local > "$$TEMPFILE" && \
	mv "$$TEMPFILE" .env.dev.local
endef

.PHONY: all
all: install quality test test-dependencies

.PHONY: ci
ci: quality test test-dependencies

.PHONY: install
install: clean-vendor composer-install

.PHONY: quality
quality: git-commit-checker cs-ci

.PHONY: test
test: atoum

.PHONY: test-dependencies
test-dependencies: sf-security-checker composer-source-checker

# Coding Style

.PHONY: cs
cs:
	${BIN_DIR}/php-cs-fixer fix --dry-run --stop-on-violation --diff

.PHONY: cs-fix
cs-fix:
	${BIN_DIR}/php-cs-fixer fix

.PHONY: cs-ci
cs-ci:
	${BIN_DIR}/php-cs-fixer fix --ansi --dry-run --using-cache=no --verbose

#COMPOSER

.PHONY: clean-vendor
clean-vendor:
	$(call printSection,CLEAN-VENDOR)
	rm -rf ${SOURCE_DIR}/vendor

.PHONY: composer-install
composer-install: ${SOURCE_DIR}/vendor/composer/installed.json

${SOURCE_DIR}/vendor/composer/installed.json:
	$(call printSection,COMPOSER INSTALL)
	$(COMPOSER) --no-interaction install --ansi --no-progress --prefer-dist

# CI TOOLS

.PHONY: composer-source-checker
composer-source-checker: ${SOURCE_DIR}/vendor/composer/installed.json ${CI_DIR}
	$(call printSection,COMPOSER SOURCE CHECKER)
	${CI_DIR}/composer-source-checker.sh ${SOURCE_DIR}/vendor/composer/installed.json

# TEST
.PHONY: atoum
atoum:
	$(call printSection,TEST atoum)
	${BIN_DIR}/atoum

