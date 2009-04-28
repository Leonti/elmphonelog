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

using Elm;
using DBus;

namespace Freesmartphone{
[DBus (name = "org.freesmartphone.PIM.Contacts")]
public interface Contacts : GLib.Object {
	public abstract string Add(GLib.HashTable<string, string> contact_data);

}
}

T.Fileselector fileselector;






public class T.AddContact : T.Abstract
{
//public FreeSmartphone.GSM.SIMEntry[] sim_book;
public DBus.Connection dbus;
public Freesmartphone.Contacts dbus_contacts;
public FreeSmartphone.GSM.SIM dbus_sim;

public signal void saved_signal (string name_new, string number_new, int storage_type, int sim_id, string opim_path);

GLib.HashTable<string, string> contact_info;
bool sim_storage;

public AddContact(DBus.Connection dbus_par, GLib.HashTable<string, string> contact_info_par, bool sim_par = false){

sim_storage = sim_par;
contact_info = contact_info_par;
/*
string? temp_val = contact_info.lookup("firstname");
debug(temp_val);
temp_val = contact_info.lookup("name");
debug(temp_val);
*/
dbus = dbus_par;
dbus_contacts = (Freesmartphone.Contacts) dbus.get_object<Freesmartphone.Contacts> ("org.freesmartphone.opimd", "/org/freesmartphone/PIM/Contacts");
dbus_sim = (FreeSmartphone.GSM.SIM) dbus.get_object<FreeSmartphone.GSM.SIM> ("org.freesmartphone.ogsmd", "/org/freesmartphone/GSM/Device"); 
}

string saved_name;
string saved_number;

    string photo_filename;
    Elm.Bg bg;
    Elm.Win add_group_win;
    Elm.Frame add_group_frame;

    Elm.Box box;
    Elm.Box box_main;
    Elm.Box box_additional;
    Elm.Box box_photo;

    Elm.Hoversel hoversel;
Elm.Table table;
Elm.Table table2;
Elm.Table table_sim;
Elm.Table table_additional;
	Elm.Button save_bt;
       Elm.Label[] field_labels;
       Elm.Entry[] field_entries;
       Elm.Label[] field_labels_additional;
       Elm.Entry[] field_entries_additional;
string[] default_groups;
string[] field_data;
string[] field_data_additional;
Elm.Box group_box;
Elm.Button add_group;
Elm.Box box_hover;
Elm.Box add_group_vbox;
Elm.Entry group_entry;
Elm.Label add_group_label;
Elm.Button button_add_group;
Elm.Button button_add_cancel;
Elm.Label group_label;
Elm.Check check_common;
Elm.Toolbar contact_tool;
Elm.ToolbarItem[] tool_items;
Elm.Icon ic_main;
Elm.Icon ic_additional;
Elm.Icon ic_photo;
Elm.Photo contact_photo;
Elm.Scroller main_scroller;

struct status_struct {
public bool additional;
public bool photo;
}
status_struct status;

