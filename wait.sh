#!/bin/sh

# The following block will run every time a node is run for the first time. If
# docker-compose down is executed, then all files are removed and this will run
# again, as intended. If the containers are simply stopped or restarted using
# docker, then the following block will not run.
echo "run script"
if [ ! -f /root/.initialised ]; then
    echo "Initializing new node."

    /geth --datadir "/root/.ethereum/" \
         init /root/genesis.json
        #  --networkid 1991 \
    #   --port "30303" \
    #   --maxpeers 3 \
    #   --rpcapi "personal,eth,web3,miner" \
    # echo "First time running node..."

    # geth --datadir /root/.ethereum --password ./account-password.txt account new > ./account.txt

    touch /root/.initialised
fi

# Get this node's 'enode url'. Other nodes will use this to connect.
# JS="'enode://' + admin.nodeInfo.id + '@' + '$(hostname -i):' + admin.nodeInfo.ports.discovery"
# ENODE_URL=$(/geth --datadir /root/.ethereum --exec "${JS}" console 2>/dev/null | sed -e 's/^"\(.*\)"$/\1/')
# echo ""
# echo "ENODE URL: ${ENODE_URL}"
# echo ""

# echo "Adding this node's  connection details to /tmp/nodes"
# echo $ENODE_URL >> /tmp/nodes

# Load any node connection details, filtering out the details for this node.
# -r  - If this option is given, backslash does not act as an escape character.
# The backslash is considered to be part of the line.
# In particular, a backslash-newline pair may not be used as a line continuation.
# while read -r LINE; do
#     if [ ${LINE} != ${ENODE_URL} ]; then
#         BOOTNODES="${LINE},${BOOTNODES}"
#     fi
# done < /root/bootstrap.txt

read -r BOOTNODES < /root/bootnodes.txt
echo "Starting geth with bootnodes: ${BOOTNODES}"

/geth --datadir /root/.ethereum \
     --networkid 1991 \
    #  --password ./account-password.txt \
    #  --verbosity 6 \
     --bootnodes "${BOOTNODES}" \
     --rpc \
    #  --rpccorsdomain "*" \
    #  --nat "none" \
     --rpcaddr "0.0.0.0" \
     --rpcapi "admin,eth,debug,miner,net,shh,txpool,personal,web3" \
     --maxpeers 25
    #  console
    #  --mine \
    #  --minerthreads 1



# /geth --datadir /root/.ethereum \
#      --networkid 1991 \
#      --bootnodes "enode://64988817c946bc44bcc128432237d97da542272c709410cb2a39d7b3ab0ea09840c3f14de9416e316aea1bcae4464db412a4f2d1c90ed703b45189d9e0d064b2@172.18.0.2:30303" \
#      --rpc \
#      --rpcaddr "0.0.0.0" \
#      --rpcapi "admin,eth,debug,miner,net,shh,txpool,personal,web3" \
#      console