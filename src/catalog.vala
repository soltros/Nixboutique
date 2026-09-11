public class PackageInfo : Object {
    public string attr { get; set; }
    public string pname { get; set; }
    public string version { get; set; }
    public string description { get; set; }
    public string url { get; set; }

    public PackageInfo (string attr, string pname, string version, string description, string url) {
        this.attr = attr; this.pname = pname; this.version = version;
        this.description = description; this.url = url;
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
