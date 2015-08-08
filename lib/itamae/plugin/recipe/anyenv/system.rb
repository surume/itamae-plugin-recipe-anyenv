package "git"

scheme = "git"
scheme = node[:anyenv][:scheme] if node[:anyenv][:scheme]

require "itame/plugin/recipe/anyenv"

git anyenv_root do
  repository "#{scheme}://github.com/riywo/anyenv.git"
end

directory "#{anyenv_root}/envs"
