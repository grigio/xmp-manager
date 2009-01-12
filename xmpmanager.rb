#!/usr/bin/ruby

# XMP Manager is a GUI to easly write XMP Metadata and tags on files
# 
# Copyright (C) 2007 Luigi Maselli <riccio_@t_inmail_sk>
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

$LOAD_PATH << File.expand_path(File.dirname(__FILE__)+'/lib')
DATA_DIR = File.expand_path(File.dirname(__FILE__))+'/data'
EXIFTOOL = "/usr/bin/exiftool"
DEBUG = false

require 'monitor'
require 'libglade2'

#
# Just to debug better
#
class Object
  def method_name
    if  /`(.*)'/.match(caller.first)
      return $1
    end
    nil
  end
end

class String
  def prepare_for_shell
    self.gsub(/\s/,'\ ')
  end
end

#
# It executes really the actions
#
class Controller
  def initialize
    @metadata = Hash.new
    load_file_paths #set @files if possible
    load_metadata
    chunks = @files[0].split('/')
    @current_directory = chunks[0..chunks.size-2].join('/') || "."
    #View.new(self)
  end
  
  def valid_tags_cache?(filename)
    puts "\n\n filename:#{filename}"
    begin
    if File::mtime(filename).min == Time.now.min
      return true
    end
    rescue
    end
      return false
  end
  
  #
  # Return the tags of other photos
  #
  def external_tags
    all_tags=[]
    filename = "#{@current_directory}/.tags.cache"
    
    # a recent cache    
    if valid_tags_cache?(filename)
      File.open(filename).each_line{|tag| all_tags << tag.strip}
    else    
    # scan the filesystem
    	cmd = open("|#{EXIFTOOL} #{@current_directory.prepare_for_shell} -xmp:subject")
		  while (temp = cmd.gets)
		    # good string with :
    		if temp[0..32] == 'Subject                         :'
      		#temp = cmd.gets
      		key, value = parse_line(temp)
      		all_tags += value.split(', ') unless value.nil?
      	end
    	end
		  cmd.close
		  puts "\n>> #{method_name}\n"+all_tags.inspect if DEBUG
    end

		ext_tags = all_tags.uniq - @tags
		ext_tags ||= []
		# HACK
		@external_tags = ext_tags
		return ext_tags
  end
  
  def tags
		cmd = open("|#{EXIFTOOL} #{@files[0].prepare_for_shell} -xmp:subject")
		#while (temp = cmd.gets)
		temp = cmd.gets
			key, value = parse_line(temp)
			@tags = value.split(', ') unless value.nil?
		#end
		cmd.close
		puts "\n>> #{method_name}\n"+@tags.inspect if DEBUG
		@tags ||= []
		return @tags
  end
  
  def metadata(field)
    @metadata[field]
  end
  
  def write(field, value)
		# hihi
		#Thread.new {
		@files.each do |filename|
			# TODO: multiple command & errors
			command = "|#{EXIFTOOL} #{filename.prepare_for_shell} -xmp:#{field}=\"#{value}\" -overwrite_original_in_place"
			cmd = open(command)
			puts "\n>> #{method_name}\n"+command if DEBUG
			#while (temp = cmd.gets)
			cmd.close
		end
		#}
		puts "\n>> #{method_name}\n"+field+"-"+value if DEBUG
	end
  
  def write_tags
    @files.each do |filename|
			xmp_subjects=''
			@tags.each do |tag|
			  xmp_subjects << " -xmp:subject=\"#{tag}\""
			end
			xmp_subjects = " -xmp:subject=\"\"" if xmp_subjects == ''
			command = "|#{EXIFTOOL} #{filename.prepare_for_shell} #{xmp_subjects} -overwrite_original_in_place"
			cmd = open(command)
			puts "\n>> #{method_name}\n"+command if DEBUG
			cmd.close
		end
  end
  
  def add_tag(value)
    @tags << value
    write_tags
	end
  
  def delete_tag(value)
	  @tags.delete value
	  write_tags
	end
  
  def load_file_paths(array = nil)
    # ARGV[0..-1]
    @files = array # from GUI
    @files ||= ARGV[0..-1] if ARGV
    #@files ||= ["test-img-tante/a.jpg", "test-img-tante/b.jpg"]
    if @files.empty?
      puts "\n>> #{method_name}\n"+"You need to specify at least a file!"
      exit(1)
    end
    puts "\n>>  #{method_name}\n"+@files.inspect+"  \n end\n" if DEBUG
  end

  
  # initially only field from the first selection are checked
  def load_metadata
    cmd = open("|#{EXIFTOOL} #{@files[0].prepare_for_shell} -xmp:all")
	  while (temp = cmd.gets)
		  key, value = parse_line(temp)
		  @metadata[key] = value unless key.nil?
	  end
	  cmd.close
	  puts "\n>> #{method_name}\n"+@metadata.inspect+"\n END \n" if DEBUG
  end
  
  def quit
    #save external_tags
    File::open("#{@current_directory}/.tags.cache",'w'){|f| f.write(@external_tags.join("\n"))}    
  end
  
	def parse_line(line)
		# "Country                         : italia".downcase.strip
		key, value = line.split(': ') unless line.nil?
		return nil, nil if key.nil? || value.nil?
		key.downcase!.gsub!(' ','')
		value[-1]='' #remove a capo
		return key, value
	end
  
end

class View

  def initialize
    @controller = Controller.new
    init_gui
    setup_tag_box
    update_gui
    
    @lock= Monitor.new
		@confirm_secs= 1
		@ready_to_write= true
		
		@metadata_dialog.show_all
		
  end
  
  
  #
  # It fills the widgets
  #
  def update_gui
    # custom fields
    @glade.widget_names.each do |name|
    	begin
      	if name[-5..-1]=='_auto' #auto event widget
          
          @glade[name].text = @controller.metadata(name.gsub('_auto', ''))

      	end
      rescue
    	end
    end
  end
  
  #
  # It loads the widgets
  #
  def init_gui
    @glade = GladeXML.new(DATA_DIR+"/nautilus-xmp-manager.glade") {|handler| method(handler)}

    # Widgets used not autogenerated
    @tag_box = @glade['tag_box']
    @tag_entry = @glade['tag_entry']
    @add_tag_button = @glade['add_tag_button']


    # Autogenerated variables and by the entry-name_auto
    @glade.widget_names.each do |name|
    	begin
      	instance_variable_set("@#{name.gsub('_auto', '')}".intern, @glade[name])
      	if name[-5..-1]=='_auto'
          name = name.gsub('_auto', '')
          
  				eval <<-END
						@#{name}.signal_connect('changed') do
						 #puts @#{name}.text
						 try_to_write(@#{name})
						end
  				END
  				
      	end
      rescue
    	end
    end

    # Widget signals
    @metadata_dialog.signal_connect('destroy'){
    	quit
    }
    @close_button.signal_connect('pressed'){
    	quit
    }
    
    @add_tag_button.signal_connect('pressed'){
      update_tag_box
    }
    
    
    @glade['help_button'].signal_connect('clicked'){
      #
    }
    

    # 		for widget in @glade.widgets
    # 			if widget.class? Gtk::Textbox #or combo
    # 				#widget.add_method(:signal_connect('changed') {try to})
    # 			end
    # 		end

    
    # Widget default values
    @metadata_dialog.title='Metadata Manager'
    @notebook.page = 0 # force page 0 see glade
  end
  
  #
  # It fills the tag_box with tags and external_tags found
  #
  def setup_tag_box
    @controller.tags.each do |tag|
      create_tag_checkbutton(tag, true)
    end
    @controller.external_tags.each do |tag|
      create_tag_checkbutton(tag)
    end
  end
  
  def is_valid_tag(tag)
    puts "\n>> #{method_name}\n"+@tag_entry.text.inspect if DEBUG
    # FIXME it should permit only utf8 a-z an spaces
    tag != ''
  end
  
  
  #
  # Add a tag that is not present in tag_box from user input 
  #
  def update_tag_box
    if is_valid_tag @tag_entry.text
      checkbutton = @tag_entry.text
      create_tag_checkbutton(checkbutton, true)
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
        @controller.add_tag @#{checkbutton}.label
      else
        @controller.delete_tag @#{checkbutton}.label
      end
     end
     @tag_box.add @#{checkbutton}.show
    END
    
    
     puts "\n>> #{method_name}\n"+checkbutton.inspect if DEBUG
  end
  
  #
  # Enabled everytime a char is pressed in a texbox
  #
	def try_to_write(widget)

    	# interrompe thread di scrittura se esiste, altrimenti scritture multiple
			@tmain.kill if @tmain.is_a? Thread

    	@previous_title= widget.text

    	#Thread principale
    	@tmain= Thread.new do    	

    	  sleep @confirm_secs #conferma

    		if (@previous_title == widget.text)
    			@t1= Thread.new do
    				@lock.synchronize do
    					puts "\n>> #{method_name}\n"+
    					     "#{@previous_title} poi #{widget.text} @@ #{widget.name.gsub('_auto', '')}" if DEBUG
    					@controller.write(widget.name.gsub('_auto', ''), widget.text)
    				end
    			end
				end
			
			end #thread
			#@tmain.join
			
	end
  
  def load_file_paths
    update_gui
  end
	
	def quit
	  @controller.quit
	  # HACK: a writing couldn't be finished yet
	  while @tmain.alive? do
      sleep 0.1
    end
		Gtk.main_quit
	end

end

Gtk.init
View.new
Gtk.main

## DEBUG INPUT from Nautilus-actions 
# Gtk.init
# window = Gtk::Window.new
# button=Gtk::Button.new
# window.add button
# button.label = ARGV.inspect
# window.show_all
# Gtk.main

