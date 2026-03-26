#!/usr/bin/env bash
set -euo pipefail

VERSION="$1"
SCHEME="voca play"
WORKDIR=$(mktemp -d ./ios-test-XXXX)
trap 'rm -rf "$WORKDIR"' EXIT

git clone git@github.com-CI:ORG/REPO.git "$WORKDIR"
cd "$WORKDIR"

# 1. Собираем проект (билд для симулятора)
xcodebuild \
  -scheme "$SCHEME" \
  -sdk iphonesimulator \
  -configuration Debug \
  build

# 2. Обновляем версию
xcrun agvtool new-marketing-version "$VERSION"
BUILD_NUMBER=$(date +%s)   # или можно передавать параметром
xcrun agvtool new-version -all "$BUILD_NUMBER"

# 3. Коммитим
git status --short
git commit -am "Increased app version to $VERSION"
git push origin HEAD
