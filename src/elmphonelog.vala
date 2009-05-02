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

using Evas;
using Elm;
using Sqlite;
using DBus;
using FreeSmartphone;

Genlist list;
Database db;
int rc;
    GenlistItemClass itc;
    GenlistItemClassFunc itcfunc;
    Win win;

        Elm.Box action_box;
Elm.Frame action_frame;
Elm.Label action_label;
Elm.Hover action_hover;
Elm.Button action_call;
Elm.Button action_sms;
Elm.Button action_1;
Elm.Button action_2;

Elm.Table buttons_table;
Elm.Table details_table;
Elm.Label details_dur_cap;
Elm.Label details_dur_data;
Elm.Label details_time_cap;
Elm.Label details_time_data;

public struct call_info
{
    public string number;
    public  string time;
    public string duration;
    public int type;
    public int number_id;
}

public struct number_info{
public string name;
public string number;
public int storage_type;//0 - no storage, 1- phone memory, 2 - sim
public int sim_id;
public string opim_path;
}

bool all_flag;
int current_number;
int current_page;

int count;
int[] longs;
string[] db_numbers;

ToolbarItem[] tool_items;

DBus.Connection dbus;
//dynamic DBus.Object dbus_sim; //SIM dbus object
FreeSmartphone.GSM.Call dbus_call;
Freesmartphonen.Contacts dbus_contacts;
call_info[] call_infs;
number_info[] number_infos;

T.AddContact[] addcontacts; //right now creating the array of addcontact instances, will have to look into that
T.Contact[] conts; //right now creating the array of addcontact instances, will have to look into that - probably have to 'null' them

FreeSmartphone.GSM.SIMEntry[] book;

