DEFAULT_RBENV_ROOT = "/usr/local/anyenv".freeze

def scheme
  scheme ||= node[:anyenv][:scheme] || "git"
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
  when "darwin"
    "/Users/#{username}/.anyenv"
  else
    "/home/#{username}/.anyenv"
  end
end

def anyenv_init(root_path)
  init_str =  %[export ANYENV_ROOT="#{root_path}"; ]
  init_str << %[export PATH="#{root_path}/bin:${PATH}"; ]
  init_str << %[eval "$(anyenv init -)"; ]
  init_str
end

def run(attributes, username = nil)
  root_path = anyenv_root(username)
  init_cmd = anyenv_init(root_path)

  git root_path do
    user username if username
    repository "#{scheme}://github.com/riywo/anyenv.git"
  end

  git "#{root_path}/plugins/anyenv-update" do
    user username
    repository "#{scheme}://github.com/znz/anyenv-update.git"
  end

  attributes[:install_envs].each do |env|
    execute "install #{env}" do
      user username if username
      command "#{init_cmd} anyenv install #{env}"
      not_if "#{init_cmd} type #{env}"
    end
  end

  attributes[:install_versions].each do |envs|
    envs.each do |name, vers|
      vers.each do |ver|
        execute "#{name} install #{ver}" do
          user username if username
          command "#{init_cmd} #{name} install #{ver}"
          not_if "#{init_cmd} #{name} versions | grep #{ver}"
        end
      end
    end
  end

  attributes[:install_versions].each do |envs|
    envs.each do |name, vers|
      execute "#{name} global #{vers.first}" do
        user username if username
        command "#{init_cmd} #{name} global #{vers.first}; " \
                "#{init_cmd} #{name} rehash"
        not_if "#{init_cmd} #{name} global | grep #{vers.first}"
      end
    end
  end
end
