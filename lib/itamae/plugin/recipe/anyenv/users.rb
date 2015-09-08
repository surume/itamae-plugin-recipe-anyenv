require 'itamae/plugin/recipe/anyenv'

package "git"

node[:anyenv][:users].each do |username, user_attributes|
  attributes = node[:anyenv].merge(user_attributes)
  run(attributes, username)
end
