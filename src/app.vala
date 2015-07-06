/**
 * This file is part of Kamus
 * Copyright (C) 2015 Abi Hafshin
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Kamus {
  public class Application : Gtk.Application {
    
    public Application () {
		  Object(application_id: "org.hafshin.kamus", flags: ApplicationFlags.FLAGS_NONE);
	  }
	  
	  static int main (string[] args) {
		  var app = new Application();
		  return app.run(args);
	  }
    
    protected override void activate() {
      var window = new Window(this);
      window.show();
    }
    
    protected override void startup () {
		  base.startup ();

		  var menu = new Menu();
		  menu.append ("About", "win.about");
		  menu.append ("Quit", "app.quit");
		  this.app_menu = menu;

		  var quit_action = new SimpleAction ("quit", null);
		  quit_action.activate.connect (this.quit);
		  this.add_action (quit_action);
	  }
  }
}


