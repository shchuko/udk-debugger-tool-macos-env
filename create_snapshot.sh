#!/bin/bash

DRIVE="hd.qcow2"
SNAPSHOT_DRIVE="hd_snapshot.qcow2"

rm "$SNAPSHOT_DRIVE"
qemu-img create -f qcow2 -b "$DRIVE" "$SNAPSHOT_DRIVE"

