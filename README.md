# Nixboutique

An early GTK4/Vala desktop browser for NixOS applications, backed by
[nixpkger](https://github.com/soltros/nixpkger).

Licensed under GPLv3-or-later.

The bundled NixOS package summary provides an offline fallback. The primary
search path is the public Elasticsearch-backed search service used by
[search.nixos.org](https://search.nixos.org/packages): searches of two or more
characters return live NixOS package records with descriptions, versions,
licenses, platforms, homepages, and source positions when available. Results
are debounced and stale responses are discarded. `nixpkger` remains the
operations backend for installation, removal, updates, snapshots, categories,
and configuration-file selection.
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

## Terminal diagnostics

When launched from a terminal, Nixboutique writes timestamped lifecycle and
failure diagnostics to stderr. Set `NIXBOUTIQUE_DEBUG=1` for detailed search,
status, and subprocess argument traces:

```sh
NIXBOUTIQUE_DEBUG=1 nixboutique
```

Passwords and command output are never included in debug traces; operation
output remains available in the in-app expandable console.
