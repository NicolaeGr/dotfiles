FLAKE_ROOT := `pwd`
FLAKE_ROOT_FILE := ".flake-root.nix"

default:
	@just --list

build: _write-flake-root
	@echo "[+] Building and switching system from {{FLAKE_ROOT}} via nh..."
	@trap 'just _remove-flake-root' EXIT; \
	nh os switch path:{{FLAKE_ROOT}}

build-boot: _write-flake-root
	@echo "[+] Building system in boot mode from {{FLAKE_ROOT}} via nh..."
	@trap 'just _remove-flake-root' EXIT; \
	nh os boot path:{{FLAKE_ROOT}}
	@just _ask-reboot

build-vm: _write-flake-root
	@echo "[+] Building system in VM mode from {{FLAKE_ROOT}} via nh..."
	@trap 'just _remove-flake-root' EXIT; \
	nixos-rebuild build-vm --flake {{FLAKE_ROOT}}#zoln

_write-flake-root:
	@new_value='"{{FLAKE_ROOT}}"'; \
	if [ -f "{{FLAKE_ROOT_FILE}}" ] && [ "$$(cat "{{FLAKE_ROOT_FILE}}")" = "$$new_value" ]; then \
		exit 0; \
	fi; \
	printf '%s\n' "$new_value" > "{{FLAKE_ROOT_FILE}}"; \
	git add "{{FLAKE_ROOT_FILE}}"; \
	echo "[+] Updated {{FLAKE_ROOT_FILE}}"

_remove-flake-root:
	@if [ -f "{{FLAKE_ROOT_FILE}}" ]; then \
		rm "{{FLAKE_ROOT_FILE}}"; \
		git restore --staged "{{FLAKE_ROOT_FILE}}" 2>/dev/null ||  true; \
		echo "[+] Removed {{FLAKE_ROOT_FILE}}"; \
	fi

_ask-reboot:
	@echo "[*] Reboot now? (y/N)"
	@read -r answer && { [ "$$answer" = "y" ] || [ "$$answer" = "Y" ]; } && sudo systemctl reboot || echo "[*] Reboot skipped"

remote hostname ip=hostname: _write-flake-root
	@echo "[+] Building and switching {{hostname}} remotely ({{ip}})..."
	@trap 'just _remove-flake-root' EXIT; \
	nixos-rebuild switch \
	  --flake {{FLAKE_ROOT}}#{{hostname}} \
	  --build-host root@{{ip}} \
	  --target-host root@{{ip}}
