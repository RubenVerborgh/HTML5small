require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "h5-min"
    gem.summary = %Q{Minify HTML5}
    gem.description = %Q{Trivial command-line minifier for HTML5 markup}
    gem.email = "runrun@runpaint.org"
    gem.homepage = "http://github.com/runpaint/h5-min"
    gem.authors = ["Run Paint Run Run"]
    gem.add_dependency "htmlentities", ">= 4.1.0"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "yard", ">= 0"
    gem.executables << 'h5-min'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :spec => :check_dependencies

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
