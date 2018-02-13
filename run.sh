#!/bin/sh
# If the file /tmp.nodes doesn't exist set FIRST=0 to indicate that this is the first of these linked nodes to run.
# Otherwise unset FIRST just in case.
[[ ! -f "/tmp/nodes" ]] && FIRST=0 ||

# The following block will run every time a node is run for the first time. If
# docker-compose down is executed, then all files are removed and this will run
# again, as intended. If the containers are simply stopped or restarted using
# docker, then the following block will not run.
if [ ! -f /root/.initialised ]; then
    echo "Initializing new node."

    /geth --datadir "/root/.ethereum/" \
            init /root/genesis.json

    touch /root/.initialised
fi

# Get this node's 'enode url'. Other nodes will use this to connect.
# If this is the first of these conected nodes generate a known enode url from /root/nodekey.txt.
JS="'enode://' + admin.nodeInfo.id + '@' + '$(hostname -i):' + admin.nodeInfo.ports.discovery"
ENODE_URL=$(/geth --datadir /root/.ethereum ${FIRST+ --nodekey "/root/nodekey.txt"} --exec "${JS}" console 2>/dev/null | sed -e 's/^"\(.*\)"$/\1/')
echo ""
echo "ENODE URL: ${ENODE_URL}"
echo ""

echo "Adding this node's  connection details to /tmp/nodes"
echo $ENODE_URL >> /tmp/nodes

# Load any node connection details, filtering out the details for this node.
# -r  - If this option is given, backslash does not act as an escape character.
# The backslash is considered to be part of the line.
# In particular, a backslash-newline pair may not be used as a line continuation.
while read -r LINE; do
    if [ ${LINE} != ${ENODE_URL} ]; then
        BOOTNODES="${LINE},${BOOTNODES}"
    fi
done < /tmp/nodes

echo "Starting geth with bootnodes: ${BOOTNODES%?}"
# ${BOOTNODES:+ --bootnodes "${BOOTNODES%?}"}
# Start this node using any other bootnodes.
# If this is the first node use /root/nodekey.txt to generate our known enode url.
$(/geth --datadir /root/.ethereum ${FIRST+ --nodekey "/root/nodekey.txt" } --networkid 1991 ${BOOTNODES:+ --bootnodes "${BOOTNODES%?}"} --rpc --rpcaddr "0.0.0.0" --rpcapi "admin,eth,debug,miner,net,shh,txpool,personal,web3" --maxpeers 25 )