    public override void run(  Evas.Object obj, void* event_info  )
    {
        open();

        bg = new Elm.Bg( win );

 //       bg.file_set( "/usr/share/backgrounds/space-02.jpg" );

        bg.size_hint_weight_set( 1.0, 1.0 );

        bg.show();

        win.resize_object_add( bg );

        box = new Elm.Box( win );
        win.resize_object_add( box );
        box.size_hint_weight_set( 1.0, 1.0 );
        box.show();

if(sim_storage == false){
status = status_struct() {additional = false,
	      photo = false};
string[] exts = {"png", "jpg", "jpeg", "gif"};
fileselector = new T.Fileselector("/", exts);
fileselector.file_selected += file_selected;
photo_filename = "";
default_groups = {"General", "Friends", "Work", "Family"};


    contact_tool = new Toolbar( win );
    contact_tool.size_hint_align_set( -1.0, -1.0 );
//    calls_tool.size_hint_weight_set( 1.0, 1.0 );
    contact_tool.show();
    box.pack_start(contact_tool);

	main_scroller = new Elm.Scroller( win );
	main_scroller.size_hint_weight_set( 1.0, 1.0 );
	main_scroller.size_hint_align_set( -1.0, -1.0 );
	main_scroller.show();
	box.pack_end(main_scroller);
//      calls_tool.scrollable_set(false);


//this somehow gives "Segmentation Fault" on exit - have to look into that
//tool_items = {};

    ic_main = new Icon(win);
    ic_main.file_set( "/usr/share/elmphonelog/icons/info.png");   
    tool_items += contact_tool.item_add(ic_main, "Main", showMain );
    ic_additional = new Icon(win);
    ic_additional.file_set( "/usr/share/elmphonelog/icons/add_info.png");
    tool_items += contact_tool.item_add(ic_additional, "Additional", showAdditional );
    ic_photo = new Icon(win);
    ic_photo.file_set( "/usr/share/elmphonelog/icons/photo.png");
    tool_items += contact_tool.item_add(ic_photo, "Photo", showPhoto );
  
	table2 = new Elm.Table( win );
	table2.size_hint_align_set( -1.0, -1.0 );
	table2.size_hint_weight_set( 1.0, 1.0 );
	table2.homogenous_set( false );
	table2.show();
//	box.pack_end(table2);
	main_scroller.content_set(table2);
 
       box_main = new Elm.Box( win );
	box_main.size_hint_weight_set( 1.0, 1.0 );
	box_main.size_hint_align_set( -1.0, -1.0 );
	table2.pack(box_main,0,0,1,1);
	box_main.show();

        box_additional = new Elm.Box( win );
	box_additional.size_hint_align_set( -1.0, -1.0 );
	table2.pack(box_additional,0,0,1,1);

        box_photo = new Elm.Box( win );
	box_photo.size_hint_align_set( -1.0, -1.0 );
	table2.pack(box_photo,0,0,1,1);
	fill_main();
}else{
//drawing for sim 
	table_sim = new Elm.Table( win );
	table_sim.size_hint_align_set( -1.0, -1.0 );
	table_sim.size_hint_weight_set( 1.0, 1.0 );
	table_sim.homogenous_set( false );
	table_sim.show();
	box.pack_start( table_sim );

string[] field_names = {"Contact name:", "Number:"};
string[]? known_values = {};
known_values += contact_info.lookup("name");
known_values += contact_info.lookup("cellnumber");

field_labels = new Elm.Label[field_names.length];
field_entries = new Elm.Entry[field_names.length];

for(int i=0; i <field_names.length; ++i){   
	field_labels[i] = new Elm.Label( win );
        field_labels[i].label_set( field_names[i] );  
	field_labels[i].size_hint_align_set( -1.0, -1.0 );
	field_labels[i].scale_set( 1.4 );
        field_labels[i].show();
	table_sim.pack(field_labels[i], 0, i, 1, 1 ); 

        field_entries[i] = new Elm.Entry( win );
	field_entries[i].single_line_set(true);
	if(known_values[i] != null){
field_entries[i].entry_set(known_values[i]);
}
	field_entries[i].size_hint_weight_set( 1.0, 0.0 );
	field_entries[i].size_hint_align_set( -1.0, -1.0 );
	field_entries[i].scale_set( 1.4 );
        field_entries[i].show();
	table_sim.pack(field_entries[i], 1, i, 1, 1 ); 
}

}
	save_bt = new Elm.Button (win);
	save_bt.size_hint_weight_set( 1.0, 0.0 );
	save_bt.size_hint_align_set( -1.0, -1.0 );
	save_bt.label_set("Save");
	save_bt.smart_callback_add( "clicked", save_clicked );
	save_bt.show();
	box.pack_end( save_bt );


    }


    public void showMain(  Evas.Object obj, void* event_info) {
box_additional.hide();
box_photo.hide();
box_main.show();
    }

    public void showAdditional(  Evas.Object obj, void* event_info) {
box_main.hide();
box_photo.hide();
if(!status.additional){
//means nothing is loaded yet - drawing the screen
fill_additional();
}else{
//it'a already there - just showing it
box_additional.show();
}
    }


    public void showPhoto(  Evas.Object obj, void* event_info) {
box_main.hide();
box_additional.hide();
if(!status.photo){
//means nothing is loaded yet - drawing the screen
fill_photo();
}else{
//it'a already there - just showing it
box_photo.show();
}
    }


