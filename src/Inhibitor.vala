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

[DBus (name = "org.freedesktop.ScreenSaver")]
public interface Insomnia.ScreenSaverIface : Object {
    public abstract uint32 inhibit (string app_name, string reason) throws Error;
    public abstract void un_inhibit (uint32 cookie) throws Error;
}

public class Insomnia.Inhibitor : Object {
    private const string IFACE = "org.freedesktop.ScreenSaver";
    private const string IFACE_PATH = "/ScreenSaver";

    private static Inhibitor? instance = null;

    private uint32? inhibit_cookie = null;

    private ScreenSaverIface? screensaver_iface = null;

    private bool inhibited = false;

    private Inhibitor () {
        try {
            screensaver_iface = Bus.get_proxy_sync (BusType.SESSION, IFACE, IFACE_PATH, DBusProxyFlags.NONE);
        } catch (Error e) {
            warning ("Could not start screensaver interface: %s", e.message);
        }
    }

    public static Inhibitor get_instance () {
        if (instance == null) {
            instance = new Inhibitor ();
        }

        return instance;
    }

    public void inhibit () {
        if (screensaver_iface != null && !inhibited) {
            try {
                inhibited = true;
                inhibit_cookie = screensaver_iface.inhibit (Constants.APP_ID, Constants.INHIBIT_STRING);
                debug ("Inhibiting screen");
            } catch (Error e) {
                warning ("Could not inhibit screen: %s", e.message);
            }
        }
    }

    public void uninhibit () {
        if (screensaver_iface != null && inhibited) {
            try {
                inhibited = false;
                screensaver_iface.un_inhibit (inhibit_cookie);
                debug ("Uninhibiting screen");
            } catch (Error e) {
                warning ("Could not uninhibit screen: %s", e.message);
            }
        }
    }
}
