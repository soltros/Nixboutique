public class PackageInfo : Object {
    public string attr { get; set; }
    public string pname { get; set; }
    public string version { get; set; }
    public string description { get; set; }
    public string url { get; set; }
    public string homepage { get; set; }
    public string position { get; set; }
    public string long_description { get; set; }
    public string license { get; set; }
    public string platforms { get; set; }

    public PackageInfo (string attr, string pname, string version, string description, string url, string homepage = "", string position = "") {
        this.attr = attr; this.pname = pname; this.version = version;
        this.description = description; this.url = url; this.homepage = homepage; this.position = position; this.long_description = ""; this.license = ""; this.platforms = "";
    }

    public static PackageInfo from_elastic (Json.Object item) {
        var result = new PackageInfo (member_string (item, "package_attr_name", "unknown"), member_string (item, "package_pname", "unknown"), member_string (item, "package_pversion", ""), member_string (item, "package_description", "No description provided."), member_string (item, "package_homepage", ""), member_string (item, "package_homepage", ""), member_string (item, "package_position", ""));
        result.long_description = clean_description (member_string (item, "package_longDescription", "")); result.platforms = member_array (item, "package_platforms");
        if (item.has_member ("package_license") && item.get_member ("package_license").get_node_type () == Json.NodeType.ARRAY) { var licenses = item.get_array_member ("package_license"); var names = new Gee.ArrayList<string> (); for (uint i = 0; i < licenses.get_length (); i++) names.add (member_string (licenses.get_object_element (i), "fullName", "")); result.license = string.joinv (", ", names.to_array ()); }
        return result;
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

    private static string member_array (Json.Object item, string name) {
        if (!item.has_member (name) || item.get_member (name).get_node_type () != Json.NodeType.ARRAY) return "";
        var values = new Gee.ArrayList<string> (); foreach (var value in item.get_array_member (name).get_elements ()) if (value.get_value_type () == typeof (string)) values.add (value.get_string ()); return string.joinv (", ", values.to_array ());
    }

    private static string clean_description (string value) {
        if (value.length == 0) return value;
        var clean = value.replace ("<rendered-html>", "").replace ("</rendered-html>", "");
        clean = clean.replace ("<p>", "").replace ("</p>", "\n\n").replace ("<br>", "\n").replace ("<br/>", "\n").replace ("<br />", "\n");
        try { clean = new Regex ("<[^>]+>").replace (clean, -1, 0, ""); } catch (Error e) { }
        return clean.replace ("&amp;", "&").replace ("&quot;", "\"").replace ("&#39;", "'").replace ("&lt;", "<").replace ("&gt;", ">").strip ();
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
