#!/bin/zsh
set -euo pipefail

project_dir=${0:A:h:h}
build_dir="$project_dir/.build"
app_dir="$project_dir/dist/Token Tea.app"
contents_dir="$app_dir/Contents"

mkdir -p "$build_dir/cache/clang" "$build_dir/cache/swiftpm"
mkdir -p "$build_dir/swiftpm-config" "$build_dir/swiftpm-security"

cd "$project_dir"
CLANG_MODULE_CACHE_PATH="$build_dir/cache/clang" swift build \
  --configuration release \
  --disable-sandbox \
  --cache-path "$build_dir/cache/swiftpm" \
  --config-path "$build_dir/swiftpm-config" \
  --security-path "$build_dir/swiftpm-security"

mkdir -p "$contents_dir/MacOS" "$contents_dir/Resources"
cp "$build_dir/release/TokenTea" "$contents_dir/MacOS/TokenTea"
cp "$project_dir/support/Info.plist" "$contents_dir/Info.plist"

codesign --force --deep --sign - "$app_dir"
echo "$app_dir"
