#!/usr/bin/env bash
###############################################################################
## next_epoch_slots.sh is a wrapper script that uses cardano-cli and cncli   ##
## to calculate if the specified stake pool is going to be leader for any    ##
## slot during the next epoch from 36h before its start.                     ##
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
## version.                                                                  ##
##                                                                           ##
## This program is distributed in the hope that it will be useful, but       ##
## WITHOUT ANY WARRANTY; without even the implied warranty of                ##
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                      ##
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
NES_POOL_NAME="TICKR"
NES_POOL_ID="your_pool_id"
NES_POOL_PORT="6000"
#
# ---- The following defaults should be ok when using cntools
#
NES_POOL_VRF="/opt/cardano/cnode/priv/pool/${NES_POOL_NAME}/vrf.skey"
NES_POOL_BYRON_GEN="/opt/cardano/cnode/files/byron-genesis.json"
NES_POOL_SHELLEY_GEN="/opt/cardano/cnode/files/shelley-genesis.json"
NES_POOL_SOCKET="/opt/cardano/cnode/sockets/node0.socket"
NES_CNCLI_BIN="${HOME}/.cargo/bin/cncli"
NES_CNCLI_DB="/opt/cardano/cnode/guild-db/cncli/cncli.db"
NES_CARDANOCLI_BIN="${HOME}/.cabal/bin/cardano-cli"
#
# ---- Do not edit the code below
#
export CARDANO_NODE_SOCKET_PATH=$NES_POOL_SOCKET
echo "## Syncing cncli database for ${NES_POOL_NAME} pool..."
$NES_CNCLI_BIN sync --host 127.0.0.1 --port $NES_POOL_PORT --db $NES_CNCLI_DB --no-service
echo "## Querying stake snapshot for ${NES_POOL_NAME} pool..."
NES_SNAPSHOT=`$NES_CARDANOCLI_BIN query stake-snapshot --stake-pool-id $NES_POOL_ID --mainnet`
NES_POOL_STAKE=$(echo "$NES_SNAPSHOT" | grep -oP '(?<=    "poolStakeMark": )\d+(?=,?)')
NES_ACTIVE_STAKE=$(echo "$NES_SNAPSHOT" | grep -oP '(?<=    "activeStakeMark": )\d+(?=,?)')
echo "## Executing cncli leaderlog for ${NES_POOL_NAME} pool..."
NES_POOL=`$NES_CNCLI_BIN leaderlog --pool-id $NES_POOL_ID --pool-vrf-skey $NES_POOL_VRF --db $NES_CNCLI_DB --byron-genesis $NES_POOL_BYRON_GEN --shelley-genesis $NES_POOL_SHELLEY_GEN  --pool-stake $NES_POOL_STAKE --active-stake $NES_ACTIVE_STAKE --ledger-set next`
EPOCH=`jq .epoch <<< $NES_POOL`
SLOTS=`jq .epochSlots <<< $NES_POOL`
IDEAL=`jq .epochSlotsIdeal <<< $NES_POOL`
PERFORMANCE=`jq .maxPerformance <<< $NES_POOL`
echo " POOL:${NES_POOL_NAME} EPOCH:${EPOCH} SLOTS:${SLOTS} PERFORMANCE:${PERFORMANCE} IDEAL:${IDEAL}"
echo "## Complete cncli leaderlog ouput:"
echo $NES_POOL
