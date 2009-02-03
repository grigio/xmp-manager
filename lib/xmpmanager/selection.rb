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

require 'xmpmanager/file'

module XmpManager

class Selection
  # backend specific methods
  include XmpManager::Exiftool

  def initialize(paths)
    # clean *paths ARGV ?
    #paths = 'spec/images/write-tests/a.jpg', 'spec/images/write-tests/b.jpg' if DEBUG
    @files = load_files(paths) # return a File Array
    @field, @status, @tags = {}, {}, {}
    #@field, @status, @tags = 
    load_selection # from @files
    load_dynamic_methods
    #load_dynamic_methods
    #load_template # common fields
  end
   
  def field(key = nil)
    if key.nil?
      @field
    else
      @field[key]
    end
  end  
  alias_method :fields, :field

  # Old style method *not dynamic*
  def field_set(key, value)
      @field[key] = value
  end  
  
  # it takes the intersection of common tags
  def tags
    @tags.keys.sort
  end
  
  def tag_add(tag)
    @tags[tag] = true
  end
  
  def tag_del(tag)
    @tags[tag] = false
  end
  
  def tag_status(tag)
    @tags[tag]
  end
  
  def status(key)
    @status[key]
  end
  
  def save
    @files.each do |file|
      @field.each do |key, value|
        file.field[key] = value
      end
      
      tags_to_write = ""
      @tags.each{|key, value| tags_to_write << key+", " if @tags[key] != false} #TODO: fix inconsistencies
      file.field['subject'] = tags_to_write
      
      file.save
    end
  end
  
  private
  
  def load_files(paths)
    files = []
    paths.each do |path| 
      files << XmpManager::File.new(path)
    end
    files
  end
  
  def load_selection
    # load default fields FIXME: move to template
    @field.merge! 'description' => '', 'creator' => '', 'rights' => '', 'title' => ''
    # load data
    @files.each do |file|
       @field.merge! file.fields
    end
    # load tags #FIXME: nil false true
    @files.each do |file|
      file.tags.each do |tag|
        @tags.merge! tag => true
      end
    end
  end

  def load_dynamic_methods
    # TODO: changed? false
    # ex. sel.title, sel.title = <value>, sel.title_changed?
    @field.each_key do |key|
      eval <<-STR
        def #{key}=(value)
          unless value.empty?
            @field['#{key}'] = value
            @status['#{key}'] = true
          else
            @status['#{key}'] = false
          end
        end
        def #{key};  @field['#{key}']; end
        def #{key}_changed?;  @status['#{key}']; end
      STR
    end
  end
  
end

end
