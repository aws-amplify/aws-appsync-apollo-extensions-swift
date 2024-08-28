#!/bin/bash

if [[ -z "${RELEASE_VERSION}" ]]; then
    echo 'Environment Var RELEASE_VERSION is not defined, aborting...'
    exit 1
fi

sed -E -i "s/[[:digit:]]+.[[:digit:]]+.[[:digit:]]+/${RELEASE_VERSION}/" \
    $(pwd)/Sources/AWSAppSyncApolloExtensions/Utilities/PackageInfo.swift
