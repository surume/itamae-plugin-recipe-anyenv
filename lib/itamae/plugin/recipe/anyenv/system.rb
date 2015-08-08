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
