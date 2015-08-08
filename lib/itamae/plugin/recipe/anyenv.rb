DEFAULT_RBENV_ROOT = "/usr/local/rbenv".freeze

def anyenv_root
  if node[:anyenv] && node[:anyenv][:anyenv_root]
    return node[:anyenv][:anyenv_root]
  end
  DEFAULT_RBENV_ROOT
end

def anyenv_init
  <<-EOS
    export ANYENV_ROOT=#{anyenv_root}
    export PATH="#{anyenv_root}/bin:${PATH}"
    eval "$(anyenv init -)"
  EOS
end
