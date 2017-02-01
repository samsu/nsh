## load the kernel modules
/sbin/modprobe openvswitch

## verify that the modules have been loaded
/sbin/lsmod | grep openvswitch

## Before starting ovs-vswitchd itself, you need to start its configuration 
## database, ovsdb-server. Each machine on which Open vSwitch is installed 
## should run its own copy of ovsdb-server. Before ovsdb-server itself can 
## be started, configure a database that it can use
#ovsdb-tool create /usr/local/etc/openvswitch/conf.db /usr/local/share/openvswitch/vswitch.ovsschema

## Configure ovsdb-server to use database created above, to listen on 
## a Unix domain socket, to connect to any managers specified in the 
## database itself
killall ovsdb-server
ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock \
    --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
    --private-key=db:Open_vSwitch,SSL,private_key \
    --certificate=db:Open_vSwitch,SSL,certificate \
    --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert \
    --pidfile --detach --log-file

## Initialize the database using ovs-vsctl for first time
ovs-vsctl --no-wait init

## Start the main Open vSwitch daemon
killall ovs-vswitchd
ovs-vswitchd --pidfile --detach --log-file

echo "openvswtich started"
echo "check log info at /usr/local/var/log/openvswitch/ovs-vswitchd.log"
