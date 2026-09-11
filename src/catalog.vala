public class PackageInfo : Object {
    public string attr { get; set; }
    public string pname { get; set; }
    public string version { get; set; }
    public string description { get; set; }
    public string url { get; set; }
    public string homepage { get; set; }
    public string position { get; set; }

    public PackageInfo (string attr, string pname, string version, string description, string url, string homepage = "", string position = "") {
        this.attr = attr; this.pname = pname; this.version = version;
        this.description = description; this.url = url; this.homepage = homepage; this.position = position;
    }

    public static PackageInfo from_json (Json.Object item) {
        var attr = member_string (item, "attr", member_string (item, "name", "unknown"));
        var pname = member_string (item, "pname", attr.substring (attr.last_index_of (".") + 1));
        return new PackageInfo (attr, pname, member_string (item, "version", ""), member_string (item, "description", "No description provided."), member_string (item, "homepage", ""), member_string (item, "homepage", ""), member_string (item, "position", ""));
    }

    private static string member_string (Json.Object item, string name, string fallback) {
        if (!item.has_member (name)) return fallback;
        var node = item.get_member (name);
        return node.get_value_type () == typeof (string) ? node.get_string () : fallback;
    }
}

public class Catalog : Object {
    public Gee.ArrayList<PackageInfo> packages = new Gee.ArrayList<PackageInfo> ();

    public Catalog (string path) throws Error {
        var parser = new Json.Parser ();
        parser.load_from_file (path);
        var root = parser.get_root ().get_object ();
        root.foreach_member ((obj, name, node) => {
            var item = node.get_object ();
            packages.add (new PackageInfo (
                item.get_string_member ("attr"), item.get_string_member ("pname"),
                item.get_string_member ("version"),
                item.has_member ("description") && !item.get_member ("description").is_null () ? item.get_string_member ("description") : "No description provided.",
                item.get_string_member ("url")));
        });
    }

    public Gee.ArrayList<PackageInfo> search (string query, int limit = 100) {
        var result = new Gee.ArrayList<PackageInfo> ();
        var q = query.strip ().down (); 
        foreach (var item in packages) {
            if (q.length == 0 || item.attr.down ().contains (q) || item.pname.down ().contains (q) || item.description.down ().contains (q)) {
                result.add (item);
                if (result.size >= limit) break;
            }
        }
        return result;
    }
}
