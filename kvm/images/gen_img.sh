VM_NAME=vm111-1
CLOUD_INIT=seed.iso
IMG_URL=https://cloud-images.ubuntu.com/xenial/current/
ORG_IMG=xenial-server-cloudimg-amd64-disk1.img
VM_IMG=$VM_NAME.img
CUR_DIR=/root/nsh/kvm/images
IMG_DIR=/var/lib/libvirt/images

WORKER="$(mktemp)" || exit $?
trap "rm -rf '$WORKER'" EXIT

# download image file
[ -e $IMG_DIR/$ORG_IMG ] || wget $IMG_URL/$ORG_IMG -P $IMG_DIR

# create cloud-init data to update hostname and password
if [ ! -e $IMG_DIR/$CLOUD_INIT ]; then
    cat > $IMG_DIR/meta-data << EOF
instance-id: $VM_NAME
local-hostname: $VM_NAME
EOF

    cat > $IMG_DIR/user-data << EOF
#cloud-config
password: root
chpasswd: { expire: False }
ssh_pwauth: True

chpasswd:
  list: |
    root:root
  expire: False
EOF

# copy the org image to the image as the basic image
# [ -e $IMG_DIR/$ORG_IMG ] || yes | cp $CUR_DIR/$ORG_IMG $IMG_DIR

# wrap all cloud-init data to an iso file
    genisoimage  -output $IMG_DIR/$CLOUD_INIT -volid cidata -joliet -rock $IMG_DIR/user-data $IMG_DIR/meta-data
fi

# create a qcow2 VM image
[ -e $IMG_DIR/$VM_IMG ] || qemu-img create -f qcow2 -b $IMG_DIR/$ORG_IMG $IMG_DIR/$VM_IMG

# initial the VM image with the above cloud-init data.
#kvm -curses -m 256 -net nic -net user,hostfwd=tcp::2222-:22 -drive file=$IMG_DIR/$VM_IMG,if=virtio -drive file=$IMG_DIR/$CLOUD_INIT,format=raw,if=virtio &
kvm -curses -m 256 -drive file=$IMG_DIR/$VM_IMG,if=virtio -drive file=$IMG_DIR/$CLOUD_INIT,format=raw,if=virtio &
jobs -p %% > $WORKER
sleep 30s & exit

