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

require 'xmpmanager/backend/exiftool'

module XmpManager

class File
  # backend specific methods
  include XmpManager::Exiftool

  def initialize(path)
    @path = path
    @field = load_fields(path)
  end

  def path
    @path
  end
  
  def field
    @field
  end
  alias_method :fields, :field
  
  # is selection? TODO: write tag?
  def tags
    if @field['subject']
      @field['subject'].split(', ').sort
    else
      []
    end
  end

  def reload!
    
  end

#  def save
#    
#  end
  
  
  #private
  

end

end
