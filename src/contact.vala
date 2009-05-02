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

using DBus;
namespace Freesmartphonen{
[DBus (name = "org.freesmartphone.PIM.Contacts")]
public interface Contacts : GLib.Object {
	public abstract void Add(GLib.HashTable<string, string> contact_data);
	public abstract string Query(GLib.HashTable<string, string> query_data)  throws DBus.Error;
}

[DBus (name = "org.freesmartphone.PIM.Contact")]
public interface Contact : GLib.Object {
	public abstract void Update(GLib.HashTable<string, string> contact_data);
	public abstract void Delete();
	public abstract GLib.HashTable<string, GLib.Value?> GetContent()  throws DBus.Error;
}

[DBus (name = "org.freesmartphone.PIM.ContactQuery")]
public interface ContactQuery : GLib.Object {
	public abstract GLib.HashTable<string, GLib.Value?> GetResult()  throws DBus.Error;
	public abstract int GetResultCount()  throws DBus.Error;
	public abstract void Skip(int to_skip)  throws DBus.Error;
}

}

public class T.Contact : T.Abstract
{
    Elm.Bg bg;
    Elm.Frame contact_frame;
    Elm.Label contact_label;
    Elm.Box main_box;
    Elm.Box inner_box;
    Elm.Table main_table;
    Elm.Scroller main_scroller;
    Elm.Label[] label_names;
    Elm.Label[] label_values;
    string contact_path;
    string contact_name;
    Elm.Photo contact_photo;
    Elm.Box footer_box;
    Elm.Hoversel h_call;
    Elm.Hoversel h_send;
    Elm.Button edit_button;
/*
public FreeSmartphone.GSM.SIMEntry[] book2;
*/
public DBus.Connection dbus;
public Freesmartphonen.Contacts dbus_contacts;

public Freesmartphonen.Contact dbus_contact;

public Contact(DBus.Connection dbus_par, string contact_p){
dbus = dbus_par;

dbus_contact =  (Freesmartphonen.Contact) dbus.get_object<Freesmartphonen.Contact> ("org.freesmartphone.opimd", contact_p);
contact_path = contact_p;
}

