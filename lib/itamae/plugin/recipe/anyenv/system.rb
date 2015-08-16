package "git"

scheme = "git"
scheme = node[:anyenv][:scheme] if node[:anyenv][:scheme]

require 'itamae/plugin/recipe/anyenv'

git anyenv_root do
  repository "#{scheme}://github.com/riywo/anyenv.git"
end

git "#{anyenv_root}/plugins/anyenv-update" do
  repository "#{scheme}://github.com/znz/anyenv-update.git"
end

directory "#{anyenv_root}/envs"

node[:anyenv][:install_envs].each do |env|
  execute "install #{env}" do
    command "#{anyenv_init} anyenv install #{env}"
    not_if "type #{env}"
  end
end

node[:anyenv][:install_versions].each do |envs|
  envs.each do |name, vers|
    vers.each do |ver|
      execute "#{name} install #{ver}" do
        command "#{name} install #{ver}"
        not_if "#{anyenv_init} #{name} versions | grep #{ver}"
      end
    end
  end
end

node[:anyenv][:install_versions].each do |envs|
  envs.each do |name, vers|
    execute "#{name} global #{vers.first}" do
      command "#{name} global #{vers.first}"
      command "#{name} rehash"
      not_if "#{anyenv_init} #{name} global | grep #{vers.first}"
    end
  end
end
