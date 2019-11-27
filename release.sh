#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
if [ -f $DIR/.env.sh ]; then
    source $DIR/.env.sh
fi
if which sentry-cli >/dev/null; then
    export SENTRY_ORG=alin-panaitiu
    export SENTRY_PROJECT=lunar
    VERSION=$(sentry-cli releases propose-version)

    # Create a release
    ERROR=$(sentry-cli releases new --finalize -p $SENTRY_PROJECT $VERSION 2>&1 >/dev/null)
    if [ ! $? -eq 0 ]; then
        echo "warning: sentry-cli - $ERROR"
    fi

    # Associate commits with the release
    ERROR=$(sentry-cli releases set-commits --auto $VERSION 2>&1 >/dev/null)
    if [ ! $? -eq 0 ]; then
        echo "warning: sentry-cli - $ERROR"
    fi
else
    echo "warning: sentry-cli not installed, download from https://github.com/getsentry/sentry-cli/releases"
fi