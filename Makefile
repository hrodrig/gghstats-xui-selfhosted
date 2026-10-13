# gghstats-xui-selfhosted — same gitflow as gghstats-selfhosted (PR-only).
#
#   topic (feature|fix|chore|docs|security/<name>)
#     → PR → develop
#     → (ship) PR develop → main
#     → annotated tag vX.Y.Z on main
#
# Never: git push origin develop | git push origin main
# Never: local merge onto main — use gh pr

.DEFAULT_GOAL := help

GREEN  := \033[0;32m
YELLOW := \033[0;33m
RESET  := \033[0m

VERSION_RAW ?= $(shell cat VERSION 2>/dev/null | tr -d '\n\r')
VERSION     := $(patsubst v%,%,$(VERSION_RAW))
TAG         := v$(VERSION)

CHART_DIR ?= run/kubernetes/helm/gghstats-xui
COMPOSE_FILE ?= run/docker-compose/minimal/docker-compose.yml

.PHONY: help release-check gitflow compose-config helm-lint

help:
	@echo "$(GREEN)gghstats-xui-selfhosted$(RESET) — Compose / Helm for gghstats-xui"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "$(YELLOW)Quality:$(RESET)"
	@echo "  $(GREEN)release-check$(RESET)   compose-config + helm-lint (when helm present)"
	@echo "  $(GREEN)compose-config$(RESET)  docker compose config (needs docker + dummy env)"
	@echo "  $(GREEN)helm-lint$(RESET)       helm lint / template chart (optional if helm missing)"
	@echo ""
	@echo "$(YELLOW)Gitflow (gghstats-selfhosted mold):$(RESET)"
	@echo "  $(GREEN)gitflow$(RESET)         Print canonical branch/PR/tag sequence"
	@echo ""
	@echo "Repo VERSION: $(VERSION) (tag: $(TAG))"
	@echo ""
	@echo "Hard rules:"
	@echo "  - Topic branches from develop; PR into develop"
	@echo "  - Never push/commit directly to develop or main"
	@echo "  - Ship: PR develop → main, then tag v* on main (user OK)"
	@echo "  - No uat"
	@echo "  - Pin GGHSTATS_XUI_VERSION / GGHSTATS_VERSION separately from repo VERSION"

compose-config:
	@command -v docker >/dev/null 2>&1 || { echo "docker required for compose-config"; exit 1; }
	@tmpdir=$$(mktemp -d); \
	cp run/common/.env.example "$$tmpdir/.env"; \
	sed -i.bak \
	  -e 's|^GGHSTATS_HOST_DATA=.*|GGHSTATS_HOST_DATA='"$$tmpdir"'|' \
	  -e 's|^GGHSTATS_GITHUB_TOKEN=.*|GGHSTATS_GITHUB_TOKEN=dummy|' \
	  -e 's|^GGHSTATS_API_TOKEN=.*|GGHSTATS_API_TOKEN=dummy|' \
	  "$$tmpdir/.env" 2>/dev/null || true; \
	docker compose --env-file "$$tmpdir/.env" -f $(COMPOSE_FILE) config >/dev/null; \
	rm -rf "$$tmpdir"; \
	echo "compose config OK ($(COMPOSE_FILE))"

helm-lint:
	@if ! command -v helm >/dev/null 2>&1; then \
	  echo "helm not found — skip helm-lint"; \
	  exit 0; \
	fi
	helm lint $(CHART_DIR)
	helm template test-release $(CHART_DIR) >/dev/null
	@echo "helm lint + template OK ($(CHART_DIR))"

release-check: compose-config helm-lint
	@echo "release-check passed (repo VERSION $(VERSION))"

gitflow:
	@echo "$(GREEN)gghstats-xui-selfhosted gitflow$(RESET) (same as gghstats-selfhosted)"
	@echo ""
	@echo "1.  git fetch && git checkout develop && git pull --ff-only"
	@echo "2.  git checkout -b feature|fix|chore|docs|security/<short-name>"
	@echo "3.  edits + approved commit(s)"
	@echo "4.  git push -u origin HEAD   # topic only"
	@echo "5.  gh pr create --base develop"
	@echo "6.  CI green → merge PR → delete topic branch"
	@echo "7.  git checkout develop && git pull --ff-only"
	@echo ""
	@echo "    STOP unless user asked to ship / release / pin."
	@echo ""
	@echo "    VERSION bump = solo PR chore/release-X.Y.Z → develop"
	@echo "    App pin     = topic PR for GGHSTATS_XUI_VERSION / GGHSTATS_VERSION"
	@echo ""
	@echo "8.  gh pr create --base main --head develop   # user OK"
	@echo "9.  CI green → merge (do NOT delete develop)"
	@echo "10. checkout main, pull --ff-only"
	@echo "11. git tag -a $(TAG) -m \"gghstats-xui-selfhosted $(VERSION)\" && git push origin $(TAG)"
	@echo "12. back to develop; PR main→develop if histories diverged"
