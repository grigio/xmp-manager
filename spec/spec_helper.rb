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

require 'stringio'
 
dir = File.dirname(__FILE__)
lib_path = File.expand_path("#{dir}/../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
$_spec_spec = true # Prevents Kernel.exit in various places
 
require 'spec'
require 'spec/mocks'
require 'spec/story'
spec_classes_path = File.expand_path("#{dir}/../spec/spec/spec_classes")

DEBUG = false
#require 'xmpmanager/file'
require 'xmpmanager/selection'
#require 'xmpmanager/backend/exiftool'

module Spec
  module Example
    class NonStandardError < Exception; end
  end
 
  module Matchers
    def fail
      raise_error(Spec::Expectations::ExpectationNotMetError)
    end
 
    def fail_with(message)
      raise_error(Spec::Expectations::ExpectationNotMetError, message)
    end
 
    def exception_from(&block)
      exception = nil
      begin
        yield
      rescue StandardError => e
        exception = e
      end
      exception
    end
    
    def run_with(options)
      ::Spec::Runner::CommandLine.run(options)
    end
 
    def with_ruby(version)
      yield if RUBY_PLATFORM =~ Regexp.compile("^#{version}")
    end
  end
end
 
def with_sandboxed_options
  attr_reader :options
  
  before(:each) do
    @original_rspec_options = ::Spec::Runner.options
    ::Spec::Runner.use(@options = ::Spec::Runner::Options.new(StringIO.new, StringIO.new))
  end
 
  after(:each) do
    ::Spec::Runner.use(@original_rspec_options)
  end
  
  yield
end
 
def with_sandboxed_config
  attr_reader :config
  
  before(:each) do
    @config = ::Spec::Example::Configuration.new
    @original_configuration = ::Spec::Runner.configuration
    spec_configuration = @config
    ::Spec::Runner.instance_eval {@configuration = spec_configuration}
  end
  
  after(:each) do
    original_configuration = @original_configuration
    ::Spec::Runner.instance_eval {@configuration = original_configuration}
    ::Spec::Example::ExampleGroupFactory.reset
  end
  
  yield
end
