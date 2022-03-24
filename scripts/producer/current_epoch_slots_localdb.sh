#!/usr/bin/env bash
###############################################################################
## current_epoch_slots_localdb.sh is a wrapper script that uses cardano-cli  ##
## and cncli to synchronize a new database in the local directory to avoid   ##
## using the one used by cntools, and then calculates if the specified       ##
## stake pool is going to be leader for any slot during the current epoch.   ##
##                                                                           ##
## Documentation and the latest version can be found at:                     ##
## https://www.github.com/jmhoms/cndeploy                                    ##
##                                                                           ##
## This code is mainly based on the example provided in cncli documentation: ##
## https://github.com/AndrewWestberg/cncli/blob/develop/USAGE.md             ##
##                                                                           ##
## Copyright (C) 2021 Josep M Homs                                           ##
##                                                                           ##
## This program is free software: you can redistribute it and/or modify it   ##
## under the terms of the GNU General Public License as published by the     ##
## Free Software Foundation, either version 3 of the License, or any later   ##
## version.                                                                  ##
##                                                                           ##
## This program is distributed in the hope that it will be useful, but       ##
## WITHOUT ANY WARRANTY; without even the implied warranty of                ##
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                      ##
## See the GNU General Public License for more details.                      ##
##                                                                           ##
## You should have received a copy of the GNU General Public License along   ##
## with this program. If not, see http://www.gnu.org/licenses/               ##
##                                                                           ##
###############################################################################
#
# ---- Version : 1.0.0
#
# ---- TODO :
# ----- Parameters checks
# ----- Error handling
#
# ---- Parameters
#
ES_POOL_NAME="TICKR"
ES_POOL_ID="your_pool_id"
ES_POOL_PORT="6000"
#
# ---- The following defaults should be ok when using cntools
#
ES_POOL_VRF="/opt/cardano/cnode/priv/pool/${ES_POOL_NAME}/vrf.skey"
ES_POOL_BYRON_GEN="/opt/cardano/cnode/files/byron-genesis.json"
ES_POOL_SHELLEY_GEN="/opt/cardano/cnode/files/shelley-genesis.json"
ES_POOL_SOCKET="/opt/cardano/cnode/sockets/node0.socket"
ES_CNCLI_BIN="${HOME}/.cargo/bin/cncli"
ES_CNCLI_DB="./cncli.db"
ES_CARDANOCLI_BIN="${HOME}/.cabal/bin/cardano-cli"
#
# ---- Do not edit the code below
#
export CARDANO_NODE_SOCKET_PATH=$ES_POOL_SOCKET
echo "## Syncing cncli database for ${ES_POOL_NAME} pool..."
$ES_CNCLI_BIN sync --host 127.0.0.1 --port $ES_POOL_PORT --db $ES_CNCLI_DB --no-service
echo "## Querying stake snapshot for ${ES_POOL_NAME} pool..."
ES_SNAPSHOT=`$ES_CARDANOCLI_BIN query stake-snapshot --stake-pool-id $ES_POOL_ID --mainnet`
ES_POOL_STAKE=$(echo "$ES_SNAPSHOT" | grep -oP '(?<=    "poolStakeSet": )\d+(?=,?)')
ES_ACTIVE_STAKE=$(echo "$ES_SNAPSHOT" | grep -oP '(?<=    "activeStakeSet": )\d+(?=,?)')
echo "## Executing cncli leaderlog for ${ES_POOL_NAME} pool..."
ES_POOL_PARMS="--pool-id $ES_POOL_ID --pool-vrf-skey $ES_POOL_VRF --db $ES_CNCLI_DB "
ES_POOL_PARMS+="--byron-genesis $ES_POOL_BYRON_GEN --shelley-genesis $ES_POOL_SHELLEY_GEN "
ES_POOL_PARMS+="--pool-stake $ES_POOL_STAKE --active-stake $ES_ACTIVE_STAKE --ledger-set current"
ES_POOL=`$ES_CNCLI_BIN leaderlog $ES_POOL_PARMS`
EPOCH=`jq .epoch <<< $ES_POOL`
SLOTS=`jq .epochSlots <<< $ES_POOL`
IDEAL=`jq .epochSlotsIdeal <<< $ES_POOL`
PERFORMANCE=`jq .maxPerformance <<< $ES_POOL`
echo " POOL:${ES_POOL_NAME} EPOCH:${EPOCH} SLOTS:${SLOTS} PERFORMANCE:${PERFORMANCE} IDEAL:${IDEAL}"
echo "## Complete cncli leaderlog ouput:"
echo $ES_POOL
