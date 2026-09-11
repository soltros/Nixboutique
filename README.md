# Nixboutique

An early GTK4/Vala desktop browser for NixOS applications, backed by
[nixpkger](https://github.com/soltros/nixpkger).

Licensed under GPLv3-or-later.

The bundled NixOS package summary provides the initial catalog and offline
fallback. Once `nixpkger` is available, searches of two or more characters are
sent to `nixpkger search --json` so the result list and detail pane use live Nix
metadata (description, version, homepage, and source position when available).
Installation, removal, updates, snapshots, categories, and configuration-file
selection remain delegated to nixpkger.

Settings includes an “Allow non-free packages” switch. When enabled, it is
persisted and passed through to nixpkger for live search and rebuild operations.

Nixpkger is required for package actions. If it is not found at startup,
Nixboutique opens setup instructions for the latest release and Git install.

## Run from soltros_nixpkgs

The supported distribution path is the package in
[`soltros_nixpkgs`](https://github.com/soltros/soltros_nixpkgs):

```sh
nix run github:soltros/soltros_nixpkgs#nixboutique
```

Use `NIXBOUTIQUE_CATALOG=/path/to/nixos_packages_summary.json` to point the app
at another catalog.
