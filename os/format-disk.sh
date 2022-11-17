#!/usr/bin/env nix-shell
#! nix-shell -i bash -p parted gptfdisk dosfstools e2fsprogs f2fs-tools cryptsetup

set -u

ROOT=/mnt-2
FORMAT=
MOUNT=
UNMOUNT=
CRYPT=
FS=btrfs

while getopts "d:r:mufCF:" opt; do
        case "$opt" in
        d)
                DEVICE="$OPTARG"
                ;;
        r)
                ROOT="$OPTARG"
                ;;
        m)
                MOUNT=1
                ;;
        u)
                UNMOUNT=1
                ;;
        f)
                FORMAT=1
                ;;
        C)
                CRYPT=1
                ;;
        F)
                FS="$OPTARG"
                ;;
        h | '?')
                echo "See $BASH_SOURCE"
                exit 1
                ;;
        esac
done

set -x

error() {
    echo "$*" > /dev/stderr
    exit 1
}

check_if_mounted() {
        if mount | grep "$DEVICE"; then
                echo >&2 "$DEVICE is mounted"
                exit 1
        fi
}

PART_ESP=00000000-0000-0000-0000-000000000000
PART_SYSTEM=11111111-1111-1111-1111-111111111111
ID_SYSTEM="aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
ID_ESP=FFFF-FFFF
CRYPT_LABEL=luks-system

CRYPT_DEV=/dev/disk/by-partuuid/"$PART_SYSTEM"
BTRFS_DEVICE=
if [ "$CRYPT" ]; then
        BTRFS_DEVICE=/dev/mapper/"${CRYPT_LABEL}"
else
        BTRFS_DEVICE=/dev/disk/by-uuid/"${ID_SYSTEM}"
fi

crypt_close() {
        if [ "$CRYPT" ]; then
                cryptsetup close "$CRYPT_LABEL"
        fi
}

crypt_format() {
        if [ "$CRYPT" ]; then
                cryptsetup -q luksFormat /dev/disk/by-partuuid/"$PART_SYSTEM" secret/root-key
        fi
        sleep 3
}

crypt_open() {
    if cryptsetup isLuks "$CRYPT_DEV"; then
        cryptsetup -q open --key-file=secret/root-key "$CRYPT_DEV" "$CRYPT_LABEL"
    else
        error "Not LUKS: $CRYPT_DEV"
    fi
}

root_mount() {
        mount -t tmpfs none "$ROOT"
        mkdir --parent "$ROOT"/nix/var
        mkdir --parent "$ROOT"/nix/store
        mkdir --parent "$ROOT"/boot
        mkdir --parent "$ROOT"/etc/nixos
}
root_unmount() {
        umount "$ROOT"
}

btrfs_prepare() {
        if [ "$CRYPT" ]; then
                mkfs.btrfs "$BTRFS_DEVICE" -f -U "${ID_SYSTEM^^}"
        else
                mkfs.btrfs /dev/disk/by-partuuid/"$PART_SYSTEM" -f -U "${ID_SYSTEM^^}"
        fi

        sleep 3

        ROOT_VOLUME=/tmp/btrfs-root-volume
        mkdir -p "$ROOT_VOLUME"

        mount -o ssd,compress=zstd "$BTRFS_DEVICE" "$ROOT_VOLUME"

        btrfs subvolume create "$ROOT_VOLUME/nix-store"
        btrfs subvolume create "$ROOT_VOLUME/gnu-store"
        btrfs subvolume create "$ROOT_VOLUME/nix-var"
        btrfs subvolume create "$ROOT_VOLUME/user"

        umount "$ROOT_VOLUME"
}

btrfs_mount() {
        mkdir --parent "$ROOT"/etc/nixos
        mkdir --parent "$ROOT"/boot
        mkdir --parent "$ROOT"/home
        mkdir --parent "$ROOT"/nix/store
        mkdir --parent "$ROOT"/gnu/store
        mkdir --parent "$ROOT"/nix/var
        mount -o subvol=nix-store,ssd,compress=zstd "$BTRFS_DEVICE" "$ROOT"/nix/store
        mount -o subvol=gnu-store,ssd,compress=zstd "$BTRFS_DEVICE" "$ROOT"/gnu/store
        mount -o subvol=nix-var,ssd,compress=zstd "$BTRFS_DEVICE" "$ROOT"/nix/var
        mount -o subvol=user,ssd,compress=zstd "$BTRFS_DEVICE" "$ROOT"/user

}
btrfs_unmount() {
        umount "$ROOT"/home
        umount "$ROOT"/etc/nixos
        umount "$ROOT"/nix/store
        umount "$ROOT"/nix/var
}

boot_prepare() {
        mkfs.fat /dev/disk/by-partuuid/"$PART_ESP" -I -i "${ID_ESP//-/}"
}
boot_mount() {
        mount /dev/disk/by-partuuid/"$PART_ESP" "$ROOT"/boot
}
boot_unmount() {
        umount "$ROOT"/boot
}

storage_prepare() {
        case "$FS" in
        btrfs)
                btrfs_prepare
                ;;
        xfs)
                xfs_prepare
                ;;
        *)
                echo "Unknown fs: $FS"
                exit
                ;;
        esac
}

storage_mount() {
        case "$FS" in
        btrfs)
                btrfs_mount
                ;;
        xfs)
                xfs_mount
                ;;
        *)
                echo "Unknown fs: $FS"
                exit
                ;;
        esac

}

storage_unmount() {
        case "$FS" in
        btrfs)
                btrfs_unmount
                ;;
        xfs)
                xfs_unmount
                ;;
        *)
                echo "Unknown fs: $FS"
                exit
                ;;
        esac
}

xfs_prepare() {
        RAW_DEVICE=
        if [ "$CRYPT" ]; then
                RAW_DEVICE="$BTRFS_DEVICE"
        else
                RAW_DEVICE=/dev/disk/by-partuuid/"$PART_SYSTEM"
        fi
        mkfs.xfs "$RAW_DEVICE" -f -m uuid="${ID_SYSTEM^^}"
}
xfs_mount() {
        mount "$BTRFS_DEVICE" "$ROOT/nix"
}

xfs_unmount() {
        umount "$ROOT/nix"
}

if [ "$FORMAT" ]; then
        check_if_mounted
        dd if=/dev/zero of="$DEVICE" bs=512 count=10

        parted -s "$DEVICE" mklabel gpt
        parted -a optimal "$DEVICE" mkpart primary fat16 1MiB 512MiB
        parted -a optimal "$DEVICE" mkpart primary ext2 512MiB 100%

        sgdisk --partition-guid=1:"$PART_ESP" "$DEVICE"
        sgdisk --partition-guid=2:"$PART_SYSTEM" "$DEVICE"

        parted "$DEVICE" name 1 msdos
        parted "$DEVICE" set 1 esp on
        parted "$DEVICE" name 2 system

        crypt_format
        crypt_open
        boot_prepare
        storage_prepare

        sleep 3
        crypt_close
fi

if [ "$MOUNT" ]; then
        check_if_mounted
        crypt_open
        root_mount
        storage_mount
        boot_mount
fi

if [ "$UNMOUNT" ]; then
        boot_unmount
        storage_unmount
        root_unmount
        crypt_close
fi
