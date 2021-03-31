#!/usr/bin/env bash

# borrowed from https://github.com/technosophos/helm-template
# downloadFile downloads the latest binary package and also the checksum
# for that binary.
PROJECT_NAME="helm-unittest"

downloadFile() {
  # Always use version from plugin.yaml for the download url
  DOWNLOAD_URL="https://github.com/rancher/helm-unittest/releases/download/$CATTLE_HELM_UNITTEST_VERSION/$PROJECT_NAME-${OS:-linux}-$ARCH.tgz"
  PLUGIN_TMP_FILE="/tmp/$PROJECT_NAME.tgz"
  echo "Downloading $DOWNLOAD_URL"
  curl -L "$DOWNLOAD_URL" -o "$PLUGIN_TMP_FILE"
}

# installFile verifies the SHA256 for the file, then unpacks and
# installs it.
installFile() {
  HELM_TMP="/tmp/$PROJECT_NAME"
  mkdir -p "$HELM_TMP"
  tar xf "$PLUGIN_TMP_FILE" -C "$HELM_TMP"
  HELM_TMP_BIN="$HELM_TMP/untt"
  echo "Preparing to install into $HELM_PLUGIN_DIR"
  # Use * to also copy the file withe the exe suffix on Windows
  cp "$HELM_TMP_BIN"* "$HELM_PLUGIN_DIR"
  echo "$PROJECT_NAME installed into $HELM_PLUGIN_DIR"
}

# fail_trap is executed if an error occurs.
fail_trap() {
  result=$?
  if [ "$result" != "0" ]; then
    echo "Failed to install $PROJECT_NAME"
    echo "For support, go to https://github.com/kubernetes/helm"
  fi
  exit $result
}

# testVersion tests the installed client to make sure it is working.
testVersion() {
  # To avoid to keep track of the Windows suffix,
  # call the plugin assuming it is in the PATH
  PATH=$PATH:$HELM_PLUGIN_DIR
  untt -h
}

# Execution

#Stop execution on any error
trap "fail_trap" EXIT
set -e
downloadFile
installFile
testVersion
