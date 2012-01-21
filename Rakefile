require "bundler/gem_tasks"

task :test do
  Dir.glob("test/**/*_test.rb").each do |f|
    require File.expand_path(File.join(File.dirname(__FILE__), f))
  end
end
