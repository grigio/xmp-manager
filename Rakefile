$:.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'rubygems'
require 'spec/version'
require 'spec/rake/spectask'

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
end

task :RegenerateUi do
  puts "Regenerate the Gtk GUI"
  system 'gtk-builder-convert data/xmpmanager/nautilus-xmp-manager.glade data/xmpmanager/nautilus-xmp-manager.ui'
end

task :RegeneratePot do
  puts "Regenerate the Pot"
  system 'rgettext data/xmpmanager/nautilus-xmp-manager.glade > po/xmp-manager.pot'
end

task :RegenerateDeb do
  puts "TODO Regenerate the Deb"
  system 'insert command here'
end
