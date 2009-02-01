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

require './spec/spec_helper.rb'

module XmpManager

describe File do
  before(:each) do
    @gnome_cup = XmpManager::File.new('spec/images/gnome-cup.jpg')
    @ubuntu_cup = XmpManager::File.new('spec/images/ubuntu-cup.jpg')
  end

  it "should load fields" do
    @gnome_cup.field['creator'].should == 'luigi'
    @gnome_cup.field['title'].should == 'un titolò'
  end


  it "should read tags" do
    @gnome_cup.tags.should == ['cup', 'gnome']
  end
  
  it "should be able to write a field" do
    @ubuntu_cup.field['title'] = 'my cup2'
    #@ubuntu_cup.save
    #@ubuntu_cup.reload!
    @ubuntu_cup.field['title'].should == 'my cup2'
    # restore
    @ubuntu_cup.field['title'] = 'my cup1'
    #@ubuntu_cup.save
  end
end

describe Selection do
  before(:each) do
    @selection = XmpManager::Selection.new('spec/images/gnome-cup.jpg', 'spec/images/ubuntu-cup.jpg')
  end

  it "should manage field" do
    @selection.field('title').should  == 'ubucup'
    
    # dynamic methods
    @selection.title_changed?.should == nil # INCONSISTENT
    @selection.title = 'ubucup'
    @selection.title_changed?.should == true
    @selection.title = '' # or nil
    @selection.title_changed?.should == false
    
    # fake write
  end

  it "should manage tags" do
    
    # With releated tags
    #@selection.tags.should == ["cup", "gnome", "logo", "tux", "ubuntu"]
    
    @selection.tags.should ==["cup", "gnome", "ubuntu"]
    @selection.tag_status('cup').should == true
    @selection.tag_status('tux').should == nil
    
    @selection.tag_del('cup')
    @selection.tag_status('cup').should == false
    
    @selection.tag_add('bau')
    @selection.tag_status('bau').should == true
    
  end

  # TODO remove sort
#  it "should load related tags" do
#    @selection.tags.should == ["cup", "gnome", "logo", "tux", "ubuntu"]
#  end

#  it "should load related tags with values" do
#    @selection.tags['cup'].should == ENABLED
#    @selection.tags['a non existent tag'].should == nil
#  end

end

end
