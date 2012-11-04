require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "html5small"
    gem.summary = %Q{HTML5small}
    gem.description = %Q{Minifier for HTML5 documents}
    gem.email = "ruben.verborgh@gmail.com"
    gem.homepage = "http://github.com/RubenVerborgh/HTML5small"
    gem.authors = ["Run Paint Run Run", "Ruben Verborgh"]
    gem.add_dependency "htmlentities", ">= 4.1.0"
    gem.add_dependency "nokogiri", ">= 1.5.0"
    gem.add_development_dependency "rspec", ">= 2.0.0"
    gem.add_development_dependency "yard", ">= 0"
    gem.executables << 'html5small'
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