    public void fill_main(){

string[] field_names = {"Contact name:", "First name:", "Second name:", "Cell number:", "Home number:", "Work number:", "E-mail:"};

string[]? known_values = {};

known_values += contact_info.lookup("name");
known_values += contact_info.lookup("firstname");
known_values += contact_info.lookup("secondname");
known_values += contact_info.lookup("cellnumber");
known_values += contact_info.lookup("homenumber");
known_values += contact_info.lookup("worknumber");
known_values += contact_info.lookup("email");


field_labels = new Elm.Label[field_names.length];
field_entries = new Elm.Entry[field_names.length];

	table = new Elm.Table( win );
	table.size_hint_align_set( -1.0, -1.0 );
	table.size_hint_weight_set( 1.0, 1.0 );
	table.homogenous_set( false );
	table.show();
	box_main.pack_start( table );

for(int i=0; i <field_names.length; ++i){   
	field_labels[i] = new Elm.Label( win );
        field_labels[i].label_set( field_names[i] );  
	field_labels[i].size_hint_align_set( -1.0, -1.0 );
	field_labels[i].scale_set( 1.4 );
        field_labels[i].show();
	table.pack(field_labels[i], 0, i, 1, 1 ); 

        field_entries[i] = new Elm.Entry( win );
	field_entries[i].single_line_set(true);
	if(known_values[i] != null){
field_entries[i].entry_set(known_values[i]);
}
	field_entries[i].size_hint_weight_set( 1.0, 0.0 );
	field_entries[i].size_hint_align_set( -1.0, -1.0 );
	field_entries[i].scale_set( 1.4 );
        field_entries[i].show();
	table.pack(field_entries[i], 1, i, 1, 1 ); 
}

	group_label = new Elm.Label( win );
        group_label.label_set( "Group:" );
	 group_label.size_hint_align_set( -1.0, -1.0 );
	group_label.scale_set( 1.4 );
        group_label.show();
	table.pack(group_label, 0, field_names.length, 1, 1 ); 

        group_box = new Elm.Box( win );
	group_box.size_hint_align_set( -1.0, -1.0 );
	group_box.size_hint_weight_set( 1.0, 1.0 );
	group_box.horizontal_set(true);
        group_box.show();
	table.pack(group_box, 1, field_names.length, 1, 1 ); 

        hoversel = new Elm.Hoversel( win );
        hoversel.hover_parent_set( win );

	fill_groups();
        group_box.pack_end( hoversel );
        hoversel.show();

	add_group = new Elm.Button (win);
	add_group.label_set("Add");
	add_group.smart_callback_add( "clicked", show_group_inwin );
	add_group.show();
	group_box.pack_end( add_group );


        add_group_vbox = new Elm.Box( win );
	add_group_vbox.size_hint_weight_set( 1.0, 1.0 );
	add_group_vbox.size_hint_align_set( -1.0, -1.0 );
        add_group_vbox.show();

        box_hover = new Elm.Box( win );
	box_hover.horizontal_set(true);
	box_hover.size_hint_weight_set( 1.0, 1.0 );
	box_hover.size_hint_align_set( -1.0, -1.0 );
        box_hover.show();

	add_group_win = win.inwin_add();
//	add_group_win.inwin_activate();
	add_group_win.inwin_style_set("minimal_vertical");

	add_group_frame = new Elm.Frame(add_group_win );
	add_group_frame.style_set("outdent_top");
	add_group_frame.size_hint_weight_set( 1.0, 1.0 );
	add_group_frame.size_hint_align_set( -1.0, -1.0 );
	add_group_frame.show();
	add_group_vbox.pack_start(add_group_frame);

	add_group_label = new Elm.Label( add_group_win );
	add_group_label.label_set("Add contacts group");
	add_group_label.scale_set( 1.4 );
	add_group_label.show();
	add_group_frame.content_set(add_group_label);

	add_group_vbox.pack_end(box_hover);

	group_entry = new Elm.Entry( win ); 
	group_entry.single_line_set(true);
	group_entry.size_hint_weight_set( 1.0, 1.0 );
	group_entry.size_hint_align_set( -1.0, 0.5 );
	group_entry.scale_set( 1.4 );
        group_entry.show();
	box_hover.pack_end(group_entry);

	button_add_group = new Elm.Button ( win );
	button_add_group.label_set("Add");
	button_add_cancel.size_hint_align_set( 1.0, -1.0 );
	button_add_group.smart_callback_add( "clicked", add_add_group );
	button_add_group.show();
	box_hover.pack_end( button_add_group );

	button_add_cancel = new Elm.Button ( win );
	button_add_cancel.size_hint_align_set( 1.0, -1.0 );
	button_add_cancel.label_set("Cancel");
	button_add_cancel.smart_callback_add( "clicked", cancel_add_group );
	button_add_cancel.show();
	box_hover.pack_end( button_add_cancel );
	add_group_win.inwin_content_set(add_group_vbox);

    check_common = new Check( win );
    check_common.label_set("Common");
if(contact_info.lookup("common") != null){
if(contact_info.lookup("common") == "true"){
check_common.state_set(true);
}
}
    check_common.size_hint_align_set( -1.0, -1.0 );
    check_common.scale_set( 1.4 );
    check_common.show();
    table.pack(check_common, 0, field_names.length + 1, 1, 1);

}

