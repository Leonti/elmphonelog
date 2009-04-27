/**
 * Copyright (C) 2009 Leonti Bielski <prishelec@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 */

public struct file_dir{
public string name;
public int type;
}
file_dir[] dir_content_gl;
string current_path;
string[]? exts;

public class T.Fileselector : T.Abstract{
public Fileselector(string dirpath, string[]? extensions){
current_path = dirpath;
exts = extensions;

}

    Elm.Bg bg;
    Elm.Box box;
    Elm.Box header_box;
    Elm.Box footer_box;
    Elm.Button up_button;
    Elm.Button home_button;
    Elm.Button enter_button;
    Elm.Button ok_button;
    Elm.Button cancel_button;
    Elm.Genlist filelist;
    Elm.GenlistItemClass itc;
    Elm.GenlistItemClassFunc itcfunc;

    public signal void file_selected ();
    public string filename;


    public override void run(  Evas.Object obj, void* event_info  )
    {
//	dir_icons = {};
        open();
        bg = new Elm.Bg( win );
        bg.file_set( "/usr/share/backgrounds/space-02.jpg" );
        bg.size_hint_weight_set( 1.0, 1.0 );
        bg.show();
        win.resize_object_add( bg );

        box = new Elm.Box( win );
        win.resize_object_add( box );
        box.size_hint_weight_set( 1.0, 1.0 );
        box.show();

        header_box = new Elm.Box( win );
	header_box.horizontal_set( true );
        header_box.size_hint_align_set( -1.0, -1.0 );
        header_box.show();
	box.pack_start(header_box);

	up_button = new Elm.Button (win);
	up_button.label_set("Up");
	up_button.size_hint_weight_set( 1.0, 1.0 );
	up_button.size_hint_align_set( -1.0, -1.0 );
	up_button.smart_callback_add( "clicked", up_clicked );
	up_button.show();
	header_box.pack_start( up_button );

	home_button = new Elm.Button (win);
	home_button.label_set("Home");
	home_button.size_hint_weight_set( 1.0, 1.0 );
	home_button.size_hint_align_set( -1.0, -1.0 );
	home_button.smart_callback_add( "clicked", home_clicked );
	home_button.show();
	header_box.pack_end( home_button );

	enter_button = new Elm.Button (win);
	enter_button.label_set("Enter");
	enter_button.size_hint_weight_set( 1.0, 1.0 );
	enter_button.size_hint_align_set( -1.0, -1.0 );
	enter_button.smart_callback_add( "clicked", enter_clicked );
	enter_button.show();
	header_box.pack_end( enter_button );

//list
        itcfunc = Elm.GenlistItemClassFunc() { label_get = getLabel,
                                               icon_get  = getIcon,
                                               state_get = getState,
                                               del       = delItem };

	itc = Elm.GenlistItemClass(){ item_style = "default",
						func = itcfunc}; 

    filelist = new Elm.Genlist( win );
    filelist.size_hint_weight_set( 1.0, 1.0 );
    filelist.size_hint_align_set( -1.0, -1.0 );
    filelist.show();
    box.pack_end(filelist);
//end list
filename = "";
draw_directory(current_path);

        footer_box = new Elm.Box( win );
	footer_box.horizontal_set( true );
        footer_box.size_hint_align_set( -1.0, -1.0 );
        footer_box.show();
	box.pack_end(footer_box);

	ok_button = new Elm.Button (win);
	ok_button.label_set("Select");
	ok_button.size_hint_weight_set( 1.0, 1.0 );
	ok_button.size_hint_align_set( -1.0, -1.0 );
	ok_button.smart_callback_add( "clicked", ok_clicked );
	ok_button.show();
	footer_box.pack_start( ok_button );

	cancel_button = new Elm.Button (win);
	cancel_button.label_set("Cancel");
	cancel_button.size_hint_weight_set( 1.0, 1.0 );
	cancel_button.size_hint_align_set( -1.0, -1.0 );
	cancel_button.smart_callback_add( "clicked", cancel_clicked );
	cancel_button.show();
	footer_box.pack_end( cancel_button );


    }


