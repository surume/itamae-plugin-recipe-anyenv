DEFAULT_RBENV_ROOT = '/usr/local/anyenv'.freeze

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

def clone_repository(install_path, repo_path, username)
  git install_path do
    user username if username
    repository repo_path
    not_if "test -d #{install_path}"
  end
end

def clone_anyenv(install_path, username)
  repo_path = "#{@scheme}://github.com/riywo/anyenv.git"
  clone_repository(install_path, repo_path, username)
end

def clone_anyenv_update(anyenv_root_path, username)
  install_path = "#{anyenv_root_path}/plugins/anyenv-update"
  repo_path = "#{@scheme}://github.com/znz/anyenv-update.git"
  clone_repository(install_path, repo_path, username)
end

def run(attributes, username = nil)
  root_path = anyenv_root(username)
  init_cmd = anyenv_init(root_path)

  clone_anyenv(root_path, username)
  clone_anyenv_update(root_path, username)

  attributes[:install_versions].keys.each do |env|
    execute "install #{env}" do
      user username if username
      command "#{init_cmd} anyenv install #{env}"
      not_if "#{init_cmd} type #{env}"
    end
  end

  attributes[:install_versions].each do |env, vers|
    vers.each do |ver|
      execute "#{env} install #{ver}" do
        user username if username
        command "#{init_cmd} #{env} install #{ver}"
        not_if "#{init_cmd} #{env} versions | grep #{ver}"
      end
    end
  end

  attributes[:install_versions].each do |env, vers|
    execute "#{env} global #{vers.first}" do
      user username if username
      command "#{init_cmd} #{env} global #{vers.first}; " \
              "#{init_cmd} #{env} rehash"
      not_if "#{init_cmd} #{env} global | grep #{vers.first}"
    end
  end
end
