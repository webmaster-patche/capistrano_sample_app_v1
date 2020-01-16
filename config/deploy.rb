# config valid for current version and patch releases of Capistrano
lock "~> 3.11.2"

set :application, "%app name%"
set :repo_url, "git@github.com:****/*****.git"

# Default branch is :master
# masterで良いので、特に変更は不要
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
# bundle exec cap %env% deploy BRANCH=feature/hogehoge
# set :branch, ENV['BRANCH'] || 'master'

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"
set :deploy_to, "/var/www/#{fetch(:application)}"

# Default value for :format is :airbrussh.
# set :format, :airbrussh
# Configure version management tool
set :scm, :git

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto
# Configure log_leve if you output the log file
# set :format, :pretty
# set :log_level, :info

# Default value for :pty is false
# set :pty, true
# sudoを使用する場合はtrue
set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"
# ln -s deploy_to/shared/config/database.yml :deploy_to/current/config/database.yml
set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
# sharedのディレクトリをcurrentにシンボリックリンクする
#set :linked_dirs, %w{bin log tmp/backup tmp/pids tmp/cache tmp/sockets vendor/bundle}
# binはrails consoleが必要なため、残す
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle')
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

# Default value for default_env is {}
# capistrano用bundleするのに必要
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :default_env, { path: "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5
# How many keep the component of deployed in the "releases" directory
set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
# Configure ssh agent
set :ssh_options, {
  keys: %w(~/.ssh/id_rsa),
  forward_agent: true,
  auth_methods: %w(publickey)
}

# Configure ur Slack's Incoming Webhook
# if you want to be disable deployment notifications to a specific stage by setting the :slackistrano configuration variable to false instead of actual settings.
set :slackistrano, false
#set :slackistrano, {
#  klass:   Slackistrano::CustomMessaging,
#  channel: '#chatops-#{fetch(:application)}-deploy',
#  webhook: 'https://hooks.slack.com/services/*/*/*'
#}

# Have you installed rbenv in the global area? Or was it installed in the user local area?
# :system or :user
set :rbenv_type, :user
# rubyのversion
set :rbenv_ruby, '2.6.5'
set :rbenv_path, '/usr/local/rbenv'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value

# Configure 
# rollback / deployを判定する為、before startingのcallbackで判定を取得する
# 参考：https://github.com/capistrano/capistrano/blob/v3.11.2/lib/capistrano/tasks/framework.rake#L57
before 'deploy:starting', 'slack:deploy:updating'

# https://github.com/capistrano/capistrano/blob/v3.11.2/lib/capistrano/dsl/task_enhancements.rb#L51
# https://www.rubydoc.info/github/capistrano/capistrano/Capistrano/TaskEnhancements
# 既存処理をOverride
module Capistrano
  module TaskEnhancements
    def exit_deploy_because_of_exception(ex)
      set :failed_exception, ex
      super ex
    end
  end
end

# Edited deploy task
namespace :deploy do

  desc 'git confirm'
  task :git_confirm do
    on release_roles :all do

      current = `git rev-parse --abbrev-ref HEAD`.chomp
      correct = fetch(:branch) || 'master'
      unless current == correct
        error "git: current branch is not '#{correct}' but '#{current}'."
        exit 1
      end
      # gitにdiffがないかどうかのチェック
      git_diff = `git diff`
      unless git_diff.empty?
        error "git: current source has any diff. \n#{git_diff}"
        exit 1
      end
    end
  end

  # 上記linked_filesで使用するファイルをアップロードするタスク
  desc 'Upload database.yml'
  task :upload do
    on roles(:app) do |host|
      if test "[ ! -d #{shared_path}/config ]"
        execute "mkdir -p #{shared_path}/config"
      end
      upload!('config/database.yml', "#{shared_path}/config/database.yml")
    end
  end

  desc 'Restart application'
  task :restart do
    # on roles(:app) do
    #   invoke 'unicorn:restart'
    # end
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  desc '.env publishing'
  task :env_publising do
    on roles(:app) do |host|
      if test "[ -f #{fetch(:deploy_to)}/.env ]"
        execute "cp -a #{fetch(:deploy_to)}/.env #{fetch(:release_path)}/.env"
      end
    end
  end
end

before 'deploy', 'deploy:git_confirm'
before 'deploy:starting', 'deploy:upload'
  # Enhance dotenv
after  'deploy:published', 'deploy:env_publising'
after  'deploy:published', 'deploy:restart'