public class NixStoreWindow : Gtk.ApplicationWindow {
    private Catalog catalog;
    private Nixpkger nixpkger = new Nixpkger ();
    private Gtk.ListBox package_list = new Gtk.ListBox ();
    private Gtk.Label result_count = new Gtk.Label ("");
    private Gtk.Label detail_title = new Gtk.Label ("Select a package");
    private Gtk.Label detail_description = new Gtk.Label ("Choose an application from the catalog to see its description, package attribute, version, and available actions.");
    private Gtk.Label detail_attr = new Gtk.Label ("");
    private Gtk.Button install_button = new Gtk.Button.with_label ("Install");
    private PackageInfo? selected;

    public NixStoreWindow (Gtk.Application app, Catalog catalog) {
        Object (application: app, title: "Nixboutique", default_width: 1320, default_height: 820);
        var css = new Gtk.CssProvider ();
        css.load_from_resource ("/com/soltros/Nixboutique/style.css");
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        this.catalog = catalog;
        nixpkger.finished.connect ((message, success) => show_status (success ? "✓ " + message : "⚠ " + message));
        set_child (build_ui ());
        search ("");
    }

    private Gtk.Widget build_ui () {
        var root = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        root.append (build_sidebar ());
        var main = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main.append (build_header ());
        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.set_position (590);
        package_list.selection_mode = Gtk.SelectionMode.SINGLE;
        package_list.row_selected.connect ((row) => { if (row != null) select_row (row); });
        var list_scroll = new Gtk.ScrolledWindow (); list_scroll.set_child (package_list); list_scroll.vexpand = true;
        paned.set_start_child (list_scroll); paned.set_end_child (build_detail ()); paned.set_resize_start_child (true);
        main.append (paned); root.append (main); return root;
    }

    private Gtk.Widget build_sidebar () {
        var side = new Gtk.Box (Gtk.Orientation.VERTICAL, 8); side.set_size_request (224, -1); side.add_css_class ("sidebar");
        var brand = new Gtk.Box (Gtk.Orientation.VERTICAL, 1); brand.margin_top = 24; brand.margin_start = 18; brand.margin_bottom = 18;
        var title = new Gtk.Label ("Nixboutique"); title.xalign = 0; title.add_css_class ("brand");
        var subtitle = new Gtk.Label ("NixOS application browser"); subtitle.xalign = 0; subtitle.add_css_class ("brand-subtitle");
        brand.append (title); brand.append (subtitle); side.append (brand);
        foreach (var label in new string[] { "Browse applications", "Installed", "Updates", "Snapshots" }) {
            var button = new Gtk.ToggleButton.with_label (label); button.set_halign (Gtk.Align.FILL); button.add_css_class ("nav-button"); side.append (button);
        }
        var spacer = new Gtk.Box (Gtk.Orientation.VERTICAL, 0); spacer.vexpand = true; side.append (spacer);
        var status = new Gtk.Label ("Local catalog\nNixpkger backend ready"); status.add_css_class ("muted"); status.margin_bottom = 18; side.append (status);
        return side;
    }

