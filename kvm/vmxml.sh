NUM=1
VM_NAME=vm111-$NUM

MAC1=$(printf '52:54:00:%02X:%02X:%02X\n' $[RANDOM%256] $[RANDOM%256] $[RANDOM%256])
MAC2=$(printf '52:54:00:%02X:%02X:%02X\n' $[RANDOM%256] $[RANDOM%256] $[RANDOM%256])

MNINF=vm$NUM-mgmt-port
INF1=vm$NUM-eth1
INF2=vm$NUM-eth2
VNC_PORT=$((NUM * 2 + 6000 ))

apt-get -y install uuid > /dev/null
UUID=$(uuid)

cat > $VM_NAME.xml << EOF
<domain type="kvm">
  <uuid>$UUID</uuid>
  <name>$VM_NAME</name>
  <memory>1048576</memory>
  <vcpu>1</vcpu>
  <os>
    <type arch='x86_64'>hvm</type>
    <boot dev="hd"/>
  </os>
  <features>
    <acpi/>
    <apic/>
  </features>
  <cputune>
    <shares>1024</shares>
  </cputune>
  <clock offset="utc"/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
  <cpu mode="host-model" match="exact">
    <topology sockets="1" cores="1" threads="1"/>
  </cpu>
  <devices>
    <disk type="file" device="disk">
      <driver name="qemu" type="qcow2" cache="none"/>
      <source file="/var/lib/libvirt/images/$VM_NAME.img"/>
      <target bus="virtio" dev="vda"/>
    </disk>
    <interface type="network">
      <target dev='$MNINF'/>
      <model type="virtio"/>
      <source network="br-mgmt"/>
      <driver name="qemu"/>
    </interface>
    <interface type="bridge">
      <virtualport type='openvswitch'>
      </virtualport>
      <target dev='$INF1'/>
      <model type="virtio"/>
      <source bridge="br-int"/>
      <driver name="qemu"/>
    </interface>
    <interface type="bridge">
      <virtualport type='openvswitch'>
      </virtualport>
      <target dev='$INF2'/>
      <model type="virtio"/>
      <source bridge="br-ex"/>
      <driver name="qemu"/>
    </interface>
    <serial type="file">
      <source path="/var/lib/libvirt/console.log"/>
    </serial>
    <console type="pty">
      <target type="serial" port="0"/>
    </console>
    <serial type="pty"/>
    <input type="tablet" bus="usb"/>
    <graphics type="vnc" port="$VNC_PORT" autoport="no" keymap="en-us" listen="0.0.0.0"/>
    <video>
      <model type="cirrus"/>
    </video>
    <memballoon model="virtio">
      <stats period="10"/>
    </memballoon>
  </devices>
</domain>
EOF
