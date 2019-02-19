using Granite.Widgets;

namespace ValaTester {
public class App:Granite.Application {

    public static MainWindow window = null;
    public static GLib.Settings settings;

    construct {
        program_name = Constants.APPLICATION_NAME;
        application_id = Constants.APPLICATION_NAME;
        settings = new GLib.Settings (Constants.APPLICATION_NAME);

    }

    protected override void activate () {
        new_window ();
    }

    public void new_window () {
        if (window != null) {
            window.present ();
            return;
        }

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/com/github/bartzaalberg/vala-tester/application.css");
        Gtk.StyleContext.add_provider_for_screen (
            Gdk.Screen.get_default (),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        window = new MainWindow (this);
        go_to_last_saved_position (window);
        go_to_last_saved_size (window);

        window.show_all ();

        change_view_if_no_vala_was_found ();
    }

    public static int main (string[] args) {
        var app = new ValaTester.App ();
        return app.run (args);
    }

    private void go_to_last_saved_position (MainWindow main_window) {
        int window_x, window_y;
        settings.get ("window-position", "(ii)", out window_x, out window_y);
        if (window_x != -1 || window_y != -1) {
            window.move (window_x, window_y);
        }
    }

    private void go_to_last_saved_size (MainWindow main_window) {
        var rect = Gtk.Allocation ();

        settings.get ("window-size", "(ii)", out rect.width, out rect.height);
        window.set_allocation (rect);

        if (settings.get_boolean ("window-maximized")) {
            window.maximize ();
        }
    }

    private void change_view_if_no_vala_was_found () {
        var stack_manager = StackManager.get_instance ();
        var vala_version_manager = ValaVersionManager.get_instance ();
        if (vala_version_manager.no_versions_found ()) {
            stack_manager.get_stack ().visible_child_name = "no-vala-found-view";
        }
    }
}
}

