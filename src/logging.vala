public class NixboutiqueLog : Object {
    private static bool debug_enabled () {
        return Environment.get_variable ("NIXBOUTIQUE_DEBUG") == "1";
    }

    private static void write (string level, string message) {
        var timestamp = new DateTime.now_local ().format ("%Y-%m-%d %H:%M:%S");
        stderr.printf ("[%s] [nixboutique] %-5s %s\n", timestamp, level, message);
        stderr.flush ();
    }

    public static void info (string message) { write ("INFO", message); }
    public static void warning (string message) { write ("WARN", message); }
    public static void error (string message) { write ("ERROR", message); }
    public static void debug (string message) { if (debug_enabled ()) write ("DEBUG", message); }
}
