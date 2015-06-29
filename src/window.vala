
namespace Kamus {
  
  [GtkTemplate(ui="/org/hafshin/kamus/window.ui")]
  public class Window : Gtk.ApplicationWindow {
    
    /**
     *  Selected dictionary 
     */
    Dictionary dict;
    
    
    private bool ready = false;
    
    private bool search_error = false;
    
    [GtkChild]
    private Gtk.ListStore word_list;

    [GtkChild]
    private Gtk.TextBuffer definition_buffer;

    [GtkChild]
    private Gtk.SearchEntry search_entry;

    [GtkChild]
    private Gtk.TreeView listview;
    
    [GtkChild]
    private Gtk.Spinner spinner;
    //[GtkChild]
    //
    [GtkChild]
    private Gtk.TreeSelection list_selection;
    
    public Window(Gtk.Application app) {
      Object(application: app, title: "Kamus");
      
      var about_action = new SimpleAction ("about", null);
      about_action.activate.connect (this.on_about_activate);
      this.add_action (about_action);
    }
    
    
    [GtkCallback]
    public void on_show() {
      load_dictionary("en-id");
      search_entry.grab_focus();
    }
    
    private void load_dictionary(string dict_id) {
      load_dictionary_inner.begin(dict_id, (obj, res) => {
        load_dictionary_inner.end(res);
      });
    }

    private async void load_dictionary_inner(string name) {
      //SourceFunc callback = load_dictionary_inner.callback;
      this.ready = false;
      definition_buffer.set_text("Loading dictioanry");
      spinner.start();
      
      dict = null;
      dict = yield DictionaryCollection.get_by_name(name);

      // ThreadFunc<void*> run = () => {
      SourceFunc run = () => {
        Gtk.TreeIter iter;
        list_selection.unselect_all();
        word_list.clear();

        for (int i=0; i< dict.items.length; i++) {
          word_list.append(out iter);
          word_list.set(iter, 0, dict.items[i].word, 1, i);

        }
        // Idle.add((owned) callback);
        
        this.ready = true;
        var path = new Gtk.TreePath.from_indices(0);
        list_selection.select_path(path);
        spinner.stop();
        return false;
      };
      Idle.add(run);
      //Thread.create<void*>(run, false);
      //run();
    }
    
    [GtkCallback]
    public void on_word_selected(Gtk.TreeSelection selection) {
      Gtk.TreeModel model;
		  Gtk.TreeIter iter;
		  uint64 index;
		  if (! this.ready) return;
		  if (selection.get_selected(out model, out iter)) {
		    model.get(iter, 1, out index);
        var item = dict.items[index];
		    definition_buffer.set_text(item.word + "\n\n" + item.definition);
		  }
    }
    
	  [GtkCallback]
	  private void on_dictionary_chooser_changed(Gtk.CheckMenuItem item) {
	    if (!item.active) return;
	    if (item.label == "EN to ID")
        load_dictionary("en-id");
      else if (item.label == "ID to EN")
        load_dictionary("id-en");
	  }
    
    [GtkCallback]
	  private void on_search_changed(Gtk.SearchEntry entry) {
	    if (!this.ready) return;
      if (entry.text.length == 0) {
        search_set_error(false);
        return;
      };
      int index = binary_search(entry.text, 0, dict.items.length, true);
      debug("full bin search: %d\n", index);
      if (index < 0) {
        index = binary_search(entry.text, 0, dict.items.length, false);
        debug("prefixed bin search: %d\n", index);
        if (index > 0) {
          while(str_prefix_cmp(dict.items[index-1].word, entry.text) >= 0) index--;
        }
      }
      if (index >= 0) {
        search_set_error(false);
        var path = new Gtk.TreePath.from_indices(index);
        list_selection.select_path(path);
        listview.scroll_to_cell(path, null, true, 0.5f, 0);
      } else {
        search_set_error(true);
      }
	  }

    private void search_set_error(bool error) {
      if (search_error == error) return;
      if (error) 
        search_entry.get_style_context().add_class("error");
      else
        search_entry.get_style_context().remove_class("error");
      search_error = error;
    }

    private int binary_search(string search, int begin, int end, bool full) {
      if (begin > end) return -1;
      int mid = (begin + end) >> 1;
      string word = dict.items[mid].word;
      int cmp = str_prefix_cmp(word, search, full);
      if (cmp == 0) return mid;
      else if (cmp > 0) return binary_search(search, begin, mid-1, full);
      else return binary_search(search, mid+1, end, full);
    }

    private int str_prefix_cmp(string str1, string str2, bool full = false) {
      int len = str2.length;
      if (str1.length < len) len = str1.length;

      for(int i=0; i<len; i++) {
        int cmp = str1[i] - str2[i];
        if (cmp != 0) return cmp;
      }
      if (full) return str1.length - str2.length;
      else if(str1.length >= str2.length) {
        return 0;
      } else {
        return -1;
      }
    }
	  
    private void on_about_activate() {
	    string[] authors = { "Abi Hafshin <abi@hafs.in>", null };

		  Gtk.show_about_dialog (this, 
                                 "program-name", Config.PACKAGE_NAME,
                                 "version", Config.VERSION,
                                 "copyright", ("Copyright \xc2\xa9 2015 Abi Hafshin"),
                                 "authors", authors,
                                 "website", Config.PACKAGE_URL,
                                 "website-label", ("Homepage"),
                                 "license-type", Gtk.License.GPL_3_0,
                                 "logo-icon-name", "accessories-dictionary",
                                 null);
	  }
	  
  }
}
