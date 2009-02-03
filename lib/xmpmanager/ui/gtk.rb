# XMP Manager is a GUI to easly write XMP Metadata and tags on files
# 
# Copyright (C) 2007 Luigi Maselli <luigix_@t_gmail_com>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
# St, Fifth Floor, Boston, MA 02110-1301 USA

require 'gtk2'

module XmpManager

class MainWindow
  def initialize
    @selection = XmpManager::Selection.new(ARGV)
    
    init_gui
  end
  
  def init_gui
    Gtk.init
    b = Gtk::Builder.new
    b.add_from_file(DATA_DIR+'/xmpmanager/nautilus-xmp-manager.ui')

    # It generates dynamic methods/signals called by UI
    b.connect_signals{|name|
      method(name)
    }
    
    # It generates signals from avalaible fields in the UI
    b.objects.each do |obj|
    	begin
    	  name = obj.name
      	instance_variable_set("@#{name.gsub('_auto', '')}".intern, b.get_object(name))
      	if name[-5..-1]=='_auto'
          name = name.gsub('_auto', '')
          
  				eval <<-END
  				  @#{name}.text = @selection.#{name}
						@#{name}.signal_connect('changed') do
						 @selection.#{name} = @#{name}.text
						end
  				END
  				
      	end
      rescue
    	end
    end
    # FIXME: merge fields with default template OR template without dynamic?
    
        
    @window = b.get_object('window')
    @tag_box = b.get_object('tag_box')
    @tag_entry = b.get_object('tag_entry')
    @add_tag_button = b.get_object('add_tag_button')
    @save_button = b.get_object('save_button')
    
    
    @selection.tags.each do |tag|
      create_tag_checkbutton(tag, true)
    end
    
    
    @window.show_all
    
    Gtk.main
  end
  
  def confirm(message)
    #TODO
    true
  end
  
  ## GUI methods/signals
  
  def on_add_tag_button_pressed
	  checkbutton = @tag_entry.text
    create_tag_checkbutton(checkbutton, true)
	  @tag_entry.text='' # valid
	  # non valid exception
  end
  
  def on_save_button_clicked
    @selection.save
    # quit
  end
  
  def on_window_destroy
    #@selection.changed? Gtk.main_quit : confirm('The changes made will be lost')
    Gtk.main_quit
  end
  
  def update_tag_box
    if is_valid_tag @tag_entry.text
  	  checkbutton = @tag_entry.text
      create_tag_checkbutton(checkbutton, false)
  	  @tag_entry.text=''
  	end  
  end
  
  #
  # Create the checkbutton with a value set and adds the signal to manage it
  #
  def create_tag_checkbutton(label, active = false)
    # HACK it bans some annoying characters
    # BUG àèìòù and others can't be used :(
    # checkbutton=checkbutton.gsub(':','_').gsub('=','_').gsub('.','_').gsub('-','_')
  	
  	# FIXME Each runtime cb should have a unique name
  	checkbutton = 'cb'+rand(1000).to_s
  	@selection.tag_add(label) if active
  	
    #   	 gtk_widget_ref(widget);
    #      gtk_container_remove(GTK_CONTAINER(old_parent), widget);
    #      gtk_container_add(GTK_CONTAINER(new_parent), widget);
    #      gtk_widget_unref(widget);
  	
  	eval <<-END
     @#{checkbutton} = Gtk::CheckButton.new('#{label}')
     # FIXME WARNING to fix
     @tag_box.pack_start(@#{checkbutton}, false, false)
     @#{checkbutton}.active = active
     @#{checkbutton}.signal_connect('toggled') do
      if @#{checkbutton}.active?
        @selection.tag_add @#{checkbutton}.label
      else
        @selection.tag_del @#{checkbutton}.label
      end
     end
     @tag_box.add @#{checkbutton}.show
    END
    
  end

  def quit
    Gtk.main_quit
  end

end

end