    public void up_clicked(  Evas.Object obj, void* event_info) {
if(current_path != "/"){
string[] temp_path = current_path.split("/");
string path_up = "";
if(temp_path.length != 2){
for(int i =1; i < temp_path.length -1; ++i){
path_up += "/" + temp_path[i];
}
}else{
path_up = "/";
}
current_path = path_up;
filelist.clear();
draw_directory(current_path);
}

    }


    public void home_clicked(  Evas.Object obj, void* event_info) {
current_path = Environment.get_home_dir();
filelist.clear();
draw_directory(current_path);
    }


    public void enter_clicked(  Evas.Object obj, void* event_info) {
    Elm.GenlistItem filelist_item = filelist.selected_item_get();
    int number = (int)filelist_item.data_get();
if(dir_content_gl[number-1].type == 1){ //means this is directory and we can enter
if(current_path != "/"){
current_path += "/" + dir_content_gl[number-1].name;
}else{
current_path +=  dir_content_gl[number-1].name;
}
filelist.clear();
draw_directory(current_path);
}
    }

    public void ok_clicked(  Evas.Object obj, void* event_info) {
    Elm.GenlistItem filelist_item = filelist.selected_item_get();
    int number = (int)filelist_item.data_get();
if(dir_content_gl[number-1].type == 0){ //means this is a file and we can select it
if(current_path != "/"){
filename = current_path + "/" + dir_content_gl[number-1].name;
}else{
filename = current_path +  dir_content_gl[number-1].name;
}
    close();
file_selected();
}

    }


    public void cancel_clicked(  Evas.Object obj, void* event_info) {

    close();
    }

    public void draw_directory(string dirname){
debug("drawing directory");
dir_content_gl = get_directory(dirname);
for(int i =0; i < dir_content_gl.length; ++i){
//debug("%s", dir_content_gl[i].name);
  filelist.item_append( itc, (void*)(i+1), null, Elm.GenlistItemFlags.NONE, onSelectedItem );
}

}

    public void onSelectedItem( Evas.Object obj, void* event_info)
    {
    Elm.GenlistItem filelist_item = filelist.selected_item_get();
    int number = (int)filelist_item.data_get();
    debug ("selected: %d", number);
    }

    public string getLabel( Elm.Object obj, string part )
    {
        int number = (int)obj;

      string label = dir_content_gl[number -1].name;
	return label;
    }
    public Elm.Object? getIcon( Elm.Object obj, string part )
    {
        
       // int number = (int)obj;
      //  debug( "icon_get for item %d", number );

//    dir_icons += new Elm.Icon(win);
//    dir_icons[dir_icons.length -1].file_set( "icon_chat.png",null );
//    dir_icons[dir_icons.length -1].show(); 
 //       return dir_icons[dir_icons.length -1];
  
return null;     
    }
    public bool getState( Elm.Object obj, string part )
    {
        int number = (int)obj;
        debug( "state_get for item %d", number );
        return false;
    }
    public void delItem( Elm.Object obj )
    {
        int number = (int)obj;
//        debug( "del for item %d", number );
    }

file_dir[]? get_directory(string dirname){

file_dir[] dir_content = {};
file_dir[] dir_content_files = {};
try{
    Dir? d = Dir.open(dirname);
	if(null != d) {
		for(string? file = d.read_name(); null != file; file = d.read_name()) {

if(file.substring(0,1) != "."){

if(FileUtils.test(dirname + "/" + file, FileTest.IS_DIR)){
file_dir name_temp = file_dir(){name = file, type = 1};
dir_content += name_temp;
}else{
//here we can check for extension
if(exts != null){
for(int i =0; i < exts.length; ++i){
string[] ex_for = file.split(".");

string from_file = ex_for[ex_for.length-1];
from_file = from_file.up();
string from_exts = exts[i];
from_exts = from_exts.up();

if(from_file == from_exts){
file_dir name_temp = file_dir(){name = file, type = 0};
dir_content_files += name_temp;
break;
}
}
}else{
file_dir name_temp = file_dir(){name = file, type = 0};
dir_content_files += name_temp;

}

}

}
		}
for(int i = 0; i < dir_content_files.length; ++i){
dir_content += dir_content_files[i];
}

	}
return dir_content;

}catch(GLib.FileError f_error){
//deal with f_error
return null;
}

}

    public override string name()
    {
        return "Window with background";
    }
}
