FLAKE_ROOT := `pwd`
SOPS_FILE := "./secrets.yaml"

default:
  @just --list

rebuild:
	@echo "[+] Rebuilding system (impure)..."
	FLAKE_ROOT={{FLAKE_ROOT}} nh os switch {{FLAKE_ROOT}} -- --impure
	@just post-rebuild

rebuild-trace:
	@echo "[+] Rebuilding system with trace (impure)..."
	FLAKE_ROOT={{FLAKE_ROOT}} nh os switch {{FLAKE_ROOT}} -- --impure --show-trace
	@just post-rebuild

post-rebuild:
	@if git diff --exit-code >/dev/null && git diff --staged --exit-code >/dev/null; then \
		if git tag --points-at HEAD | grep -q buildable; then \
			echo "[*] Current commit already tagged as buildable"; \
		else \
			git tag buildable-"$(date +%Y%m%d%H%M%S)" -m ""; \
			echo "[+] Tagged current commit as buildable"; \
		fi \
	else \
		echo "[!] Working tree dirty, not tagging"; \
	fi

# ===============================
# Flake management
# ===============================
update:
	@echo "[+] Updating flake inputs..."
	nix flake update

rebuild-update: update rebuild

diff:
	@git diff ':!flake.lock'

check:
	@nix flake check --impure --keep-going

check-trace:
	@nix flake check --impure --show-trace

# ===============================
# SOPS & secrets management
# ===============================
sops:
	@echo "[*] Editing {{SOPS_FILE}}..."
	nix-shell -p sops --run "SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt sops {{SOPS_FILE}}"

age-key:
	nix-shell -p age --run "age-keygen"

rekey:
	@echo "[*] Rekeying secrets..."
	cd secrets && ( \
		sops updatekeys -y secrets.yaml && \
		(pre-commit run --all-files || true) && \
		git add -u && (git commit -m 'chore: rekey' || true) && git push \
	)

update-nix-secrets:
	(cd ../nix-secrets && git fetch && git rebase) || true
	nix flake update nix-secrets

check-sops:
	@echo "[*] Checking SOPS activation..."
	@SOPS_LOG=$(journalctl --no-pager --no-hostname --since "10 minutes ago" | tac | awk '!flag; /Starting sops-nix activation/{flag=1};' | tac | grep sops); \
	if [[ ! $SOPS_LOG =~ "Finished sops-nix activation" ]]; then \
		echo "[!] SOPS-nix failed to activate"; \
		echo "$SOPS_LOG"; \
		exit 1; \
	else \
		echo "[+] SOPS-nix activation finished"; \
	fi
