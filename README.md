# Nixboutique

An early GTK4/Vala desktop browser for NixOS applications, backed by
[nixpkger](https://github.com/soltros/nixpkger).

Licensed under GPLv3-or-later.

The first slice uses the local package summary at
`../nixos_search_rag/nixos_packages_summary.json`, searches it offline, and
delegates installation to `nixpkger install <attribute>`. Richer package
records, installed-state detection, removal, updates, and snapshots are the
next backend/UI slices.

## Run

From `/home/derrik`:

```sh
nix develop /home/derrik/Nixboutique
nix run /home/derrik/Nixboutique
```

Use `NIXSTORE_CATALOG=/path/to/nixos_packages_summary.json` to point the app
at another catalog.
