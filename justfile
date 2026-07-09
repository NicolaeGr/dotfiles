FLAKE_ROOT := `pwd`
FLAKE_ROOT_FILE := ".flake-root.nix"

default:
	@just --list

build: _write-flake-root
	@echo "[+] Building and switching system from {{FLAKE_ROOT}} via nh..."
	FLAKE_ROOT={{FLAKE_ROOT}} nh os switch path:{{FLAKE_ROOT}}

build-boot: _write-flake-root
	@echo "[+] Building system in boot mode from {{FLAKE_ROOT}} via nh..."
	FLAKE_ROOT={{FLAKE_ROOT}} nh os boot path:{{FLAKE_ROOT}}
	@just _ask-reboot

_write-flake-root:
	@new_value='"{{FLAKE_ROOT}}"'; \
	if [ -f "{{FLAKE_ROOT_FILE}}" ] && [ "$$(cat "{{FLAKE_ROOT_FILE}}")" = "$new_value" ]; then \
		exit 0; \
	fi; \
	printf '%s\n' "$new_value" > "{{FLAKE_ROOT_FILE}}"; \
	echo "[+] Updated {{FLAKE_ROOT_FILE}}"

_ask-reboot:
	@echo "[*] Reboot now? (y/N)"
	@read -r answer && { [ "$$answer" = "y" ] || [ "$$answer" = "Y" ]; } && sudo systemctl reboot || echo "[*] Reboot skipped"
