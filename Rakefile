require 'rubygems'
require 'rake/gempackagetask'
 
spec = Gem::Specification.new do |s|
  s.name = 'rack-mockups'
  s.version = '0.0.1'
  s.summary = 'Use static mockups until your application responds to the path using Rack middleware'
  s.files = FileList['[A-Z]*', 'lib/**/*']
  s.has_rdoc = false
  s.author = 'Ryan Carmelo Briones'
  s.email = 'ryan.briones@brionesandco.com'
  s.homepage = 'http://brionesandco.com/ryanbriones'
end
 
package_task = Rake::GemPackageTask.new(spec) {}
 
task :build_gemspec do
  File.open("#{spec.name}.gemspec", "w") do |f|
    f.write spec.to_ruby
  end
end
 
task :default => [:build_gemspec, :gem]
