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
LC_POOL_NAME="TICKR"
LC_POOL_ID="your_pool_id"
LC_POOL_PORT="6000"
#
# ---- The following defaults should be ok when using cntools
#
LC_POOL_VRF="/opt/cardano/cnode/priv/pool/${LC_POOL_NAME}/vrf.skey"
LC_POOL_BYRON_GEN="/opt/cardano/cnode/files/byron-genesis.json"
LC_POOL_SHELLEY_GEN="/opt/cardano/cnode/files/shelley-genesis.json"
LC_POOL_SOCKET="/opt/cardano/cnode/sockets/node0.socket"
LC_CNCLI_BIN="${HOME}/.cargo/bin/cncli"
LC_CNCLI_DB="/opt/cardano/cnode/guild-db/cncli/cncli.db"
LC_CARDANOCLI_BIN="${HOME}/.cabal/bin/cardano-cli"
#
# ---- Do not edit the code below
#
export CARDANO_NODE_SOCKET_PATH=$LC_POOL_SOCKET
echo "## Syncing cncli database for ${LC_POOL_NAME} pool..."
$LC_CNCLI_BIN sync --host 127.0.0.1 --port $LC_POOL_PORT --db $LC_CNCLI_DB --no-service
echo "## Querying stake snapshot for ${LC_POOL_NAME} pool..."
LC_SNAPSHOT=`$LC_CARDANOCLI_BIN query stake-snapshot --stake-pool-id $LC_POOL_ID --mainnet`
LC_POOL_STAKE=$(echo "$LC_SNAPSHOT" | grep -oP '(?<=    "poolStakeMark": )\d+(?=,?)')
LC_ACTIVE_STAKE=$(echo "$LC_SNAPSHOT" | grep -oP '(?<=    "activeStakeMark": )\d+(?=,?)')
echo "## Executing cncli leaderlog for ${LC_POOL_NAME} pool..."
LC_POOL=`$LC_CNCLI_BIN leaderlog --pool-id $LC_POOL_ID --pool-vrf-skey $LC_POOL_VRF --db $LC_CNCLI_DB --byron-genesis $LC_POOL_BYRON_GEN --shelley-genesis $LC_POOL_SHELLEY_GEN  --pool-stake $LC_POOL_STAKE --active-stake $LC_ACTIVE_STAKE --ledger-set next`
EPOCH=`jq .epoch <<< $LC_POOL`
SLOTS=`jq .epochSlots <<< $LC_POOL`
IDEAL=`jq .epochSlotsIdeal <<< $LC_POOL`
PERFORMANCE=`jq .maxPerformance <<< $LC_POOL`
echo " POOL:${LC_POOL_NAME} EPOCH:${EPOCH} SLOTS:${SLOTS} PERFORMANCE:${PERFORMANCE} IDEAL:${IDEAL}"
echo "## Complete cncli leaderlog ouput:"
echo $LC_POOL
