#!/usr/bin/env nix-shell
#! nix-shell -i bash -p parted gptfdisk dosfstools e2fsprogs f2fs-tools cryptsetup

set -u

ROOT=/mnt-2
FORMAT=
MOUNT=
UNMOUNT=
CRYPT=
FS=btrfs
LABEL="gpt"

while getopts "d:r:mufCF:L:" opt; do
        case "$opt" in
        L)
                case "$OPTARG" in
                mbr | msdos)
                        LABEL=msdos
                        ;;
                efi | uefi | gpt)
                        LABEL=gpt
                        ;;
                esac
                ;;
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
        echo "$*" >/dev/stderr
        exit 1
}

check_if_mounted() {
        if mount | grep "$DEVICE"; then
                echo >&2 "$DEVICE is mounted"
                exit 1
        fi
}

HOST_ID=0001

LUKS_KEY=secrets/"${HOST_ID}".key

PART_MSDOS_PREFIX=0000"${HOST_ID}"

if [ "$LABEL" = "gpt" ]; then
        PART_BOOT=00000000-0000-0000-"$HOST_ID"-000000000000
        PART_SYSTEM=00000000-0000-0000-"$HOST_ID"-000000000001
elif [ "$LABEL" = "msdos" ]; then
        PART_BOOT="$PART_MSDOS_PREFIX"-01
        PART_SYSTEM="$PART_MSDOS_PREFIX"-02
fi

ID_SYSTEM=00000000-0000-0000-"$HOST_ID"-000000000011
ID_BOOT="$HOST_ID"-0011
CRYPT_LABEL=luks-"$HOST_ID"

CRYPT_DEV=/dev/disk/by-partuuid/"$PART_SYSTEM"
BTRFS_DEVICE=
if [ "$CRYPT" ]; then
        BTRFS_DEVICE=/dev/mapper/"${CRYPT_LABEL}"
else
        BTRFS_DEVICE=/dev/disk/by-uuid/"${ID_SYSTEM}"
fi

if [ "$CRYPT" ] && [ ! -e "$LUKS_KEY" ]; then

        dd if=/dev/urandom of="$LUKS_KEY" count=1 bs=1K
        chmod 400 "$LUKS_KEY"
fi

should_exists() {
        mkdir --parent "$@"
}

crypt_close() {
        if [ "$CRYPT" ]; then
                cryptsetup close "$CRYPT_LABEL"
        fi
}

crypt_format() {
        if [ "$CRYPT" ]; then
                cryptsetup -q luksFormat /dev/disk/by-partuuid/"$PART_SYSTEM" "$LUKS_KEY"
        fi
        sleep 3
}

crypt_open() {
        if cryptsetup isLuks "$CRYPT_DEV"; then
                cryptsetup -q open --key-file="$LUKS_KEY" "$CRYPT_DEV" "$CRYPT_LABEL"
        else
                error "Not LUKS: $CRYPT_DEV"
        fi
}

root_mount() {
        should_exists "$ROOT"
        mount -t tmpfs none "$ROOT"
        should_exists "$ROOT"/nix/var "$ROOT"/nix/store "$ROOT"/boot "$ROOT"/etc/nixos
}

root_unmount() {
        umount "$ROOT"
}

btrfs_subvol_name() {
        local MOUNT_POINT="$1"
        echo "$MOUNT_POINT" | perl -pE 's[^/][];s[/$][];tr[/][-]'
}

btrfs_subvol_create() {
        local ROOT_VOLUME=/tmp/btrfs-root-volume
        mkdir -p "$ROOT_VOLUME"
        mount -o ssd,compress=zstd "$BTRFS_DEVICE" "$ROOT_VOLUME"
        for MOUNT_POINT in "$@"; do
                local SUBVOL_NAME=$(btrfs_subvol_name "$MOUNT_POINT")
                btrfs subvolume create "$ROOT_VOLUME/$SUBVOL_NAME"
        done
        umount "$ROOT_VOLUME"
}

btrfs_subvol_mount() {
        local MOUNT_POINT="$1"
        should_exists "$ROOT"/"$MOUNT_POINT"
        mount -o subvol=$(btrfs_subvol_name "$MOUNT_POINT") "$BTRFS_DEVICE" "$ROOT"/"$MOUNT_POINT"
}

btrfs_prepare() {
        if [ "$CRYPT" ]; then
                mkfs.btrfs "$BTRFS_DEVICE" -f -U "${ID_SYSTEM^^}"
        else
                mkfs.btrfs /dev/disk/by-partuuid/"$PART_SYSTEM" -f -U "${ID_SYSTEM^^}"
        fi

        sleep 3
        btrfs_subvol_create /nix/store
        btrfs_subvol_create /nix/var
        btrfs_subvol_create /user
}

btrfs_mount() {
        should_exists "$ROOT"/etc/nixos "$ROOT"/boot "$ROOT"/home "$ROOT"/nix/store  "$ROOT"/nix/var
        btrfs_subvol_mount /nix/store
        btrfs_subvol_mount /nix/var
        btrfs_subvol_mount /user
}

btrfs_unmount() {
        umount "$ROOT"/home "$ROOT"/etc/nixos "$ROOT"/nix/store "$ROOT"/nix/var "$ROOT"/user
}

boot_prepare() {
    if [ "$LABEL" = "gpt" ]; then
        mkfs.fat /dev/disk/by-partuuid/"$PART_BOOT" -I -i "${ID_BOOT//-/}"
    elif [ "$LABEL" = "msdos" ]; then
        mkfs.ext2 /dev/disk/by-partuuid/"$PART_BOOT"
    else
        error "$LABEL unsupported"
    fi
}

boot_mount() {
        mount /dev/disk/by-partuuid/"$PART_BOOT" "$ROOT"/boot
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

        if [ "$LABEL" = "gpt" ]; then
                parted -s "$DEVICE" mklabel "$LABEL"
                parted -a optimal "$DEVICE" mkpart primary fat16 1MiB 512MiB
                parted -a optimal "$DEVICE" mkpart primary ext2 512MiB 100%

                sgdisk --partition-guid=1:"$PART_BOOT" "$DEVICE"
                sgdisk --partition-guid=2:"$PART_SYSTEM" "$DEVICE"

                parted "$DEVICE" name 1 msdos
                parted "$DEVICE" set 1 esp on
                parted "$DEVICE" name 2 system
        elif [ "$LABEL" = "msdos" ]; then
                parted -s "$DEVICE" mklabel "$LABEL"
                parted -a optimal "$DEVICE" mkpart primary ext2 1MiB 512MiB
                parted -a optimal "$DEVICE" mkpart primary ext2 512MiB 100%

                (
                        echo x                      # Expert mode
                        echo i                      # Change disk indentifier
                        echo 0x"$PART_MSDOS_PREFIX" # New identifier
                        echo r                      # Return
                        echo w                      # Write
                        echo q                      # Quite
                ) | fdisk "$DEVICE"
                parted "$DEVICE" set 1 boot on
                partx "$DEVICE"
        else
                error "$LABEL unsupported"
        fi

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
