DEFAULT_ANYENV_ROOT = '/usr/local/anyenv'.freeze

def run(attributes, username = ENV['USER'])
  init(username)

  clone_anyenv
  clone_anyenv_update

  directory "#{@root_path}/envs"

  install_envs(attributes)
end

private

def scheme
  @scheme ||= node[:anyenv][:scheme] || 'git'
end

def init(username)
  @username = username
  @root_path = ENV['ANYENV_ROOT'] || DEFAULT_ANYENV_ROOT
end

def anyenv_init_with(command)
  <<-"EOS".gsub("\n", ' ')
    export ANYENV_ROOT=#{@root_path};
    export PATH=#{@root_path}/bin:${PATH};
    eval "$(anyenv init -)";
    #{command}
  EOS
end

def clone_repository(install_path, repo_path)
  username = @username
  git install_path do
    user username if username
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
  username = @username
  exec = anyenv_init_with <<-EOS
    yes | anyenv install #{envname}
  EOS
  is_exec = anyenv_init_with "type #{envname}"

  execute "install #{envname}" do
    user username if username
    command exec
    not_if is_exec
  end
end

def install_env_version(envname, version)
  username = @username
  exec = anyenv_init_with <<-EOS
    yes | #{envname} install #{version}
  EOS
  is_exec = anyenv_init_with "#{envname} versions | grep #{version}"

  execute "#{envname} install #{version}" do
    user username if username
    command exec
    not_if is_exec
  end
end

def global_version(envname, version)
  username = @username
  exec = anyenv_init_with <<-EOS
    #{envname} global;
    #{version}; #{envname} rehash;
  EOS
  is_exec = anyenv_init_with "#{envname} versions | grep #{version}"

  execute "#{envname} global #{version}" do
    user username if username
    command exec
    not_if is_exec
  end
end
