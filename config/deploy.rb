require 'bundler/capistrano'

set :application, "alexandrews.info"
set :repository,  "https://github.com/conatus/dotinfo.git"
set :scm, :git
set :deploy_via, :remote_cache
set :branch, "master"
set :use_sudo, false
set :host, 'alexandrews.info'

role :web, host

set :user, ENV['USER']

ssh_options[:forward_agent] = true

set :deploy_to, "/home/#{user}/app/#{application}"

namespace :deploy do
	desc "Link to serving directory"
	task :link_served_directory do
		run "rm -rf /home/#{user}/#{application}"
		run "ln -s #{latest_release}/_site /home/#{user}/#{application}"
	end
end

namespace :jekyll do
	desc "Generate site on remote server"
	task :generate_site do
		run "cd #{latest_release} && bundle exec jekyll build"
	end
end

namespace :sass do
	desc "Convert SASS to CSS"
	task :convert_sass do
		run "cd #{latest_release} && bundle exec 'sass --update scss:css --style compressed'"
	end
end

after 'deploy:update_code', 'sass:convert_sass', 'jekyll:generate_site'
after 'deploy:update', 'deploy:link_served_directory'