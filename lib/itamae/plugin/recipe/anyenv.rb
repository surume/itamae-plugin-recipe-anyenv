DEFAULT_ANYENV_ROOT = '/usr/local/anyenv'.freeze

def run(attributes, username = ENV['USER'])
  init(username)

  p :USR
  p ENV['USER']
  p :ANYENV_ROOT
  p ENV['ANYENV_ROOT']

  clone_anyenv
  clone_anyenv_update

  directory "#{@root_path}/envs"

  install_envs(attributes)
end

private

def scheme
  @scheme ||= node[:anyenv][:scheme] || 'git'
end

# def install_envs(attributes)
#   attributes[:install_versions].each do |envs|
#     envs.each do |env, vers|
#       install('anyenv', env)

#       vers.each { |ver| install(env, ver) }

#       global_version(env, vers.first)
#     end
#   end
# end

# def install(from, to)
#   execute anyenv_init_with(@root_path, "yes | #{from} install #{to};")
# end

def init(username)
  @username = username
  @root_path = ENV['ANYENV_ROOT'] || DEFAULT_ANYENV_ROOT
end

def anyenv_init_with(root_path, command)
  <<-"EOS".gsub("\n", ' ')
    export ANYENV_ROOT=#{root_path};
    export PATH=#{root_path}/bin:${PATH};
    eval "$(anyenv init -)";
    #{command}
  EOS
end

# def anyenv_root(username)
#   return anyenv_system_root if username.nil?
#   anyenv_user_root(username)
# end

# def anyenv_system_root
#   if node[:anyenv] && node[:anyenv][:anyenv_root]
#     return node[:anyenv][:anyenv_root]
#   end
#   return ENV['ANYENV_ROOT'] || DEFAULT_ANYENV_ROOT
# end

# def anyenv_user_root(username)
#   if node[:anyenv][:users][username].key?(:anyenv_root)
#     return node[:anyenv][:users][username][:anyenv_root]
#   end
#   case node[:platform]
#   when 'darwin'
#     "/Users/#{username}/.anyenv"
#   else
#     "/home/#{username}/.anyenv"
#   end
# end

# def anyenv_init(root_path)
#   <<-"EOS".gsub("\n", ' ')
# export ANYENV_ROOT=#{root_path};
# export PATH=#{root_path}/bin:${PATH};
# eval "$(anyenv init -)";
#   EOS
# end

def clone_repository(install_path, repo_path)
  git install_path do
    user @username if @username
    repository repo_path if repo_path
    not_if "test -d #{install_path}"
  end
end

def clone_anyenv
  repo_path = "#{scheme}://github.com/riywo/anyenv.git"
  clone_repository(@root_path, repo_path)
end

def clone_anyenv_update
  install_path = "#{@root_path}/plugins/anyenv-update"
  repo_path = "#{scheme}://github.com/znz/anyenv-update.git"
  clone_repository(install_path, repo_path)
end

def install_envs(attributes)
  attributes[:install_versions].each do |envs|
    envs.each do |env, vers|
      install_env(env)

      vers.each do |ver|
        install_env_version(env, ver)
      end

      global_version(env, vers.first)
    end
  end
end

def install_env(envname)
  exec = anyenv_init_with @root_path, <<-EOS
    "yes | anyenv install #{envname}"
  EOS
  is_exec = anyenv_init_with @root_path, "type #{envname}"

  execute "install #{envname}" do
    user @username if @username
    command exec
    not_if is_exec
  end
end

def install_env_version(envname, version)
  exec = anyenv_init_with @root_path, <<-EOS
    "yes | #{envname} install #{version}"
  EOS
  is_exec = anyenv_init_with @root_path, "#{envname} versions | grep #{version}"

  execute "#{envname} install #{version}" do
    user @username if @username
    command exec
    not_if is_exec
  end
end

def global_version(envname, version)
  exec = anyenv_init_with @root_path, <<-EOS
    #{envname} global;
    #{version}; #{envname} rehash;
  EOS
  is_exec = anyenv_init_with @root_path, "#{envname} global | grep #{version}"

  execute "#{envname} global #{version}" do
    user @username if @username
    command exec
    not_if is_exec
  end
  # execute "#{envname} global #{version}" do
  #   user @username if @username
  #   command <<-EOS
  #     #{envname} global #{version};
  #     #{envname} rehash;
  #   EOS
  #   not_if "#{envname} global | grep #{version}"
  # end
end
