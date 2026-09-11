public class Nixpkger : Object {
    public signal void finished (string message, bool success);
    public string command { get; set; default = "nixpkger"; }

    public bool is_available () {
        return Environment.find_program_in_path (command) != null;
    }

    public void install (PackageInfo package) { run ("install", package.attr); }
    public void remove (PackageInfo package) { run ("remove", package.attr); }
    public void update () { run ("update"); }
    public void snapshot () { run ("snapshot"); }

    private void run (string action, string? attr = null) {
        try {
            string[] argv;
            if (attr == null) argv = { command, action };
            else argv = { command, action, attr };
            var process = new Subprocess.newv (argv, SubprocessFlags.STDOUT_PIPE | SubprocessFlags.STDERR_MERGE);
            process.communicate_utf8_async.begin (null, null, (obj, res) => {
                try {
                    string? stdout;
                    string? stderr;
                    process.communicate_utf8_async.end (res, out stdout, out stderr);
                    finished (stdout ?? "Operation complete.", process.get_successful ());
                } catch (Error e) { finished (e.message, false); }
            });
        } catch (Error e) { finished (e.message, false); }
    }
}
