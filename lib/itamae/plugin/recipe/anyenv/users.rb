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

def anyenv_user_init(username)
  init_str =  %[export ANYENV_ROOT="#{anyenv_user_root(username)}"; ]
  init_str << %[export PATH="#{anyenv_user_root(username)}/bin:${PATH}"; ]
  init_str << %[eval "$(anyenv init -)"; ]
  init_str
end

package "git"

scheme = node[:anyenv][:scheme] || "git"

node[:anyenv][:users].each do |username, user_attributes|
  attributes = node[:anyenv].merge(user_attributes)
  anyenv_root = anyenv_user_root(username)
  anyenv_init = anyenv_user_init(username)

  git anyenv_root do
    user username
    repository "#{scheme}://github.com/riywo/anyenv.git"
  end

  git "#{anyenv_root}/plugins/anyenv-update" do
    user username
    repository "#{scheme}://github.com/znz/anyenv-update.git"
  end

  attributes[:install_envs].each do |env|
    execute "install #{env}" do
      user username
      command "#{anyenv_init} anyenv install #{env}"
      not_if "#{anyenv_init} type #{env}"
    end
  end

  attributes[:install_versions].each do |envs|
    envs.each do |name, vers|
      vers.each do |ver|
        execute "#{name} install #{ver}" do
          user username
          command "#{anyenv_init} #{name} install #{ver}"
          not_if "#{anyenv_init} #{name} versions | grep #{ver}"
        end
      end
    end
  end

  attributes[:install_versions].each do |envs|
    envs.each do |name, vers|
      execute "#{name} global #{vers.first}" do
        user username
        command "#{anyenv_init} #{name} global #{vers.first}; " \
                "#{anyenv_init} #{name} rehash"
        not_if "#{anyenv_init} #{name} global | grep #{vers.first}"
      end
    end
  end
end
