FLAKE_ROOT := `pwd`
FLAKE_ROOT_FILE := ".flake-root.nix"

REPO_STATUS := `git status --porcelain`
BUILD_TAG_PREFIX := "build-"

default:
	@just --list

build: _pre_build
	@echo "[+] Building and switching system from {{FLAKE_ROOT}} via nh..."
	@trap 'just _post_build $? true' EXIT; \
	nh os switch path:{{FLAKE_ROOT}}

build-boot: _pre_build
	@echo "[+] Building system in boot mode from {{FLAKE_ROOT}} via nh..."
	@trap 'just _post_build $? true' EXIT; \
	nh os boot path:{{FLAKE_ROOT}}
	@just _ask-reboot

build-vm: _pre_build
	@echo "[+] Building system in VM mode from {{FLAKE_ROOT}} via nh..."
	@trap 'just _post_build $? true' EXIT; \
	nixos-rebuild build-vm --flake {{FLAKE_ROOT}}

check HOST=`hostname`:
	@echo "[+] Checking system for host {{HOST}} from {{FLAKE_ROOT}} via nh..."
	@trap 'just _post_build $? false' EXIT; \
	nh os build path:{{FLAKE_ROOT}} -H {{HOST}}

update:
	@echo "[+] Updating flake inputs for {{FLAKE_ROOT}}..."
	@nix flake update

fmt:
	@echo "[+] Formatting the flake..."
	@nixfmt -

clean:
	@echo "[+] Cleaning build artifacts..."
	@nh clean all

sops-edit FILE="secrets/secrets.yaml":
	@tmp=$(mktemp); \
	just _get-age-key > "$tmp"; \
	SOPS_AGE_KEY_FILE="$tmp" sops {{FILE}}; \
	rm "$tmp"

sops-encrypt FILE:
	@tmp=$(mktemp); \
	just _get-age-key > "$tmp"; \
	SOPS_AGE_KEY_FILE="$tmp" sops -e -i {{FILE}}; \
	rm "$tmp"

sops-decrypt FILE="secrets/secrets.yaml":
	@tmp=$(mktemp); \
	just _get-age-key > "$tmp"; \
	SOPS_AGE_KEY_FILE="$tmp" sops -d {{FILE}}; \
	rm "$tmp"

sops-update-keys FILE="secrets/secrets.yaml":
	@tmp=$(mktemp); \
	just _get-age-key > "$tmp"; \
	SOPS_AGE_KEY_FILE="$tmp" sops updatekeys {{FILE}}; \
	rm "$tmp"

_pre_build:
	@if [ -f "{{FLAKE_ROOT_FILE}}" ] && [ "$(< "{{FLAKE_ROOT_FILE}}")" = '"{{FLAKE_ROOT}}"' ]; then \
		exit 0; \
	fi; \
	printf '%s\n' '"{{FLAKE_ROOT}}"' > "{{FLAKE_ROOT_FILE}}"; \
	git add "{{FLAKE_ROOT_FILE}}"; \
	echo "[+] Updated {{FLAKE_ROOT_FILE}}"

_post_build EXIT_STATUS TAG:
	@if [ -f "{{FLAKE_ROOT_FILE}}" ]; then \
		rm "{{FLAKE_ROOT_FILE}}"; \
		git restore --staged "{{FLAKE_ROOT_FILE}}" 2>/dev/null || true; \
		echo "[+] Removed {{FLAKE_ROOT_FILE}}"; \
	fi; \
	if [ "{{EXIT_STATUS}}" -ne 0 ]; then \
		echo "[!] Command failed; skipping build tag"; \
		exit 0; \
	fi; \
	if [ "{{TAG}}" != "true" ]; then \
		echo "[*] Tagging disabled for this recipe"; \
		exit 0; \
	fi; \
	if [ -n '{{REPO_STATUS}}' ]; then \
		echo "[*] Repo was dirty before build; skipping build tag"; \
		exit 0; \
	fi; \
	if git tag --points-at HEAD | grep -q '^{{BUILD_TAG_PREFIX}}'; then \
		echo "[*] HEAD already has a build tag"; \
		exit 0; \
	fi; \
	TAG_NAME="{{BUILD_TAG_PREFIX}}$(date +%Y-%m-%d-%H%M%S)"; \
	git tag "$TAG_NAME"; \
	echo "[+] Tagged build: $TAG_NAME"

_ask-reboot:
	@echo "[*] Reboot now? (y/N)"
	@read -r answer && { [ "$answer" = "y" ] || [ "$answer" = "Y" ]; } && sudo systemctl reboot || echo "[*] Reboot skipped"

_get-age-key:
	@sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key