    public override void run(  Evas.Object obj, void* event_info  )
    {

string[] field_names = {"First name:", "Second name:", "Cell number:", "Home number:", "Work number:", "E-mail:", "Group:","In common:" ,"Second E-mail:","Web page:", "SIP:", "Jabber:", "Comments:"};
//group, Common

        open();
        bg = new Elm.Bg( win );
//        bg.file_set( "/usr/share/backgrounds/space-02.jpg" );
        bg.size_hint_weight_set( 1.0, 1.0 );
        bg.size_hint_min_set( 160, 160 );
        bg.size_hint_max_set( 640, 640 );
        bg.show();

      win.resize_object_add( bg );

        main_box = new Elm.Box( win );
	main_box.size_hint_weight_set( 1.0, 1.0 );
	main_box.size_hint_align_set( -1.0, -1.0 );
        main_box.show();
        win.resize_object_add( main_box );



	contact_frame = new Elm.Frame(win );
	contact_frame.style_set("outdent_top");
//	contact_frame.size_hint_weight_set( 1.0, 1.0 );
//	contact_frame.size_hint_align_set( -1.0, -1.0 );
	contact_frame.show();
	main_box.pack_start(contact_frame);

	contact_label = new Elm.Label( win );

	contact_label.scale_set( 2 );
	contact_label.show();
	contact_frame.content_set(contact_label);

	main_scroller = new Elm.Scroller( win );
	main_scroller.size_hint_weight_set( 1.0, 1.0 );
	main_scroller.size_hint_align_set( -1.0, -1.0 );
	main_scroller.show();
	main_box.pack_end(main_scroller);

        inner_box = new Elm.Box( win );
	inner_box.size_hint_weight_set( 1.0, 1.0 );
	inner_box.size_hint_align_set( -1.0, -1.0 );
        inner_box.show();
	main_scroller.content_set(inner_box);
//	main_box.pack_end(inner_box);


	main_table = new Elm.Table( win );
	main_table.size_hint_align_set( -1.0, -1.0 );
	main_table.size_hint_weight_set( 1.0, 1.0 );
	main_table.homogenous_set( false );
	main_table.show();
	inner_box.pack_start(main_table);

label_names = new Elm.Label[field_names.length];
label_values = new Elm.Label[field_names.length];

string[]? actual_values = get_values();
	contact_label.label_set(contact_name);

for(int i=0; i <field_names.length; ++i){
	label_names[i] = new Elm.Label( win );
        label_names[i].label_set( field_names[i] );  
	label_names[i].size_hint_align_set( -1.0, -1.0 );
//	label_names[i].scale_set( 1.4 );
        label_names[i].show();
	main_table.pack(label_names[i], 0, i, 1, 1 ); 

        label_values[i] = new Elm.Label( win );
if(actual_values != null){
        label_values[i].label_set( actual_values[i] );
}
	label_values[i].size_hint_weight_set( 1.0, 0.0 );
	label_values[i].size_hint_align_set( -1.0, -1.0 );
//	label_values[i].scale_set( 1.4 );
        label_values[i].show();
	main_table.pack(label_values[i], 1, i, 1, 1 ); 

}

	contact_photo = new Elm.Photo( win );
	contact_photo.size_hint_align_set( -1.0, -1.0 );
	contact_photo.size_hint_weight_set( 1.0, 1.0 );
	contact_photo.size_set(180);
	if (actual_values != null) contact_photo.file_set(actual_values[actual_values.length - 1]); //last entry in array
        contact_photo.show();
	inner_box.pack_end(contact_photo);

        footer_box = new Elm.Box( win );
	footer_box.horizontal_set( true );
        footer_box.size_hint_align_set( -1.0, -1.0 );
        footer_box.show();
	main_box.pack_end(footer_box);
 
        h_call = new Elm.Hoversel( win );
        h_call.hover_parent_set( win );
	h_call.label_set( "Call" ); //just mockup right now
	h_call.size_hint_weight_set( 1.0, 1.0 );
	h_call.size_hint_align_set( -1.0, -1.0 );
	h_call.item_add( "Cell", null, Elm.IconType.NONE, null ); //not adding items if not available
	h_call.item_add( "Home", null, Elm.IconType.NONE, null );
	h_call.item_add( "Work", null, Elm.IconType.NONE, null );
	h_call.item_add( "SIP", null, Elm.IconType.NONE, null );
        h_call.show();
        footer_box.pack_start( h_call );
      

        h_send = new Elm.Hoversel( win );
        h_send.hover_parent_set( win );
	h_send.label_set( "Send" ); //just mockup right now
	h_send.size_hint_weight_set( 1.0, 1.0 );
	h_send.size_hint_align_set( -1.0, -1.0 );
	h_send.item_add( "SMS", null, Elm.IconType.NONE, null );
	h_send.item_add( "E-mail", null, Elm.IconType.NONE, null ); //not adding if not available
        h_send.show();  
        footer_box.pack_end( h_send );
    
	edit_button = new Elm.Button (win);
	edit_button.label_set("Edit");
	edit_button.size_hint_weight_set( 1.0, 1.0 );
	edit_button.size_hint_align_set( -1.0, -1.0 );
	edit_button.smart_callback_add( "clicked", edit_clicked );
	edit_button.show();
	footer_box.pack_end( edit_button );

    }

    public void edit_clicked(  Evas.Object obj, void* event_info) {
    close();
    }

public string[]? get_values(){ //array of strings corresponding to our labels + photo_path as last one
// {"Contact name:", "First name:", "Second name:", "Cell number:", "Home number:", "Work number:", "E-mail:", "Group:","In common","Second E-mail:","Web page:", "SIP:", "Jabber:", "Comments:"};
string[] cont_values = {}; //order should be the same

GLib.HashTable<string, GLib.Value?>  qw_result = dbus_contact.GetContent();

Value temp_val = qw_result.lookup("name");
contact_name = temp_val.get_string();
temp_val = qw_result.lookup("firstname");
cont_values += temp_val.get_string();
temp_val =  qw_result.lookup("secondname");
cont_values += temp_val.get_string();
temp_val =  qw_result.lookup("cellnumber");
cont_values += temp_val.get_string();
temp_val =  qw_result.lookup("homenumber");
cont_values += temp_val.get_string();
temp_val =  qw_result.lookup("worknumber");
cont_values += temp_val.get_string();
temp_val =  qw_result.lookup("email");
cont_values += temp_val.get_string();
temp_val =  qw_result.lookup("group");
cont_values += temp_val.get_string();
temp_val =  qw_result.lookup("common");
cont_values += temp_val.get_string();
temp_val =  qw_result.lookup("secondemail");
cont_values += temp_val.get_string();
temp_val =  qw_result.lookup("webpage");
cont_values += temp_val.get_string();
temp_val =  qw_result.lookup("sip");
cont_values += temp_val.get_string();
temp_val =  qw_result.lookup("jabber");
cont_values += temp_val.get_string();
temp_val =  qw_result.lookup("comments");
cont_values += temp_val.get_string();
temp_val =  qw_result.lookup("photoimage");
cont_values += temp_val.get_string();

for(int i =0; i < cont_values.length; ++i){
debug(cont_values[i]);
}
return cont_values;
 
}

    public override string name()
    {
        return "Window with background";
    }
}
