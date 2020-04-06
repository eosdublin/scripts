#!/bin/bash
PROPOSER=$1
PROPOSAL_NAME=$2
NEW_ACCOUNT_NAME=$3
NEW_ACCOUNT_OWNER_KEY=$4
NEW_ACCOUNT_ACTIVE_KEY=$5
RAM_BYTES=${6:-4096}
NEW_ACCOUNT_ACTOR=${7:-welcome.xec}
EXPIRATION=${8:-$(date --date='+1 month' +%FT%T)}
DRY_RUN=${9:-1}

CLEOS="cleos --wallet-url http://127.0.0.1:7777 -u http://xec.eosdublin.io"
SPONSOR="welcome.xec"
SPONSOR_PERMISSION="newacc"

MULTISIG_PERMISSIONS=$(cat <<-END
[
	{"actor": "amsterdamsp1", "permission": "active"},
	{"actor": "cryptolions1", "permission": "active"},
	{"actor": "cryptolions2", "permission": "active"},
	{"actor": "cryptolions3", "permission": "active"},
	{"actor": "cryptolions4", "permission": "active"},
	{"actor": "cryptolions5", "permission": "active"},
	{"actor": "dutcheosbp12", "permission": "active"},
	{"actor": "dutcheosbp13", "permission": "active"},
	{"actor": "dutcheosbp14", "permission": "active"},
	{"actor": "dutcheosbp15", "permission": "active"},
	{"actor": "dutcheosiobp", "permission": "active"},
	{"actor": "eosamsterdam", "permission": "active"},
	{"actor": "eosbarcelona", "permission": "active"},
	{"actor": "eosdublinbp2", "permission": "active"},
	{"actor": "eosdublinbp3", "permission": "active"},
	{"actor": "eosdublinbp4", "permission": "active"},
	{"actor": "eosdublinbp5", "permission": "active"},
	{"actor": "eosdublinwow", "permission": "active"},
	{"actor": "factfactfact", "permission": "active"},
	{"actor": "kahunacowboy", "permission": "active"},
	{"actor": "missingparts", "permission": "active"}
]
END
)

BUYRAMBYTES_DATA=$(cat <<-END
{
	"payer": "$SPONSOR",
	"receiver": "$NEW_ACCOUNT_NAME",
	"bytes": $RAM_BYTES
}
END
)

DELEGATEBW_DATA=$(cat <<-END
{
	"from": "$SPONSOR",
	"receiver": "$NEW_ACCOUNT_NAME",
	"stake_net_quantity": "1.0000 XEC",
	"stake_cpu_quantity": "1.0000 XEC",
	"transfer": 1
}
END
)
	
NEWACCOUNT_DATA=$(cat <<-END
{
	"creator": "$SPONSOR",
	"name": "$NEW_ACCOUNT_NAME",
	"owner": {
		"threshold": 1,
		"keys": [{ "key": "$NEW_ACCOUNT_OWNER_KEY", "weight": 1 }],
		"accounts": [],
		"waits": []
	},
	"active": {
		"threshold": 1,
		"keys": [{ "key": "$NEW_ACCOUNT_ACTIVE_KEY", "weight": 1 }],
		"accounts": [],
		"waits": []
	}
}
END
)

BUYRAMBYTES_DATA_PACKED=$($CLEOS convert pack_action_data eosio buyrambytes "$BUYRAMBYTES_DATA")
DELEGATEBW_DATA_PACKED=$($CLEOS convert pack_action_data eosio delegatebw "$DELEGATEBW_DATA")
NEWACCOUNT_DATA_PACKED=$($CLEOS convert pack_action_data eosio newaccount "$NEWACCOUNT_DATA")
REFERENCE_BLOCK_NUMBER=$($CLEOS get info | jq '.head_block_num')
REFERENCE_BLOCK_PREXIX=$($CLEOS get block $REFERENCE_BLOCK_NUMBER | jq '.ref_block_prefix')

TRANSACTION=$(cat <<-END
{
	"expiration": "$EXPIRATION",
	"ref_block_num": $REFERENCE_BLOCK_NUMBER,
	"ref_block_prefix": $REFERENCE_BLOCK_PREXIX,
	"max_net_usage_words": 0,
	"max_cpu_usage_ms": 0,
	"delay_sec": 0,
	"context_free_actions": [],
	"actions": [
		{
			"account": "eosio",
			"name": "newaccount",
			"authorization": [{
				"actor": "$NEW_ACCOUNT_ACTOR",
				"permission": "active"
			}],
			"data": "$NEWACCOUNT_DATA_PACKED"
		},
		{
			"account": "eosio",
			"name": "buyrambytes",
			"authorization": [{
				"actor": "$SPONSOR",
				"permission": "$SPONSOR_PERMISSION"
			}],
			"data": "$BUYRAMBYTES_DATA_PACKED"
		},
		{
			"account": "eosio",
			"name": "delegatebw",
			"authorization": [{
				"actor": "$SPONSOR",
				"permission": "$SPONSOR_PERMISSION"
			}],
			"data": "$DELEGATEBW_DATA_PACKED"
		}
	],
	"transaction_extensions": [],
	"signatures": [],
	"context_free_data": []
}
END
)

ARGS="-j"

if [ "$DRY_RUN" -eq "1" ]; then
	ARGS="${ARGS}ds"
fi

# If passing this through a cleos wrapper, you might need to escape your quotation marks
# TRANSACTION="${TRANSACTION//\"/\\\"}"
# MULTISIG_PERMISSIONS="$(echo "${MULTISIG_PERMISSIONS//\"/\\\"}" | tr -d '[:space:]')"

echo $CLEOS multisig propose_trx "$PROPOSAL_NAME" \"$MULTISIG_PERMISSIONS\" \"$TRANSACTION\" $PROPOSER $ARGS
$CLEOS multisig propose_trx "$PROPOSAL_NAME" "$MULTISIG_PERMISSIONS" "$TRANSACTION" $PROPOSER $ARGS
