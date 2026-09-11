public class Nixpkger : Object {
    public signal void finished (string message, bool success);
    public signal void auth_finished (string message, bool success);
    public string command { get; set; default = "nixpkger"; }
    public string config_dir { get; set; default = ""; }
    public string apps_file { get; set; default = ""; }
    public string module_file { get; set; default = ""; }
    public string flake { get; set; default = ""; }
    public string category { get; set; default = ""; }
    public bool impure { get; set; default = false; }

    public bool is_available () {
        return Environment.find_program_in_path (command) != null;
    }

    public void install (PackageInfo package) { var packages = new Gee.ArrayList<PackageInfo> (); packages.add (package); install_many (packages); }
    public void remove (PackageInfo package) { var packages = new Gee.ArrayList<PackageInfo> (); packages.add (package); remove_many (packages); }
    public void install_many (Gee.ArrayList<PackageInfo> packages) { run_packages ("install", packages); }
    public void remove_many (Gee.ArrayList<PackageInfo> packages) { run_packages ("remove", packages); }
    public void update () { run ("update"); }
    public void update_soltros () { run_with_args ("update", { "--source", "soltros" }); }
    public void list () { run ("list"); }
    public void add_category () { if (category.length > 0) run_with_args ("add-category", { category }); }
    public void list_category () { if (category.length > 0) run_with_args ("list-categories", { category }); }
    public void snapshot () { run ("snapshot"); }
    public void backup () { run ("backup"); }
    public void gc () { run ("gc"); }
    public void restore (string path) { run_with_args ("restore", { path }); }

    private void run_packages (string action, Gee.ArrayList<PackageInfo> packages) {
        var args = new Gee.ArrayList<string> (); foreach (var package in packages) args.add (package.attr); run_with_args (action, args.to_array ());
    }

    public void authenticate (string password) {
        try {
            string[] argv = { "sudo", "-S", "-v" };
            var process = new Subprocess.newv (argv, SubprocessFlags.STDIN_PIPE | SubprocessFlags.STDOUT_PIPE | SubprocessFlags.STDERR_PIPE);
            process.communicate_utf8_async.begin (password + "\n", null, (obj, res) => {
                try {
                    string? stdout; string? stderr;
                    process.communicate_utf8_async.end (res, out stdout, out stderr);
                    auth_finished (process.get_successful () ? "Administrator access granted." : (stderr ?? "sudo authentication failed."), process.get_successful ());
                } catch (Error e) { auth_finished (e.message, false); }
            });
        } catch (Error e) { auth_finished (e.message, false); }
    }

    private void run (string action) { run_with_args (action, {}); }

    private void run_with_args (string action, string[] trailing) {
        try {
            var args = new Gee.ArrayList<string> (); args.add (command);
            if (config_dir.length > 0) { args.add ("--config-dir"); args.add (config_dir); }
            if (apps_file.length > 0) { args.add ("--apps-file"); args.add (apps_file); }
            if (module_file.length > 0) { args.add ("--module-file"); args.add (module_file); }
            if (flake.length > 0) { args.add ("--flake"); args.add (flake); }
            if (impure) args.add ("--impure");
            args.add (action); if (category.length > 0 && (action == "install" || action == "remove" || action == "update")) { args.add ("--category"); args.add (category); } foreach (var argument in trailing) args.add (argument);
            string[] argv = args.to_array ();
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
