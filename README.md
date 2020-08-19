# UDK Debugger Tool macOS environment

There's no UDK Debugger Tool binaries to be executed on macOS natively, this repo provides a solution to run the tool under Linux VM

Scheme: 

```TARGET <-pty-> socat <-pty-> LINUX GUEST <-serial-> UDK Debugger Tool <-tcp-> GDB``` 

## Setup notes

1. Download your favourite Linux distribution iso (ex. Ubuntu), place it into scripts directory and rename to cd.iso

3. Install QEMU

3. Run ```./qemu_boot_vm.sh```, complete guest installition, install UDK Debugger tool, connect it to COM1, baud rate 115200

4. Install other necessary utilities (gdb, openssh-server, screen, telnet, etc.)

5. Shutdown the VM. After shutting down the snapshot will be created, next boots gonna use it (hd_snapshot.qcow2 instead of hd.qcow2)

6. To make some edits on root image (hd.qcow2), run ```./qemu_boot_vm.sh setup```, after execution snaphot will be re-created from changed image

7. To forcely connect CD, run ```qemu_boot_vm.sh cd```, it will connect CD and boot in setup mode (no. 6). Or just remove *.qcow2 files for pure installition

## Debug Example (QEMU target example)

1. Run setted up debugger VM, make UDK Debugger Tool listening on COM1. Make a point on created pty (ex. /dev/ttys002)

2. Run target QEMU VM, providing an option ```-serial pty``` (it will create device ex. /dev/ttys003). Stop its booting at statring phase (Pause, Reset)

3. Run ```./connect_ttys.sh /dev/ttys003 /dev/ttys002```, whis devices paths created in steps 1,2

4. Resume target VM executing, UDK Debugger Tool will handle it. 

5. Connect to the tool using GDB (connecting from host accepted, because of port forwarding), etc.

## xHyve notes

Same algorithm to QEMU target debugging.
To make target VM wait, use this trick:

```bash
xhyve <SOME_OPTIONS> \
	-s 6,lpc -l com1,autopty \
    	-s 7,fbuf,tcp=127.0.0.1:29000,w=1024,h=768,wait
```

Make a point on pci devices' numbers. PTY will be initialized, and after that VM pauses waiting for 
VNC connection. Run ```./connect_ttys.sh```, and after connect to VM via VNC. 
VM resumes execution and UDK Debugger Tool handles it

## Problems

- In come cases UDK Debugger tool will crash with exception.

- Under xHyve the target not handles any debugger commands at all ¯\_(ツ)_/¯ 

