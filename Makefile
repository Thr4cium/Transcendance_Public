SHELL := /bin/bash

# Auto-detect host IP and hostname for network access
HOST_IP := $(shell hostname -I 2>/dev/null | awk '{print $$1}')
HOST_FQDN := $(shell hostname -f 2>/dev/null)

.DEFAULT_GOAL := up

# Update .env with dynamic HOST_IP and HOST_FQDN
define update_env
	@if [ -n "$(HOST_IP)" ] && [ -f .env ]; then \
		sed -i 's|FRONTEND_URL=https://[^:]*:[0-9]*|FRONTEND_URL=https://$(HOST_IP):8443|g' .env; \
		sed -i 's|ALLOWED_ORIGINS=.*|ALLOWED_ORIGINS=https://$(HOST_IP):8443,https://localhost:8443,https://$(HOST_FQDN):8443|g' .env; \
		echo "✅ Updated .env with HOST_IP=$(HOST_IP), HOST_FQDN=$(HOST_FQDN)"; \
	fi
endef

# Regenerate SSL certs to cover localhost, IP and FQDN
define update_certs
	@if [ -x ./generate-certs.sh ] && { [ ! -d "./certs" ] || [ !  -f "./certs/cert.pem" ] || [ ! -f "./certs/key.pem" ]; }; then \
		./generate-certs.sh "localhost,$(HOST_IP),$(HOST_FQDN)"; \
	fi
endef

define print_addresses
	@echo ""
	@echo "========================================"
	@echo "   🎮 ft_transcendence is running! 🎮   "
	@echo "========================================"
	@echo ""
	@echo "📍 Local access:"
	@echo "   https://localhost:8443"
	@echo ""
	@if [ -n "$(HOST_IP)" ]; then \
		echo "📍 Network access (from other devices):"; \
		echo "   https://$(HOST_IP):8443"; \
		echo "   https://$(HOST_FQDN):8443"; \
		echo ""; \
	fi
	@echo "⚠️  Accept the self-signed certificate in your browser"
	@echo ""
endef

up:
	$(call update_env)
	$(call update_certs)
	HOST_IP=$(HOST_IP) docker compose up --build -d
	$(call print_addresses)

up-attached:
	$(call update_env)
	$(call update_certs)
	HOST_IP=$(HOST_IP) docker compose up --build

down:
	docker compose down

restart:
	docker compose down
	$(call update_env)
	$(call update_certs)
	HOST_IP=$(HOST_IP) docker compose up --build -d
	$(call print_addresses)

address:
	@echo ""
	@echo "========================================"
	@echo "   🎮 ft_transcendence addresses 🎮    "
	@echo "========================================"
	@echo ""
	@echo "📍 Local access:"
	@echo "   https://localhost:8443"
	@echo ""
	@if [ -n "$(HOST_IP)" ]; then \
		echo "📍 Network access (from other devices):"; \
		echo "   https://$(HOST_IP):8443"; \
		echo ""; \
	else \
		echo "⚠️  Could not detect host IP"; \
		echo ""; \
	fi
	@echo "⚠️  Accept the self-signed certificate in your browser"
	@echo ""

fclean:
	docker compose down --rmi all --volumes

aggressivecleanup:
	docker compose down --volumes --remove-orphans || true
	docker images -aq | xargs -r docker rmi -f
	docker system prune -af --volumes

re: fclean up

container:
	docker compose ps

logs:
	docker compose logs -f

userservice-logs:
	docker compose logs -f user-service

gateway-logs:
	docker compose logs -f gateway

gameserver-logs:
	docker compose logs -f game-server

matchmaking-logs:
	docker compose logs -f matchmaking-service

auth-logs:
	docker compose logs -f auth-service

chat-logs:
	docker compose logs -f chat-service

ps:
	docker compose ps

exec:
	docker compose exec backend sh