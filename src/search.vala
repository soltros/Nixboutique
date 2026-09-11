public class NixSearch : Object {
    public signal void finished (string output, bool success);
    private Soup.Session session = new Soup.Session ();
    private uint request_id = 0;

    public void search (string query, string channel = "26.05") {
        var id = ++request_id;
        var index_channel = channel == "unstable" ? "nixos-unstable" : "nixos-" + channel;
        var body = new Json.Builder ();
        body.begin_object (); body.set_member_name ("from"); body.add_int_value (0); body.set_member_name ("size"); body.add_int_value (100);
        body.set_member_name ("query"); body.begin_object (); body.set_member_name ("multi_match"); body.begin_object ();
        body.set_member_name ("query"); body.add_string_value (query.strip ()); body.set_member_name ("fields"); body.begin_array ();
        foreach (var field in new string[] { "package_attr_name^9", "package_programs^9", "package_mainProgram^9", "package_pname^6", "package_description^1.3", "package_longDescription" }) body.add_string_value (field);
        body.end_array (); body.set_member_name ("type"); body.add_string_value ("best_fields"); body.set_member_name ("fuzziness"); body.add_string_value ("AUTO"); body.end_object (); body.end_object (); body.end_object ();
        var generator = new Json.Generator (); generator.set_root (body.get_root ()); size_t body_length; string body_text = generator.to_data (out body_length);
        var message = new Soup.Message ("POST", "https://search.nixos.org/backend/latest-51-" + index_channel + "/_search");
        message.get_request_headers ().append ("Authorization", "Basic YVdWU0FMWHBadjpYOGdQSG56TDUyd0ZFZWt1eHNmUTljU2g=");
        message.set_request_body_from_bytes ("application/json", new Bytes (body_text.data[0:body_length])); 
        session.send_and_read_async.begin (message, Priority.DEFAULT, null, (obj, res) => {
            try {
                var bytes = session.send_and_read_async.end (res);
                if (id != request_id) return;
                finished (bytes.get_data () != null ? (string) bytes.get_data () : "", message.status_code >= 200 && message.status_code < 300);
            } catch (Error e) { if (id == request_id) finished (e.message, false); }
        });
    }
}
