## Setup

HOST ?= example
KEYFILE ?= cryptroot.key
KEYSIZE ?= 4096

config: password configuration.nix

configuration.nix: hosts/${HOST}.nix
	@echo "Generating configuration: HOST=${HOST}"
	ln -s "$<" "$@"

password: .hashedPassword.nix

.hashedPassword.nix:
	echo "\"$$(mkpasswd -m sha-512)\"" > "$@"
	chmod 400 "$@"

${KEYFILE}:
	dd if=/dev/urandom of="$@" bs=1 count=${KEYSIZE}
	@echo "Add keyfile to encrypted volume: cryptsetup luksAddKey $$DEVICE ${KEYFILE}"

initrd.keys.gz: ${KEYFILE}
	find $^ | cpio --quiet -H newc -o | gzip -9 -n > "$@"
	chmod 400 "$@"


## Management

update: sync
	sudo nixos-rebuild switch
	nix-env -u '*'
	home-manager switch
	flatpak update --appstream && flatpak update

outdated: sync
	sudo nixos-rebuild dry-build --upgrade

sync:
	sudo nix-channel --update
	nix-channel --update

clean:
	sudo nix-collect-garbage --delete-older-than 7d
	home-manager expire-generations "-7 days"

wireguard: /etc/nixos/.wireguard.key
	wg genkey > "$@"
	chmod 400 "$@"
