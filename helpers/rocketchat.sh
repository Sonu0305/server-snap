#!/bin/bash

source $SNAP/helpers/common.sh
source $SNAP/helpers/environment.sh
source $SNAP/helpers/mongo.sh
source $SNAP/helpers/misc.sh

start_rocketchat() {
    init_user_environment_variables

    # absolute musts for rocketchat to start
    export PORT=$(snapctl get port)
    export MONGO_URL=$(snapctl get mongo-url)
    export MONGO_OPLOG_URL=$(snapctl get mongo-oplog-url)
    export ROOT_URL=$(snapctl get siteurl)
    export REG_TOKEN=$(snapctl get reg-token)
	export DENO_DIR="$SNAP_COMMON/.cache/deno"

	if ! [[ -d "$DENO_DIR" ]]; then
		mkdir -pv "$(dirname $DENO_DIR)"
	fi

	if [[ -d "$SNAP/.cache/deno" ]]; then
		cp -vr "$SNAP/.cache/deno" "$DENO_DIR"
	else
		echo "[WARN] deno cache directory not found, apps may not work correctly" >&2
	fi

    # We know that mongodb IS running
    # Let's save the PID someplace
    set -m
    node $SNAP/main.js &
    echo $! > $SNAP_COMMON/rocketchat.pid
    fg
    rm $SNAP_COMMON/rocketchat.pid
}

stop_rocketchat() {
    pkill -9 -F $SNAP_COMMON/rocketchat.pid
}

get_current_migration() {
    mongo_eval "db.getSiblingDb('parties').migrations.findOne().version"
}

migrate_to_latest() {
    export MIGRATION_VERSION=latest,exit
    start_rocketchat
}

