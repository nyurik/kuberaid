#!/usr/bin/env bash
set -euo pipefail

function assert_mounted() {
  local disk="$1"
  local device="$2"
  if ! (lsblk | grep -q "^$device.*/mnt/disks/$disk"); then
    echo "$device is not mounted as /mnt/disks/$disk, assuming this is not the first run, or we had a failure"
    exit 0
  fi
}

function unmount_disk() {
  local disk="$1"
  umount "/mnt/disks/$disk"
  rmdir "/mnt/disks/$disk"
}

function main() {
  if [[ -n "${VERBOSE:-}" ]]; then
    echo "--- lsblk ---"
    lsblk
    echo "--- disk usage ---"
    df -h | grep -E '(ssd|nvme|md)'
  fi

  assert_mounted ssd0 sdb
  assert_mounted ssd1 sdc
  assert_mounted ssd2 sdd

  umount_disk ssd0
  umount_disk ssd1
  umount_disk ssd2

  local ret_code
  ret_code=$(
    yes | mdadm --create /dev/md0 --force --level=0 --raid-devices=3 /dev/sdb /dev/sdc /dev/sdd
    echo $?
  )

  case $ret_code in
    0) ;;
    141)
      echo "mdadm failed with a known error ${ret_code}, ignoring..."
      ;;
    *)
      echo "mdadm failed with error ${ret_code}, aborting"
      exit 0  # prevent pod restart
      ;;
  esac

  mkfs.ext4 -F /dev/md0
  mkdir -p /mnt/disks/localssd
  # Possibly need "nobarrier" ?
  mount /dev/md0 /mnt/disks/localssd -o discard,defaults,nofail
  chmod a+w /mnt/disks/localssd
}

main