    public void fill_groups(){
//	hoversel.clear();
if(contact_info.lookup("group") != null){
//doing something with the group
}

        hoversel.label_set( "General" );
for(int i =0; i < default_groups.length; ++i){
        hoversel.item_add( default_groups[i], null, Elm.IconType.NONE, null );
}
}

    public void fill_additional(){
string[] field_names = {"Second E-mail:","Web page:", "SIP:", "Jabber:", "Comments:"};
string[]? known_values = {};

known_values += contact_info.lookup("secondemail");
known_values += contact_info.lookup("webpage");
known_values += contact_info.lookup("sip");
known_values += contact_info.lookup("jabber");
known_values += contact_info.lookup("comments");

field_labels_additional = new Elm.Label[field_names.length];
field_entries_additional = new Elm.Entry[field_names.length];

	table_additional = new Elm.Table( win );
	table_additional.size_hint_align_set( -1.0, -1.0 );
	table_additional.size_hint_weight_set( 1.0, 1.0 );
	table_additional.homogenous_set( false );
	table_additional.show();
	box_additional.pack_start( table_additional );

for(int i=0; i <field_names.length; ++i){   
	field_labels_additional[i] = new Elm.Label( win );
        field_labels_additional[i].label_set( field_names[i] );  
	field_labels_additional[i].size_hint_align_set( -1.0, -1.0 );
	field_labels_additional[i].scale_set( 1.4 );
        field_labels_additional[i].show();
	table_additional.pack(field_labels_additional[i], 0, i, 1, 1 ); 

        field_entries_additional[i] = new Elm.Entry( win );
//	field_entries_additional[i].line_wrap_set(false);
	field_entries_additional[i].single_line_set(true);
	if(known_values[i] != null){
field_entries_additional[i].entry_set(known_values[i]);
}
	field_entries_additional[i].size_hint_weight_set( 1.0, 0.0 );
	field_entries_additional[i].size_hint_align_set( -1.0, -1.0 );
	field_entries_additional[i].scale_set( 1.4 );
        field_entries_additional[i].show();
	table_additional.pack(field_entries_additional[i], 1, i, 1, 1 ); 
}


    box_additional.show();
    status.additional = true;
}
    public void fill_photo(){

	contact_photo = new Elm.Photo( win );
	contact_photo.size_hint_align_set( -1.0, -1.0 );
	contact_photo.size_hint_weight_set( 1.0, 1.0 );
	contact_photo.size_set(130);
if(contact_info.lookup("photoimage") != null){
contact_photo.file_set(contact_info.lookup("photoimage"));
}
        contact_photo.show();
	contact_photo.smart_callback_add( "clicked", addPhoto );
	box_photo.pack_start(contact_photo);

    box_photo.show();
    status.photo = true;
}

    public void show_group_inwin(  Evas.Object obj, void* event_info ){
	group_entry.entry_set("");
	add_group_win.show();
}

    public void cancel_add_group(  Evas.Object obj, void* event_info ){
	add_group_win.hide();
}
 
   public void add_add_group(  Evas.Object obj, void* event_info ){
//performing adding group
	add_group_win.hide();
}

    public void addPhoto(  Evas.Object obj, void* event_info) {
debug("Adding photo");
fileselector.run(obj, event_info);

}

public void file_selected(){
photo_filename = fileselector.filename;
debug("File selected: %s", photo_filename);
contact_photo.file_set(photo_filename);
}