    private Gtk.Widget build_header () {
        var header = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 14); header.margin_top = 16; header.margin_bottom = 16; header.margin_start = 20; header.margin_end = 20; header.add_css_class ("content-header");
        var search_entry = new Gtk.SearchEntry (); search_entry.placeholder_text = "Search 144,297 packages by name, attribute, or description"; search_entry.hexpand = true; search_entry.add_css_class ("search"); search_entry.search_changed.connect (() => search (search_entry.text));
        header.append (search_entry); result_count.add_css_class ("muted"); header.append (result_count); return header;
    }

    private Gtk.Widget build_detail () {
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 15); box.add_css_class ("detail"); box.set_size_request (390, -1);
        detail_title.xalign = 0; detail_title.wrap = true; detail_title.add_css_class ("detail-title");
        detail_attr.xalign = 0; detail_attr.wrap = true; detail_attr.add_css_class ("detail-attr");
        detail_description.xalign = 0; detail_description.wrap = true; detail_description.max_width_chars = 48; detail_description.add_css_class ("package-desc");
        install_button.add_css_class ("install"); install_button.set_sensitive (false); install_button.clicked.connect (() => { if (selected != null) nixpkger.install (selected); });
        box.append (detail_title); box.append (detail_attr); box.append (detail_description); box.append (install_button);
        var note = new Gtk.Label ("Actions are delegated to nixpkger and may ask for administrator approval."); note.xalign = 0; note.wrap = true; note.add_css_class ("muted"); box.append (note); return box;
    }

    private void search (string query) {
        while (true) { var row = package_list.get_row_at_index (0); if (row == null) break; package_list.remove (row); }
        var matches = catalog.search (query); result_count.label = "%d results".printf (matches.size);
        foreach (var item in matches) {
            var row = new Gtk.ListBoxRow (); row.set_child (package_row (item)); row.set_data<PackageInfo> ("package", item); package_list.append (row);
        }
    }

    public void show_nixpkger_wizard () {
        if (nixpkger.is_available ()) return;
        var dialog = new Gtk.Window (); dialog.title = "Set up nixpkger"; dialog.transient_for = this; dialog.modal = true; dialog.default_width = 600; dialog.default_height = 420;
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 14); box.margin_top = 24; box.margin_bottom = 24; box.margin_start = 26; box.margin_end = 26;
        var title = new Gtk.Label ("Nixboutique needs nixpkger"); title.xalign = 0; title.add_css_class ("section-title");
        var body = new Gtk.Label ("Nixpkger handles installation, removal, updates, snapshots, and NixOS configuration changes. Install it once, then restart Nixboutique."); body.xalign = 0; body.wrap = true;
        var instructions = new Gtk.Label ("Download and extract the source archive from the latest release, then run sh install.sh inside the extracted directory.\n\nOr install from Git:\n\ngit clone https://github.com/soltros/nixpkger.git\ncd nixpkger\nsh install.sh"); instructions.xalign = 0; instructions.wrap = true; instructions.selectable = true; instructions.add_css_class ("detail-attr");
        var actions = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10); actions.halign = Gtk.Align.END;
        var release = new Gtk.Button.with_label ("Open latest release"); release.clicked.connect (() => { try { AppInfo.launch_default_for_uri ("https://github.com/soltros/nixpkger/releases/latest", null); } catch (Error e) { show_status (e.message); } });
        var close = new Gtk.Button.with_label ("Close"); close.clicked.connect (() => dialog.close ()); actions.append (release); actions.append (close);
        box.append (title); box.append (body); box.append (instructions); box.append (actions); dialog.set_child (box); dialog.present ();
    }

    private Gtk.Widget package_row (PackageInfo item) {
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 3); box.add_css_class ("package-row");
        var top = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8); var name = new Gtk.Label (item.pname); name.xalign = 0; name.hexpand = true; name.add_css_class ("package-name"); var version = new Gtk.Label (item.version); version.add_css_class ("package-version"); top.append (name); top.append (version);
        var desc = new Gtk.Label (item.description); desc.xalign = 0; desc.ellipsize = Pango.EllipsizeMode.END; desc.max_width_chars = 70; desc.add_css_class ("package-desc");
        box.append (top); box.append (desc); return box;
    }

    private void select_row (Gtk.ListBoxRow row) { selected = row.get_data<PackageInfo> ("package"); if (selected == null) return; detail_title.label = selected.pname; detail_attr.label = "pkgs." + selected.attr + "  ·  " + selected.version; detail_description.label = selected.description; install_button.set_sensitive (true); }
    private void show_status (string message) { result_count.label = message; }
}

public class NixStoreApp : Gtk.Application {
    public NixStoreApp () { Object (application_id: "com.soltros.Nixboutique", flags: ApplicationFlags.DEFAULT_FLAGS); }
    protected override void activate () {
        try {
            var path = Environment.get_variable ("NIXBOUTIQUE_CATALOG") ?? find_catalog ();
            var window = new NixStoreWindow (this, new Catalog (path)); window.present ();
            window.show_nixpkger_wizard ();
        } catch (Error e) { critical ("Unable to load catalog: %s", e.message); }
    }

    private string find_catalog () throws Error {
        var candidates = new string[] {
            "nixos_search_rag/nixos_packages_summary.json",
            "data/nixos_packages_summary.json",
            "/usr/share/nixboutique/nixos_packages_summary.json",
            "/run/current-system/sw/share/nixboutique/nixos_packages_summary.json",
            Environment.get_variable ("NIXBOUTIQUE_DATADIR") ?? ""
        };
        foreach (var candidate in candidates) {
            if (candidate.length > 0 && FileUtils.test (candidate, FileTest.EXISTS)) {
                if (candidate.has_suffix (".json")) return candidate;
                var bundled = Path.build_filename (candidate, "nixos_packages_summary.json");
                if (FileUtils.test (bundled, FileTest.EXISTS)) return bundled;
            }
        }
        throw new FileError.NOENT ("Bundled NixOS package catalog not found");
    }
}

int main (string[] args) { var app = new NixStoreApp (); return app.run (args); }
