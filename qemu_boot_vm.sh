#!/bin/bash

# Installition CD
# If injected, booting in SETUP_MODE
CD="cd.iso"
CD_INJECTED=false


# If true, connects main drive instead of snapshot drive
# connects virtual network device to provide Internet access
# and creates a snapshot after shutting VM down
SETUP_MODE=false

for ARG in "$@"; do
	case "$ARG" in
		cd) CD_INJECTED=true ;;
		setup) SETUP_MODE=true ;;
	esac
done

# A drive system to be installed 
# Will be auto-created 
DRIVE="hd.qcow2"
SNAPSHOT_DRIVE="hd_snapshot.qcow2"
DRIVE_DEFAULT_SIZE="15G"

# Port forwarding
GDB_PORT_HOST=12344
SSH_PORT_HOST=2222

echo "Port forwarding:"
echo -e "\tgdb localhost:$GDB_PORT_HOST (:1234 guest)"
echo -e "\tssh localhost:$SSH_PORT_HOST (:22 guest)"

if [[ ! -f "$DRIVE" ]]; then
	qemu-img create -f qcow2 "$DRIVE" "$DRIVE_DEFAULT_SIZE"
	CD_INJECTED=true
fi

ACCEL=""
case "$(uname)" in
	[Dd]arwin) ACCEL="-accel hvf" ;;
	[Ll]inux) ACCEL="-accel kvm" ;;
	*) echo "Unknown system type, running without acceleration" ;;
esac;

if [[ "$CD_INJECTED" == true ]]; then 
	echo "CD Injected"
	SETUP_MODE=true
	CD_OPTION="-cdrom $CD"
fi

INSTALLED_DRIVE="$SNAPSHOT_DRIVE"
if [[ "$SETUP_MODE" == true ]]; then
	echo "Setup mode enabled"
	
	NIC_OPTION="-nic user,model=virtio-net-pci"
	INSTALLED_DRIVE="$DRIVE"
	
	rm "$SNAPSHOT_DRIVE"
fi
	
qemu-system-x86_64 \
  $CD_OPTION \
  -drive "file=$INSTALLED_DRIVE,format=qcow2" \
  $ACCEL \
  -m 1G \
  -smp 1 \
  -vga vmware \
  $NIC_OPTION \
  -device e1000,netdev=net0 \
  -netdev user,id=net0,hostfwd=tcp::"$SSH_PORT_HOST"-:22,hostfwd=tcp::"$GDB_PORT_HOST"-:1234 \
  -serial pty \
;

if [[ "$SETUP_MODE" == true ]]; then
	qemu-img create -f qcow2 -b "$DRIVE" "$SNAPSHOT_DRIVE"
fi 
	

