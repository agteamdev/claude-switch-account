# Store listing — ready-to-paste copy (addons.mozilla.org)

The fields of the submission form, filled in. Copy them across as-is.

---

## Listing

### Name

```
Private Account Switcher for Claude
```

> "Claude" is an Anthropic trademark, so the name reads as a third-party tool
> ("… for Claude") and the description says it is not affiliated.

### Summary

```
Save several claude.ai sessions and switch accounts in one click. Local only, no tracking, open source.
```

### Description

```
Keep several claude.ai accounts side by side and switch between them in one click — no logging out and back in every time.

Not affiliated with, endorsed by, or connected to Anthropic.

HOW IT WORKS

claude.ai keeps you signed in through cookies. This extension saves those cookies per profile, so switching account is just restoring the right set:

1. Log into an account on claude.ai, then click "Save current session".
2. Click "New login" and sign into another account, then save that one too.
3. Both accounts now sit in the list. One click switches between them.

Each profile is labelled automatically with the account name and e-mail, so you always know which one is active.

FEATURES

• One-click switching between saved accounts
• Automatic account name and e-mail detection
• Open claude.ai tabs reload themselves after a switch
• Rename, delete and reorder profiles (drag and drop)
• Export and import your profiles, optionally encrypted with a password
• "New login" clears the session without touching your saved profiles
• Available in English, French, German, Spanish, Italian, Portuguese, Ukrainian and Russian

PRIVACY

Everything stays on your device. No server, no analytics, no tracking, no third party, no remote code. The only network request made is to the claude.ai API, using the cookies already in your browser, to read the account name shown in the list.

Session cookies are stored in the extension's local storage, the same way your browser already stores its own cookies. Deleting a profile erases them immediately; uninstalling removes everything. Export writes a file only when you click Export; with a password it is encrypted in your browser, without one it contains the cookies in plain text.

GOOD TO KNOW

One account is active per browser profile at a time — this is switching, not running several accounts simultaneously. For simultaneous sessions, use separate browser profiles (or Firefox containers).

Full source code, auditable: https://github.com/agteamdev/claude-switch-account
```

### Categories

`Privacy & Security`, `Tabs`

### License

`MIT`

### Privacy policy

Paste the text of `PRIVACY.md`, or link it:

```
https://github.com/agteamdev/claude-switch-account/blob/main/PRIVACY.md
```

### Support site

```
https://github.com/agteamdev/claude-switch-account/issues
```

---

## Notes for reviewers

```
Plain JavaScript. The package only copies the source files and rewrites manifest.json
for Firefox (tools/build.sh, see the README); no minification, no remote code, no analytics.

Purpose: keep several claude.ai logins and switch between them. The extension saves the
claude.ai / anthropic.com session cookies of the user's own logged-in session into
browser.storage.local and writes them back when the user clicks an account. Nothing is
sent to any third party.

Permissions:
- cookies + host permissions for claude.ai and anthropic.com: read and restore the
  session cookies (the only thing the extension manages).
- storage: save the profiles locally.
- tabs: reload open claude.ai tabs after a switch; open the popup page in a tab for
  Import on Firefox (the toolbar popup closes when a file picker opens).

Network: one request, to claude.ai with the user's own cookies, to read the name and
e-mail of the signed-in account so the profile can be labelled. No other requests.

Export / Import: the user can write the profiles to a JSON file and read it back. The
file can be encrypted in the browser with a password (AES-256-GCM, key from
PBKDF2-SHA-256, 600,000 iterations, random salt and IV). The password is never stored.

To test without a real account: Export / Import, drag-and-drop ordering and the password
dialog work without logging in; switching accounts needs a claude.ai session.

Based on https://github.com/Smeagolworms4/claude-switch-account (MIT).
```
