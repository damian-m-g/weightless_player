#necessary for minitest tests
require 'rake/testtask'

#################TASKS#######################

#to execute minitest tests with `rake test`
Rake::TestTask.new do |t|
  #search recursively under the folder test for files called test*. You may have to create the folder manually.
  t.pattern = 'test/**/test*.rb'
end

desc 'to generate RDoc documentation'
task :rdoc do
  system('rdoc --all --tab-width=1 --force-output --main="ReadMe.md" --exclude="bin" --exclude="data" --exclude="ext" --exclude="share" --exclude="doc" --exclude="test" --exclude="cocot.gemspec" --exclude="Gemfile" --exclude="Gemfile.lock" --exclude="Rakefile"')
end

desc 'ocra --no-lzma'
task :ocra_no_lzma, :version do |t, args|
  args.with_defaults(:version => '')
  system("ocra --chdir-first --no-lzma --output 'youtube_lister#{args[:version].!=('') ? "_#{args[:version]}" : ''}.exe' './bin/youtube_list' './lib/**/*' './data/*'")
end

desc 'ocra'
task :ocra, :version do |t, args|
  args.with_defaults(:version => '')
  system("ocra --chdir-first --output 'youtube_lister#{args[:version].!=('') ? "_#{args[:version]}" : ''}.exe' './bin/youtube_list' './lib/**/*' './data/*'")
end