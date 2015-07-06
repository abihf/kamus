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
    
  public class DictionaryCollection {
    public static async Dictionary get_by_name(string name) {
      var dict = new Dictionary();
      yield dict.load_from_resource("/org/hafshin/kamus/dicts/" + name + ".dict");
      return dict;
    }
  } 

  public class Dictionary {
    public DictionaryItem[] items;
  
    public async void load_from_resource(string path) throws Error {
      print("load resource: %s\n", path);
      InputStream stream = resources_open_stream(path,  ResourceLookupFlags.NONE);
      yield this.load_stream(stream);
      stream.unref();
    }

    public int search(string str) {
      int index = binary_search(str, 0, items.length, true);
      debug("full bin search: %d\n", index);
      if (index < 0) {
        index = binary_search(str, 0, items.length, false);
        debug("prefixed bin search: %d\n", index);
      }
      return index;
    }

    private int binary_search(string search, int begin, int end, bool full) {
      if (begin > end) return -1;
      int mid = (begin + end) >> 1;
      string word = items[mid].word;
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

    // public async void load_file(string filename) {
    //   File file = File.new_for_path(filename);
    //   InputStream stream = yield file.read_async();
    //   yield this.load_stream(stream);
    // }

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
