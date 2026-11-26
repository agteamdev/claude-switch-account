# Firefox support

`bash tools/build.sh` produces a Firefox package next to the Chrome one
(`dist/firefox-mv3/` and `claude-switch-account-<version>-firefox.zip`). The two
builds differ only in `manifest.json`:

```json
// Chrome
"background": { "service_worker": "background.js", "type": "module" }

// Firefox
"background": { "scripts": ["background.js"], "type": "module" },
"browser_specific_settings": {
  "gecko": {
    "id": "claude-switch-account-private@agteamdev",
    "strict_min_version": "140.0",
    "data_collection_permissions": { "required": ["none"] }
  }
}
```

The `manifest.json` in the source tree carries both sets of keys, so the source
folder also loads directly in either browser; each engine ignores the other's keys.

Firefox has no Manifest V3 service worker: it runs an event page from
`background.scripts`. `background.js` has no imports, so it loads fine both as an
ES module (Chrome) and as a classic script (Firefox).

Every API the extension uses (`cookies`, `storage`, `tabs`, `windows`, `runtime`)
exists in Firefox, and the `chrome.*` namespace is aliased there, callbacks
included.

`strict_min_version` is 140 because `data_collection_permissions` (required by AMO
for new extensions) is not understood by older builds. Dropping that key would
allow older Firefox versions at the cost of an AMO warning.

Import opens the popup page in a tab on Firefox, because the toolbar popup closes
when a file picker opens.

## Testing locally

`web-ext run` does not work against a **snap-packaged** Firefox: snap confinement
blocks the remote debugging port and web-ext fails with `ECONNREFUSED`. Use the
manual route instead.

1. `bash tools/build.sh`
2. Open `about:debugging#/runtime/this-firefox`
3. **Load Temporary Add-on…** → pick `dist/firefox-mv3/manifest.json`
4. The extension stays until Firefox is restarted.

Its console is behind the **Inspect** button on the add-on card, which opens a
dedicated devtools window for the background page, the equivalent of Chrome's
"service worker" link.

With a non-snap Firefox, `npx web-ext run --source-dir dist/firefox-mv3` works.

## Linting

```bash
npx web-ext lint --source-dir dist/firefox-mv3
```

Lint the *built* package, not the source tree, otherwise `tools/` and `docs/`
raise `FLAGGED_FILE_EXTENSION`.

## Publishing to AMO

Manual: addons.mozilla.org → Developer Hub → **Submit a New Add-on** → **On this
site**, upload `claude-switch-account-<version>-firefox.zip`. If asked whether the
code is generated or minified, answer yes and upload
`claude-switch-account-<version>-sources.zip` (the build only copies files and
rewrites `manifest.json`; the README explains how to rebuild).

Automatic (later versions): get API credentials (JWT issuer + secret) at
[addons.mozilla.org/developers/addon/api/key](https://addons.mozilla.org/en-US/developers/addon/api/key/)
and store them as the `AMO_JWT_ISSUER` and `AMO_JWT_SECRET` repository secrets.
The `publish-firefox` job in `.github/workflows/build.yml` then signs and submits
every `v*` tag with the listing metadata from `amo-metadata.json`.

`--channel listed` publishes on AMO; `unlisted` only signs the package for
self-distribution.

## Is it worth it?

Firefox ships **Multi-Account Containers** natively, which solves the same
problem better: several accounts open *simultaneously* in different tabs, where
this extension switches between them one at a time. On Chrome the extension
fills a real gap; on Firefox it competes with a built-in feature and only wins
on convenience: one click in a popup versus managing containers by hand.

One upside: the extension preserves each cookie's `storeId`, which in Firefox
is the container identifier. Switching therefore works inside containers
without extra work.
