#!/bin/bash

#
# Sifnode entrypoint.
#

set -x

. /sifnode/test/integration/vagrantenv.sh
. ${TEST_INTEGRATION_DIR}/shell_utilities.sh

ADD_VALIDATOR_TO_WHITELIST=${1:-${ADD_VALIDATOR_TO_WHITELIST}}
shift

if [ -z "${ADD_VALIDATOR_TO_WHITELIST}" ]
then
  # no whitelist validator requested; mostly useful for testing validator whitelisting
  echo $0: no whitelisted validators
else
  whitelisted_validator=$(yes $VALIDATOR1_PASSWORD | sifnodecli keys show -a --bech val $MONIKER --home $CHAINDIR/.sifnodecli)
  echo $0: whitelisted validator $whitelisted_validator
  sifnoded add-genesis-validators $whitelisted_validator --home $CHAINDIR/.sifnoded
  # need a new account to be the administrator
  adminuser=$(yes | sifnodecli keys add sifnodeadmin --keyring-backend test -o json 2>&1 | jq -r .address)
  #{"name":"fnord","type":"local","address":"sif10ckfjtdmk9zkcs9fhl0h260xsj6kvg7esmyqrw","pubkey":"sifpub1addwnpepqtd7ysjyu9aynhemqe9sanmlest8y6dvg24aqzknfmp2ppp7cmxlkc7y8lz","mnemonic":"exact below syrup slender party witness already lamp inform dash impose ginger sauce shift tag humble awkward spawn blue flower lab census gold girl"}
  set_persistant_env_var SIFCHAIN_ADMIN_ACCOUNT $adminuser $envexportfile
  sifnoded add-genesis-account $adminuser 100000000000000000000rowan --home $CHAINDIR/.sifnoded
  sifnoded set-genesis-oracle-admin $adminuser --home $CHAINDIR/.sifnoded
fi

sifnoded start --minimum-gas-prices 0.5rowan --rpc.laddr tcp://0.0.0.0:26657 --home $CHAINDIR/.sifnoded