    public void save_clicked(  Evas.Object obj, void* event_info){

//Total mess right now - maybe due to some nugs in entry or in Vala, maybe in me :)
//allows to save only one time per session
//somehow we can do .entry_get() only for one time :(

if(sim_storage == false){
debug("saving to phone memory");

field_data = {};
for(int i =0; i < field_entries.length; ++i){
field_data += field_entries[i].entry_get();
}
for(int i = 0; i < field_data.length; ++i){
debug("proverko: %s",field_data[i]);
}



GLib.HashTable<string, string>  contact = new GLib.HashTable<string, string>(GLib.str_hash, GLib.str_equal);
saved_name = field_data[0].substring(0, (int)field_data[0].length - 4);
saved_number = field_data[3].substring(0, (int)field_data[3].length - 4);
       contact.insert( "name", saved_name);
       contact.insert( "firstname", field_data[1].substring(0, (int)field_data[1].length - 4));
       contact.insert( "secondname", field_data[2].substring(0, (int)field_data[2].length - 4));
       contact.insert( "cellnumber", saved_number);
       contact.insert( "homenumber", field_data[4].substring(0, (int)field_data[4].length - 4));
       contact.insert( "worknumber", field_data[5].substring(0, (int)field_data[5].length - 4));
       contact.insert( "email", field_data[6].substring(0, (int)field_data[6].length - 4));
if(check_common.state_get()){
       contact.insert( "common", "true");
}else{
       contact.insert( "common", "false");
}
       contact.insert( "group", "General");


if(status.additional){
field_data_additional = {};
for(int i =0; i < field_entries_additional.length; ++i){
field_data_additional += field_entries_additional[i].entry_get();
}
       contact.insert( "secondemail", field_data_additional[0].substring(0, (int)field_data_additional[0].length - 4));
       contact.insert( "webpage", field_data_additional[1].substring(0, (int)field_data_additional[1].length - 4));
       contact.insert( "sip", field_data_additional[2].substring(0, (int)field_data_additional[2].length - 4));
       contact.insert( "jabber", field_data_additional[3].substring(0, (int)field_data_additional[3].length - 4));
       contact.insert( "comments", field_data_additional[4].substring(0, (int)field_data_additional[4].length - 4));
}else{
       contact.insert( "secondemail", "");
       contact.insert( "webpage", "");
       contact.insert( "sip", "");
       contact.insert( "jabber", "");
       contact.insert( "comments", "");

}
//if(status.photo){
       contact.insert( "photoimage", photo_filename);
//}

//checking for presense of "path" in hashtable
// in future - when path is present it means that contact is already exists and we are updating it instead of adding
//for now - adding very contact

string cont_path = dbus_contacts.Add(contact);
saved_signal (saved_name, saved_number, 1, 0, cont_path);

debug("new contact added: %s", cont_path);
}else{
debug("saving to sim");
if(contact_info.lookup("sim_position") !=  null){
debug("Updating existing sim entry with id: %d", contact_info.lookup("sim_position").to_int());

field_data = {};
field_data += field_entries[0].entry_get();
field_data += field_entries[1].entry_get();
saved_name = field_data[0].substring(0, (int)field_data[0].length - 4);
saved_number = field_data[1].substring(0, (int)field_data[1].length - 4);
dbus_sim.store_entry("contacts", contact_info.lookup("sim_position").to_int(), saved_name, saved_number);
saved_signal (saved_name, saved_number, 2, contact_info.lookup("sim_position").to_int(), "");
//updating

}else{
debug("Adding new entry to sim");
//FreeSmartphone.GSM.SIMEntry[]
//adding to sim
int free_entry = find_free_entry();
if(free_entry != -1){
debug("free entry %d", free_entry);
field_data = {};
field_data += field_entries[0].entry_get();
field_data += field_entries[1].entry_get();
saved_name = field_data[0].substring(0, (int)field_data[0].length - 4);
saved_number = field_data[1].substring(0, (int)field_data[1].length - 4);
dbus_sim.store_entry("contacts", free_entry, saved_name, saved_number);
saved_signal (saved_name, saved_number, 2, free_entry, "");
}else{
//some dialog would be useful :)
debug("no free entry found");
}
}
}

close(); //closing because of the bug we cannot edit entered data - once retrieved from entries - entries become unresponsive(segmentation fault) :(
}

public int find_free_entry(){
int ind = -1;
GLib.HashTable<string, GLib.Value?> phonebook_info = dbus_sim.get_phonebook_info("contacts");
FreeSmartphone.GSM.SIMEntry[] book = dbus_sim.retrieve_phonebook("contacts");

for(int i= phonebook_info.lookup("min_index").get_int(); i <= phonebook_info.lookup("max_index").get_int(); ++i){
bool match = false;
for(int j = 0; j < book.length; ++j){
if(book[j].attr1 == i ){
match = true;
break;
}
}
if(match == false){
ind = i;
break;
}
}

return ind;
}

    public override string name()
    {
        return "Window with background";
    }
} 
