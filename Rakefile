$:.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'rubygems'
require 'spec/version'
require 'spec/rake/spectask'

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
end

task :RegeneratePot do
  puts "Regenerate the Pot"
  system 'xgettext --from-code=UTF-8 --language=glade data/xmpmanager/nautilus-xmp-manager.ui -o po/xmpmanager.pot'
end

task :RegeneratePotRb do
  puts "Regenerate the Pot"
  system 'rgettext lib/xmpmanager/ui/gtk.rb -o po/xmpmanagerrb.pot'
end

task :RegeneratePo do
  puts "Regenerate the Po"
  system 'mkdir po/it_IT'
  system 'rmsgfmt po/it.po -o po/it_IT/xmpmanager.mo' #TODO: for each lang po avalaible
end

task :RegenerateDeb do
  puts "TODO Regenerate the Deb"
  system 'insert command here'
end
