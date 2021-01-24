/*
 * Copyright (c) 2021 Manexim (https://github.com/manexim)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
 */

public class Insomnia.MainWindow : Gtk.ApplicationWindow {
    private Gtk.HeaderBar headerbar;
    private Gtk.Label title_label;

    private bool timer_started;
    private int seconds_left = 0;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            icon_name: Constants.APP_ID,
            resizable: false,
            title: Constants.APP_NAME,
            height_request: 400,
            width_request: 400
        );
    }

    construct {
        get_style_context ().add_class ("rounded");

        headerbar = new Gtk.HeaderBar () {
            show_close_button = true
        };
        headerbar.get_style_context ().add_class ("default-decoration");

        var menu_widget = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL,
            margin = 12
        };

        var hidden_button = new Gtk.RadioButton.with_label (null, "") {
            active = true
        };
        var inactive_button = new Gtk.RadioButton.with_label (hidden_button.get_group (), Constants.INACTIVE_STRING) {
            active = Application.seconds_to_inhibit == Constants.INACTIVE_SECONDS
        };
        var 5min_button = new Gtk.RadioButton.with_label (hidden_button.get_group (), Constants.5_MIN_STRING) {
            active = Application.seconds_to_inhibit == Constants.5_MIN_SECONDS
        };
        var 10min_button = new Gtk.RadioButton.with_label (hidden_button.get_group (), Constants.10_MIN_STRING) {
            active = Application.seconds_to_inhibit == Constants.10_MIN_SECONDS
        };
        var 15min_button = new Gtk.RadioButton.with_label (hidden_button.get_group (), Constants.15_MIN_STRING) {
            active = Application.seconds_to_inhibit == Constants.15_MIN_SECONDS
        };
        var 30min_button = new Gtk.RadioButton.with_label (hidden_button.get_group (), Constants.30_MIN_STRING) {
            active = Application.seconds_to_inhibit == Constants.30_MIN_SECONDS
        };
        var 45min_button = new Gtk.RadioButton.with_label (hidden_button.get_group (), Constants.45_MIN_STRING) {
            active = Application.seconds_to_inhibit == Constants.45_MIN_SECONDS
        };
        var 1hour_button = new Gtk.RadioButton.with_label (hidden_button.get_group (), Constants.1_HOUR_STRING) {
            active = Application.seconds_to_inhibit == Constants.1_HOUR_SECONDS
        };
        var 2hours_button = new Gtk.RadioButton.with_label (hidden_button.get_group (), Constants.2_HOURS_STRING) {
            active = Application.seconds_to_inhibit == Constants.2_HOURS_SECONDS
        };
        var indefinitely_button = new Gtk.RadioButton.with_label (hidden_button.get_group (), Constants.INDEFINITELY_STRING) {
            active = Application.seconds_to_inhibit < 0
        };

        inactive_button.toggled.connect (button_toggled_cb);
        5min_button.toggled.connect (button_toggled_cb);
        10min_button.toggled.connect (button_toggled_cb);
        15min_button.toggled.connect (button_toggled_cb);
        30min_button.toggled.connect (button_toggled_cb);
        45min_button.toggled.connect (button_toggled_cb);
        1hour_button.toggled.connect (button_toggled_cb);
        2hours_button.toggled.connect (button_toggled_cb);
        indefinitely_button.toggled.connect (button_toggled_cb);

        menu_widget.add (inactive_button);
        menu_widget.add (5min_button);
        menu_widget.add (10min_button);
        menu_widget.add (15min_button);
        menu_widget.add (30min_button);
        menu_widget.add (45min_button);
        menu_widget.add (1hour_button);
        menu_widget.add (2hours_button);
        menu_widget.add (indefinitely_button);
        menu_widget.show_all ();

        var menu = new Gtk.Popover (null);
        menu.add (menu_widget);

        var app_menu = new Gtk.MenuButton () {
            image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR),
            tooltip_text = Constants.MENU_STRING,
            popover = menu
        };

        headerbar.pack_end (app_menu);

        set_titlebar (headerbar);

        var grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };

        title_label = new Gtk.Label ("") {
            use_markup = true
        };
        title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);

        grid.add (title_label);

        add (grid);
    }

    private void update () {
        if (Application.seconds_to_inhibit < 0) {
            title_label.label = Constants.ACTIVE_STRING;

            Inhibitor.get_instance ().inhibit ();
        } else if (seconds_left > 0) {
            int hours = seconds_left / 3600;
            int minutes = (seconds_left - (3600 * hours)) / 60;
            int seconds = seconds_left - (3600 * hours) - (minutes * 60);

            title_label.label = "<span font_features='tnum'>%02d:%02d:%02d</span>".printf (hours, minutes, seconds);

            Inhibitor.get_instance ().inhibit ();
        } else {
            title_label.label = Constants.INACTIVE_STRING;

            Inhibitor.get_instance ().uninhibit ();
        }
    }

    public void start_timer (int seconds) {
        seconds_left = seconds;

        if (timer_started) return;

        timer_started = true;
        Timeout.add_seconds_full (Priority.DEFAULT, 1, ()=> {
            update ();

            if (seconds_left > 0) {
                seconds_left--;
            }

            return true;
        });
    }

    private void button_toggled_cb (Gtk.ToggleButton button) {
        switch (button.get_label ()) {
            case Constants.INACTIVE_STRING:
                Application.seconds_to_inhibit = Constants.INACTIVE_SECONDS;
                break;
            case Constants.5_MIN_STRING:
                Application.seconds_to_inhibit = Constants.5_MIN_SECONDS;
                break;
            case Constants.10_MIN_STRING:
                Application.seconds_to_inhibit = Constants.10_MIN_SECONDS;
                break;
            case Constants.15_MIN_STRING:
                Application.seconds_to_inhibit = Constants.15_MIN_SECONDS;
                break;
            case Constants.30_MIN_STRING:
                Application.seconds_to_inhibit = Constants.30_MIN_SECONDS;
                break;
            case Constants.45_MIN_STRING:
                Application.seconds_to_inhibit = Constants.45_MIN_SECONDS;
                break;
            case Constants.1_HOUR_STRING:
                Application.seconds_to_inhibit = Constants.1_HOUR_SECONDS;
                break;
            case Constants.2_HOURS_STRING:
                Application.seconds_to_inhibit = Constants.2_HOURS_SECONDS;
                break;
            case Constants.INDEFINITELY_STRING:
                Application.seconds_to_inhibit = Constants.INDEFINITELY_SECONDS;
                break;
        }

        start_timer (Application.seconds_to_inhibit);
    }
}
