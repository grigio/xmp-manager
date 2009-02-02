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

module XmpManager

module Exiftool
  EXIFTOOL = "/usr/bin/exiftool"
  
  def load_fields(path)
    fields = {}
    command = "|#{EXIFTOOL} #{path} -xmp:all"
    puts ">> #{command}" if DEBUG
    cmd = open(command)
	  while (temp = cmd.gets)
		  key, value = parse_line(temp)
		  fields[key] = value unless key.nil?
	  end
	  cmd.close
	  fields
  end  
  
  def save
    field_list = ''
    fields.each do |field, value|
      unless field == 'subject'
        field_list << " -xmp:#{field}=\"#{value}\""
      else
        if not tags.empty?
          tags = value.split(", ")
          tags.each {|tag| field_list << " -xmp:#{field}=\"#{tag}\""}
        else
          field_list << " -xmp:subject=\"\" "
        end
      end
	  end
	  command = "#{EXIFTOOL} #{path} #{field_list} -overwrite_original_in_place"
	  puts ">> #{command}" if DEBUG
	  cmd = system command
  end
  # --
  
  private
    
	def parse_line(line)
		# "Country                         : italia".downcase.strip
		key, value = line.split(': ') unless line.nil?
		return nil, nil if key.nil? || value.nil?
		key.downcase!.gsub!(' ','').gsub!("/",'_') # To generate valid methods in Selection
		value[-1]='' #remove a capo
		return key, value
	end
	
end

end
