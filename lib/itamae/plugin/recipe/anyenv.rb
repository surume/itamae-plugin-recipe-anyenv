DEFAULT_RBENV_ROOT = '/usr/local/anyenv'.freeze

def run(attributes, username = nil)
  init(username)

  clone_anyenv
  clone_anyenv_update

  install_envs(attributes)
end

private

def init(username)
  @username = username
  @anyenv_root_path = anyenv_root(username)
  @init_cmd = anyenv_init(@anyenv_root_path)
end

def scheme
  @scheme ||= node[:anyenv][:scheme] || 'git'
end

def anyenv_root(username)
  return anyenv_system_root if username.nil?
  anyenv_user_root(username)
end

def anyenv_system_root
  if node[:anyenv] && node[:anyenv][:anyenv_root]
    return node[:anyenv][:anyenv_root]
  end
  DEFAULT_RBENV_ROOT
end

def anyenv_user_root(username)
  if node[:anyenv][:users][username].key?(:anyenv_root)
    return node[:anyenv][:users][username][:anyenv_root]
  end
  case node[:platform]
  when 'darwin'
    "/Users/#{username}/.anyenv"
  else
    "/home/#{username}/.anyenv"
  end
end

def anyenv_init(root_path)
  init_str =  %(export ANYENV_ROOT="#{root_path}"; )
  init_str << %(export PATH="#{root_path}/bin:${PATH}"; )
  init_str << %(eval "$(anyenv init -)"; )
end

def clone_repository(install_path, repo_path)
  git install_path do
    user @username if @username
    repository repo_path if repo_path
    not_if "test -d #{install_path}"
  end
end

def clone_anyenv
  repo_path = "#{scheme}://github.com/riywo/anyenv.git"
  clone_repository(@anyenv_root_path, repo_path)
end

def clone_anyenv_update
  install_path = "#{@anyenv_root_path}/plugins/anyenv-update"
  repo_path = "#{scheme}://github.com/znz/anyenv-update.git"
  clone_repository(install_path, repo_path)
end

def install_env(envname)
  execute "install #{envname}" do
    user @username if @username
    command "#{@init_cmd} anyenv install #{envname}"
    not_if "#{@init_cmd} type #{envname}"
  end
end

def install_env_version(envname, version)
  execute "#{envname} install #{version}" do
    user @username if @username
    command "#{@init_cmd} #{envname} install #{version}"
    not_if "#{@init_cmd} #{envname} versions | grep #{version}"
  end
end

def global_version(envname, version)
  execute "#{envname} global #{version}" do
    user @username if @username
    command "#{@init_cmd} #{envname} global #{version}; " \
      "#{@init_cmd} #{envname} rehash"
    not_if "#{@init_cmd} #{envname} global | grep #{version}"
  end
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
