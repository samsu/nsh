#!/bin/bash

set -o xtrace

## use a specific folder as the workfolder ($PWD)
W_DIR=/root/nsh/kvm

VM_PREFIX='vm111-'
VM_SEQ=2
IMG_DIR=$W_DIR/images
VM_NAME=$VM_PREFIX$VM_SEQ
IMG_FILE=$IMG_DIR/$VM_NAME
 
# clean current VM data
virsh destroy $VM_NAME
virsh undefine $VM_NAME

# create a nat network for the fgtvm management plane.
BR_MGMT=br-mgmt
MGMT_NET=br-mgmt

# create a nat network for the vm management plane.
brctl show |grep  $BR_MGMT >> /dev/null
if [[ $? -ne 0 ]]; then
    echo "Creating the management bridge"
    cat > $MGMT_NET.xml << EOF
<network>
  <name>$MGMT_NET</name>
  <bridge name="$BR_MGMT"/>
  <forward mode="nat"/>
  <ip address="169.254.254.1" netmask="255.255.255.0">
    <dhcp>
      <range start="169.254.254.100" end="169.254.254.254"/>
    </dhcp>
  </ip>
</network>
EOF
    virsh net-define $MGMT_NET.xml
    virsh net-start $MGMT_NET
    virsh net-autostart $MGMT_NET
fi

# create VM with the updated data
cd $W_DIR
virsh define $VM_NAME.xml
virsh start $VM_NAME

