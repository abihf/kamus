

namespace Kamus {
    
  public class DictionaryCollection {
    static Gee.HashMap<string, Dictionary> dicts = new Gee.HashMap<string, Dictionary>();

    public static async Dictionary get_by_name(string name) {
      Dictionary dict = dicts.get(name);
      if (dict == null) {
        dict = new Dictionary();
        yield dict.load_from_resource("/org/hafshin/kamus/dicts/" + name + ".dict");
        dicts.set(name, dict);
      }
      return dict;
    }
  } 

  public class Dictionary {
    public DictionaryItem[] items;
  
    public async void load_from_resource(string path) throws Error {
      print("load resource: %s\n", path);
      InputStream stream = resources_open_stream(path,  ResourceLookupFlags.NONE);
      yield this.load_stream(stream);
      // stream.unref();
    }

    public async void load_file(string filename) {
      File file = File.new_for_path(filename);
      InputStream stream = yield file.read_async();
      yield this.load_stream(stream);
    }

    public async void load_stream(InputStream stream){
      DataInputStream dis = new DataInputStream(stream);
      string line;
      var arr = new Array<DictionaryItem>();
      while ((line = yield dis.read_line_async()) != null) {
        if (line != "" && line[0] != '[') {
          string[] arg = line.split("\t", 2);
          var item = new DictionaryItem();
          item.word = arg[0];
          item.definition = arg[1];
          arr.append_val(item);
        }
      }
      this.items = arr.data;
    }
    
  }
  
  public class DictionaryItem {
    public string word;
    public string definition;
  }

}
