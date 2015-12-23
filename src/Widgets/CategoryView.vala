// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
//
//  Copyright (C) 2011-2012 Giulio Collura
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

public class Slingshot.Widgets.CategoryView : Gtk.EventBox {

    private Gtk.Grid container;
    public Sidebar category_switcher;
    public Gtk.Separator separator;
    public Widgets.Grid app_view;
    private SlingshotView view;

    private const string ALL_APPLICATIONS = _("All Applications");
    private const string NEW_FILTER = _("Create a new Filter");
    private const string SWITCHBOARD_CATEGORY = "switchboard";

    private int current_position = 0;

    public Gee.HashMap<int, string> category_ids = new Gee.HashMap<int, string> ();

    public CategoryView (SlingshotView parent) {
        view = parent;
        set_visible_window (false);
        hexpand = true;

        container = new Gtk.Grid ();
        container.hexpand = true;
        container.orientation = Gtk.Orientation.HORIZONTAL;
        separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);

        category_switcher = new Sidebar ();

        app_view = new Widgets.Grid (view.rows, view.columns - 1);

        container.add (category_switcher);
        container.add (separator);
        container.add (app_view);
        add (container);

        connect_events ();
        setup_sidebar ();
    }

    public void setup_sidebar () {
        var old_selected = category_switcher.selected;
        category_ids.clear ();
        category_switcher.clear ();
        app_view.set_size_request (-1, -1);
        // Fill the sidebar
        int n = 0;
        foreach (string cat_name in view.apps.keys) {
            if (cat_name == SWITCHBOARD_CATEGORY)
                continue;

            category_ids.set (n, cat_name);
            category_switcher.add_category (GLib.dgettext ("gnome-menus-3.0", cat_name).dup ());
            n++;
        }
        category_switcher.show_all ();

        int minimum_width;
        category_switcher.get_preferred_width (out minimum_width, null);

        // Because of the different sizes of the column widget, we need to calculate if it will fit.
        int removing_columns = (int)((double)minimum_width / (double)Pixels.ITEM_SIZE);
        if (minimum_width % Pixels.ITEM_SIZE != 0)
            removing_columns++;

        int columns = view.columns - removing_columns;
        app_view.resize (view.rows, columns);

        category_switcher.selected = old_selected;
    }

    private void connect_events () {
        category_switcher.selection_changed.connect ((name, nth) => {
            string category = category_ids.get (nth);
            show_filtered_apps (category);
        });
    }

    private void add_app (Backend.App app) {
        var app_entry = new AppEntry (app);
        app_entry.app_launched.connect (() => view.close_indicator ());
        app_view.append (app_entry);
        app_view.show_all ();

    }

    public void show_filtered_apps (string category) {

        app_view.clear ();
        foreach (Backend.App app in view.apps[category])
            add_app (app);

        current_position = 0;

    }

}
