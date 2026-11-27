#!/usr/bin/env bash
# Builds dist/:
#   chrome-mv3/  firefox-mv3/                    unpacked builds (differ only in manifest.json)
#   claude-switch-account-<version>-chrome.zip   Chrome / Brave / Edge package
#   claude-switch-account-<version>-firefox.zip  Firefox package
#   claude-switch-account-<version>-sources.zip  complete sources (addons.mozilla.org asks for them)
# Requires: bash, zip, node.
set -euo pipefail

cd "$(dirname "$0")/.."

for tool in zip node; do
  command -v "$tool" >/dev/null || { echo "error: '$tool' is required" >&2; exit 1; }
done

NAME=claude-switch-account
VERSION="${1:-$(node -p "require('./manifest.json').version")}"

# An MV3 manifest without default_locale breaks every __MSG_*__, so check first.
node -e '
  const m = require("./manifest.json");
  if (!m.default_locale) throw new Error("manifest.default_locale is missing");
  const fs = require("fs");
  for (const l of fs.readdirSync("_locales")) JSON.parse(fs.readFileSync(`_locales/${l}/messages.json`));
  console.log(`manifest v${m.version} ok - locales: ${fs.readdirSync("_locales").join(", ")}`);
'

rm -rf dist
mkdir -p dist

for target in chrome firefox; do
  dir="dist/${target}-mv3"
  mkdir -p "$dir"
  cp -R background.js popup.html popup.css popup.js _locales icons "$dir/"
  find "$dir" -name '.DS_Store' -delete

  # Each browser gets only the manifest keys it understands.
  node -e '
    const fs = require("fs");
    const [target, version, out] = process.argv.slice(1);
    const m = JSON.parse(fs.readFileSync("manifest.json", "utf8"));
    m.version = version;
    if (target === "chrome") {
      delete m.browser_specific_settings;
      delete m.background.scripts;
    } else {
      delete m.background.service_worker;
    }
    fs.writeFileSync(out, JSON.stringify(m, null, 2) + "\n");
  ' "$target" "$VERSION" "$dir/manifest.json"

  (cd "$dir" && zip -r -q "../${NAME}-${VERSION}-${target}.zip" .)
done

# Sources: everything needed to rebuild with `bash tools/build.sh`.
zip -r -q "dist/${NAME}-${VERSION}-sources.zip" . \
  -x 'dist/*' '.git/*' 'node_modules/*' '*.DS_Store'

for f in dist/*.zip; do
  echo "-> $f ($(du -h "$f" | cut -f1))"
done