public int main( string[] args )
{
dbus = DBus.Bus.get (DBus.BusType.SESSION);
FreeSmartphone.GSM.SIM dbus_sim;
dbus_sim = (FreeSmartphone.GSM.SIM) dbus.get_object<FreeSmartphone.GSM.SIM> ("org.freesmartphone.ogsmd", "/org/freesmartphone/GSM/Device");
book = dbus_sim.retrieve_phonebook("contacts");

dbus_call = (FreeSmartphone.GSM.Call) dbus.get_object<FreeSmartphone.GSM.Call> ("org.freesmartphone.ogsmd", "/org/freesmartphone/GSM/Device");

dbus_contacts = (Freesmartphonen.Contacts) dbus.get_object<Freesmartphonen.Contacts> ("org.freesmartphone.opimd", "/org/freesmartphone/PIM/Contacts");


all_flag = false;

count = 0;
longs = {};

//dynamic DBus.Object dbus_pim_sources;
//dbus_pim_sources = dbus.get_object ("org.freesmartphone.opimd", "/org/freesmartphone/PIM/Sources", "org.freesmartphone.PIM.Sources");
//dbus_pim_sources.InitAllEntries();

        rc = Database.open ("/var/db/phonelog.db", out db);

        if (rc != Sqlite.OK) {
            stderr.printf ("Can't open database: %d, %s\n", rc, db.errmsg ());
        }

get_all_numbers();

for(int i=0; i< db_numbers.length; ++i){
debug(db_numbers[i]);
}

number_infos += number_info(){name = "Unknown", number = "", storage_type = 0, sim_id = 0, opim_path = ""};

get_names();

    Elm.init( args );

    win = new Win( null, "elmphonelog", WinType.BASIC );
    win.title_set( "Phonelog" );
    win.autodel_set( true );
    win.resize( 320, 320 );
    win.smart_callback_add( "delete-request", exit );
    win.show();

    var bg = new Bg( win );
    bg.size_hint_weight_set( 1.0, 1.0 );
    bg.show();
    win.resize_object_add( bg );


    Box box = new Box( win );
    box.size_hint_align_set( -1.0, -1.0 );
    box.size_hint_weight_set( 1.0, 1.0 );
    box.show();
    win.resize_object_add( box );

    Toolbar calls_tool = new Toolbar( win );
    calls_tool.size_hint_align_set( -1.0, -1.0 );
//    calls_tool.size_hint_weight_set( 1.0, 1.0 );
    calls_tool.show();
    box.pack_start(calls_tool);

//      calls_tool.scrollable_set(false);
    Icon ic_in = new Icon(calls_tool);
    ic_in.file_set(  "/usr/share/elmphonelog/icons/in.png" );
//this somehow gives "Segmentation Fault" - have to look into that

tool_items = {};
   
    tool_items += calls_tool.item_add(ic_in, "In", showIn );
    Icon ic_out = new Icon(calls_tool);
    ic_out.file_set(  "/usr/share/elmphonelog/icons/out.png" );
   tool_items += calls_tool.item_add(ic_out, "Out", showOut );
    Icon ic_mis = new Icon(calls_tool);
    ic_mis.file_set(  "/usr/share/elmphonelog/icons/missed.png" );
    tool_items += calls_tool.item_add(ic_mis, "Missed", showMis );
    Icon ic_all = new Icon(calls_tool);
    ic_all.file_set(  "/usr/share/elmphonelog/icons/all.png" );
    tool_items += calls_tool.item_add(ic_all, "All", showAll );



        itcfunc = GenlistItemClassFunc() { label_get = getLabel,
                                               icon_get  = getIcon,
                                               state_get = getState,
                                               del       = delItem };

	itc = GenlistItemClass(){ item_style = "default",
						func = itcfunc}; 

    list = new Elm.Genlist( box );

//    show_calls(2);
tool_items[2].select();

    list.smart_callback_add( "expand,request", list_exp_req );
    list.smart_callback_add( "contract,request", list_con_req );
    list.smart_callback_add( "expanded", list_exp );
    list.smart_callback_add( "contracted", list_con );
    list.size_hint_weight_set( 1.0, 1.0 );
    list.size_hint_align_set( -1.0, -1.0 );
    list.show();
    box.pack_end(list);




    Elm.run();
    Elm.shutdown();
    return 0;
}

    public void list_exp_req( Evas.Object obj, void* event_info){
    debug("expand request");
action_hover.hide();
    GenlistItem* list_item = event_info;
    list_item->selected_set(false);
    list_item->expanded_set( true );
    }
    public void list_exp( Evas.Object obj, void* event_info){
    debug("expanding");
    GenlistItem* list_item = event_info;
    int number = (int)list_item -> data_get();
    debug ("expanding: %d", number);

int i;
int cou = 0;
for( i=0; i < longs.length; ++i ){
cou += longs[i];
if (cou - longs[i] + 1 == number) break;
}; 
    debug("how many to expand %d", longs[i]);
for(int j = 1; j < longs[i] ; ++j){

    list.item_append( itc, (void*)(number + j), list_item, Elm.GenlistItemFlags.NONE, onSelectedItem );
}
    }

    public void list_con_req( Evas.Object obj, void* event_info){
    debug("contract request");
action_hover.hide();
    GenlistItem* list_item = event_info;
    list_item->selected_set(false);
    list_item->expanded_set( false );
    }
    public void list_con( Evas.Object obj, void* event_info){
    debug("contracting");
    GenlistItem* list_item = event_info;
    list_item->subitems_clear();
    }


    public string getLabel( Elm.Object obj, string part )
    {
        int number = (int)obj;
string label = "";
if(number_infos[call_infs[number-1].number_id].storage_type != 0){
      label = number_infos[call_infs[number-1].number_id].name +" "+ call_infs[number-1].time;
}else if(call_infs[number-1].number != "***"){
      label = call_infs[number-1].number +" "+ call_infs[number-1].time;
}else{
      label = "Hidden "+ call_infs[number-1].time;
}

// + " " + durations[number-1]; // values[1] + " " + values[3] + " " + values[6];
	return label;
    }
    public Elm.Object? getIcon( Elm.Object obj, string part )
    {
 //       return null;
        /* This leads to a SIGSEGV, something's still wrong wrt. those delegates */
        
        int number = (int)obj;
//        debug( "icon_get for item %d", number );
    Icon ic = new Icon(win);
if(all_flag == true){
switch(call_infs[number-1].type){
case 0:
    ic.file_set( "/usr/share/elmphonelog/icons/in.png" ); break;
case 1:
    ic.file_set( "/usr/share/elmphonelog/icons/out.png" ); break;
case 2:
    ic.file_set( "/usr/share/elmphonelog/icons/missed.png" ); break;
}
}
	ic.show();
        return ic;
        
    }
    public bool getState( Elm.Object obj, string part )
    {
        int number = (int)obj;
//        debug( "state_get for item %d", number );
        return false;
    }
    public void delItem( Elm.Object obj )
    {
        int number = (int)obj;
//        debug( "del for item %d", number );
    }
    public void onSelectedItem( Evas.Object obj, void* event_info)
    {
    GenlistItem proverko = list.selected_item_get();
    int number = (int)proverko.data_get();
    debug ("selected: %d", number);

current_number = number;
//    cont.call_inf = call_infs[0];
//    cont.dbus = dbus;
//    cont.run(obj, event_info);


if(call_infs[number-1].number != "***"){
//showing action hover
debug("showing action hover");

    GenlistItem* list_item = event_info;
    list_item->selected_set(false);

        action_box = new Elm.Box( win );
//	action_box.size_hint_weight_set( 1.0, 1.0 );
//	action_box.size_hint_align_set( -1.0, -1.0 );
        action_box.show();

	action_frame = new Elm.Frame( action_box );
	action_frame.style_set("outdent_top");
//	action_frame.size_hint_weight_set( 1.0, 1.0 );
//	action_frame.size_hint_align_set( -1.0, -1.0 );
	action_frame.show();

	action_box.pack_start(action_frame);

	action_label = new Elm.Label( action_box );
	action_label.label_set(number_infos[call_infs[number-1].number_id].name + " " + call_infs[number-1].number);
	action_label.scale_set( 1.4 );
	action_label.show();
	action_frame.content_set(action_label);
/*
Elm.Table details_table;
Elm.Table buttons_table;
Elm.Label details_dur_cap;
Elm.Label details_dur_data;
Elm.Label details_time_cap;
Elm.Label details_time_data;
*/
details_table = new Table( action_box );
details_table.size_hint_align_set( -1.0, -1.0 );
details_table.size_hint_weight_set( 1.0, 1.0 );
details_table.show();
action_box.pack_end(details_table);

	details_dur_cap = new Elm.Label( action_box );
	details_dur_cap.label_set("Duration:");
	details_dur_cap.scale_set( 1.4 );
//	details_dur_cap.size_hint_weight_set( 1.0, 1.0 );
	details_dur_cap.size_hint_align_set( -1.0, -1.0 );
	details_dur_cap.show();
	details_table.pack(details_dur_cap,0,0,1,1);

	details_dur_data = new Elm.Label( action_box );
	details_dur_data.label_set(call_infs[number-1].duration);
	details_dur_data.scale_set( 1.4 );
//	details_dur_data.size_hint_weight_set( 1.0, 1.0 );
	details_dur_data.size_hint_align_set( -1.0, -1.0 );
	details_dur_data.show();
	details_table.pack(details_dur_data,1,0,1,1);

	details_time_cap = new Elm.Label( action_box );
	details_time_cap.label_set("Time:");
	details_time_cap.scale_set( 1.4 );
//	details_time_cap.size_hint_weight_set( 1.0, 1.0 );
	details_time_cap.size_hint_align_set( -1.0, -1.0 );
	details_time_cap.show();
	details_table.pack(details_time_cap,0,1,1,1);

	details_time_data = new Elm.Label( action_box );
	details_time_data.label_set(call_infs[number-1].time);
	details_time_data.scale_set( 1.4 );
//	details_time_data.size_hint_weight_set( 1.0, 1.0 );
	details_time_data.size_hint_align_set( -1.0, -1.0 );
	details_time_data.show();
	details_table.pack(details_time_data,1,1,1,1);


buttons_table = new Table( action_box );
buttons_table.size_hint_align_set( -1.0, -1.0 );
buttons_table.size_hint_weight_set( 1.0, 1.0 );
buttons_table.homogenous_set( true );
buttons_table.show();
action_box.pack_end(buttons_table);

action_call = new Elm.Button ( action_box );
action_call.label_set("Call");
action_call.smart_callback_add( "clicked", call_number );
action_call.size_hint_weight_set( 1.0, 1.0 );
action_call.size_hint_align_set( -1.0, -1.0 );
action_call.show();
buttons_table.pack(action_call, 0, 0, 1, 1 );

action_sms = new Elm.Button ( action_box );
action_sms.label_set("Send SMS");
action_sms.smart_callback_add( "clicked", send_message );
action_sms.size_hint_weight_set( 1.0, 1.0 );
action_sms.size_hint_align_set( -1.0, -1.0 );
action_sms.show();
buttons_table.pack(action_sms, 1, 0, 1, 1 );

action_1 =  new Elm.Button ( action_box );
action_1.size_hint_weight_set( 1.0, 1.0 );
action_1.size_hint_align_set( -1.0, -1.0 );
action_1.show();
buttons_table.pack(action_1, 0, 1, 1, 1 );

action_2 =  new Elm.Button ( action_box );
action_2.size_hint_weight_set( 1.0, 1.0 );
action_2.size_hint_align_set( -1.0, -1.0 );
action_2.show();
buttons_table.pack(action_2, 1, 1, 1, 1 );


switch(number_infos[call_infs[number-1].number_id].storage_type){
case 0:
action_1.label_set("Save to phone");
action_1.smart_callback_add( "clicked", save_number );

action_2.label_set("Save to sim");
action_2.smart_callback_add( "clicked", save_number_to_sim );
break;
case 1:
action_1.label_set("View");
action_1.smart_callback_add( "clicked", view_number );

action_2.label_set("Edit");
action_2.smart_callback_add( "clicked", edit_number );
break;
case 2:
action_1.label_set("Edit");
action_1.smart_callback_add( "clicked", edit_number_sim );

action_2.label_set("Copy to phone");
action_2.smart_callback_add( "clicked", save_number );

break;
}

	action_hover= new Elm.Hover( win );
	action_hover.style_set("popout");
	action_hover.parent_set( win );
	action_hover.target_set ( list );
	action_hover.content_set("middle", action_box);
	action_hover.show();
}
    }

    public void call_number( Evas.Object obj, void* event_info){
        debug( "calling number" );
	action_hover.hide();
dbus_call.initiate(call_infs[current_number-1].number, "voice");
    }

    public void send_message( Evas.Object obj, void* event_info){
        debug( "sending message" );
	action_hover.hide();
    }
    public void save_number( Evas.Object obj, void* event_info){
        debug( "saving number to phone memory" );
	action_hover.hide();

GLib.HashTable<string, string>  contact_info = new GLib.HashTable<string, string>(GLib.str_hash, GLib.str_equal);
       contact_info.insert( "name", number_infos[call_infs[current_number-1].number_id].name);
       contact_info.insert( "cellnumber", call_infs[current_number-1].number);
    addcontacts += new T.AddContact(dbus, contact_info);
    addcontacts[addcontacts.length-1].saved_signal += update_contact;
    addcontacts[addcontacts.length-1].run(obj, event_info);

    }

    public void save_number_to_sim( Evas.Object obj, void* event_info){
        debug( "saving number to sim " );
	action_hover.hide();
GLib.HashTable<string, string>  contact_info = new GLib.HashTable<string, string>(GLib.str_hash, GLib.str_equal);
//       contact_info.insert( "name", number_infos[call_infs[current_number-1].number_id].name);
       contact_info.insert( "cellnumber", call_infs[current_number-1].number);
    addcontacts += new T.AddContact(dbus, contact_info, true);
    addcontacts[addcontacts.length-1].saved_signal += update_contact;
    addcontacts[addcontacts.length-1].run(obj, event_info);
    }
    public void view_number( Evas.Object obj, void* event_info){
        debug( "view number from phone memory" );
	action_hover.hide();
    conts += new T.Contact(dbus, number_infos[call_infs[current_number-1].number_id].opim_path);
    conts[conts.length-1].saved_signal += update_contact;
    conts[conts.length-1].run(obj, event_info);
    }
    public void edit_number( Evas.Object obj, void* event_info){
        debug( "editing number from phone memory" );
	action_hover.hide();

GLib.HashTable<string, string>  contact_info = new GLib.HashTable<string, string>(GLib.str_hash, GLib.str_equal);

Freesmartphonen.Contact dbus_contact =  (Freesmartphonen.Contact) dbus.get_object<Freesmartphonen.Contact> ("org.freesmartphone.opimd", number_infos[call_infs[current_number-1].number_id].opim_path);
GLib.HashTable<string, GLib.Value?>  contact_content = dbus_contact.GetContent();
GLib.List<weak string> v = contact_content.get_keys();
foreach(string key_name in v){
contact_info.insert(key_name, contact_content.lookup(key_name).get_string());
}

    addcontacts += new T.AddContact(dbus, contact_info);
    addcontacts[addcontacts.length-1].saved_signal += update_contact;
    addcontacts[addcontacts.length-1].run(obj, event_info);
    }
    public void edit_number_sim( Evas.Object obj, void* event_info){
        debug( "editing number from sim" );
	action_hover.hide();

GLib.HashTable<string, string>  contact_info = new GLib.HashTable<string, string>(GLib.str_hash, GLib.str_equal);
       contact_info.insert( "name", number_infos[call_infs[current_number-1].number_id].name);
       contact_info.insert( "cellnumber", call_infs[current_number-1].number);
       contact_info.insert( "sim_position", "%d".printf(number_infos[call_infs[current_number-1].number_id].sim_id));
    addcontacts += new T.AddContact(dbus, contact_info, true);
    addcontacts[addcontacts.length-1].saved_signal += update_contact;
    addcontacts[addcontacts.length-1].run(obj, event_info);

    }


    public void showIn( Evas.Object obj, void* event_info){
        debug( "show In" );
all_flag = false;
    show_calls(0);
    }

    public void showOut( Evas.Object obj, void* event_info){
        debug( "show Out" );
all_flag = false;
    show_calls(1);
    }
    public void showMis( Evas.Object obj, void* event_info){
        debug( "show Mis" );
all_flag = false;
  show_calls(2);

    }
    public void showAll( Evas.Object obj, void* event_info){
        debug( "show All" );
all_flag = true;
  show_calls(3);
    }

    public static int sqlite_callback (int n_columns, string[] values,
                                string[] column_names)
    {
debug("sqlite callback running");
        for (int i = 0; i < n_columns; i++) {
            stdout.printf ("%s = %s\n", column_names[i], values[i]);
        }
        stdout.printf ("\n");

StringBuilder edit = new StringBuilder(values[1]);
edit.erase(0,1);
edit.erase(edit.len-1,1);
string duration = "";
if(n_columns > 4){
if(values[6] != null) duration = values[6];
}
int type = 0;
if(duration == "" && values[2] == "0"){ 
type = 2;
}else if(values[2] == "1"){
type = 1;
}

if (duration == "") duration = "N/A";

call_info call_i = call_info(){number = edit.str, time = values[3], duration = duration, type = type, number_id = get_number_id(edit.str)};
call_infs += call_i;
count += 1;


if(call_infs.length > 1 && (call_infs[call_infs.length - 2].number in call_infs[call_infs.length - 1].number || call_infs[call_infs.length - 1].number in call_infs[call_infs.length - 2].number)){
longs[longs.length-1] += 1;
}else{
longs += 1;
}



        return 0;
    }



    public void show_calls(int calls_type){
current_page = calls_type;
list.clear();
    string statement = "";
call_infs = {};
count = 0;
longs = {};

    switch(calls_type){
case 0:
statement = "select id, number, direction, datetime(startTime, 'localtime'), activeTime, datetime(releaseTime, 'localtime'), duration  from calls where direction=0 AND activeTime IS NOT NULL  ORDER BY startTime DESC";
break;
case 1:
statement = "select id, number, direction, datetime(startTime, 'localtime'), activeTime, datetime(releaseTime, 'localtime'), duration from calls where direction=1 ORDER BY startTime DESC";
break;
case 2:
statement = "select id, number, direction, datetime(startTime, 'localtime') from missed_calls where direction = 0  ORDER BY startTime DESC";
break;
case 3:
statement = "select id, number, direction, datetime(startTime, 'localtime'), activeTime, datetime(releaseTime, 'localtime'), duration from calls  ORDER BY startTime DESC";
break;
}
        rc = db.exec (statement, sqlite_callback, null);
        if (rc != Sqlite.OK) { 
            stderr.printf ("SQL error: %d, %s\n", rc, db.errmsg ());
        }

int cou = 0;
for(int i = 0; i<longs.length; ++i ){
cou += longs[i];
if(longs[i] == 1){
list.item_append( itc, (void*)cou, null, Elm.GenlistItemFlags.NONE, onSelectedItem );
}else{
int cou_ex =  cou - longs[i] + 1;
list.item_append( itc, (void*)cou_ex, null, Elm.GenlistItemFlags.SUBITEMS, onSelectedItem );
}
}

}

