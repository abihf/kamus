
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