public void get_all_numbers(){
db_numbers = {};
string statement = "select distinct number from calls";
        rc = db.exec (statement, sqlite_numbers, null);
        if (rc != Sqlite.OK) { 
            stderr.printf ("SQL error: %d, %s\n", rc, db.errmsg ());
        }

}


    public static int sqlite_numbers (int n_columns, string[] values,
                                string[] column_names)
    {
debug("sqlite callback for numbers running");
        for (int i = 0; i < n_columns; i++) {
            stdout.printf ("%s = %s\n", column_names[i], values[i]);
        }
        stdout.printf ("\n");

StringBuilder edit = new StringBuilder(values[0]);
edit.erase(0,1);
edit.erase(edit.len-1,1);

db_numbers += edit.str;

return 0;
}


public int get_number_id(string number){
int number_id = 0;
for(int i = 0; i < number_infos.length; ++i){
if(number_infos[i].number == number){
debug("Have a match for number, returning id accordingly");
number_id = i;
break;
}
}

return number_id;
}


public void get_names(){

for(int j= 0; j < db_numbers.length; ++j){
if(db_numbers[j] != "***"){
debug("checking for name in phone memory for number: %s", db_numbers[j]);
//checking for name in phone memeory

      GLib.HashTable<string, string>  cont_query = new GLib.HashTable<string, string>(GLib.str_hash, GLib.str_equal);
      cont_query.insert( "cellnumber", db_numbers[j]); //right now checking only for cellnumber - untill opimd is complete - don't see any point in wasting time
      string query_path = dbus_contacts.Query(cont_query);
//      debug(query_path); 
Freesmartphonen.ContactQuery dbus_query = (Freesmartphonen.ContactQuery) dbus.get_object<Freesmartphonen.ContactQuery> ("org.freesmartphone.opimd", query_path);
int results_count = dbus_query.GetResultCount();
if(results_count != 0){
dbus_query.Skip(results_count - 1);
GLib.HashTable<string, GLib.Value?>  qw_result = dbus_query.GetResult();

GLib.Value temp_val = qw_result.lookup("name");
string contact_name = temp_val.get_string();
debug("found match in phone memory! %s", contact_name);
temp_val = qw_result.lookup("cellnumber");
string contact_number = temp_val.get_string();
temp_val = qw_result.lookup("Path");
string contact_path = temp_val.get_string();

number_infos += number_info(){name = contact_name, number = db_numbers[j], storage_type = 1, sim_id = 0, opim_path = contact_path};

}else{ //means nothing in phone memory
//end checking in phone memory

debug("checking for name in sim phonebook");
string name = "";
string number = db_numbers[j];
int sim_position = 0;
bool match = false;
for(int i =0; i < book.length; ++i){
if(number in book[i].attr3 || book[i].attr3 in number){
debug("number: %s matches %s with number %s", number, book[i].attr2, book[i].attr3);
match = true;
name = book[i].attr2;
sim_position = book[i].attr1;
break;
}
}
int st_type = 0;
if (match == true) st_type = 2;
number_infos += number_info(){name = name, number = number, storage_type = st_type, sim_id = sim_position, opim_path = ""};
}
}else{
number_infos += number_info(){name = "Hidden", number = "***", storage_type = 0, sim_id = 0, opim_path = ""};
}
}
}

public void update_contact(string name_new, string number_new, int storage_type, int sim_id, string opim_path){
debug("updating contact on a list with number %d , name: %s, number: %s", current_number, name_new, number_new);

number_infos[call_infs[current_number-1].number_id].name = name_new;
number_infos[call_infs[current_number-1].number_id].storage_type = storage_type;
switch(storage_type){
case 1:
number_infos[call_infs[current_number-1].number_id].opim_path = opim_path;
break;
case 2:
number_infos[call_infs[current_number-1].number_id].sim_id = sim_id;
break;
}

show_calls(current_page);
//call_infs[current_number-1].number = number_new; - we don's need to change number - it would have no sence
}