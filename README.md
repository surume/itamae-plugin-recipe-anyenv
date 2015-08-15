# Itamae::Plugin::Recipe::Anyenv

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/itamae/plugin/recipe/anyenv`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'itamae-plugin-recipe-anyenv'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install itamae-plugin-recipe-anyenv

## Usage

System wide anyenv installation

### Recipe

```ruby
# your recipe
include_recipe "anyenv::system"
```

### Node

Use this with `itamae -y node.yml`

```yml
anyenv:
  anyenv_root: "/path/to/anyenv"
  install_envs:
    - rbenv
    - exenv
  install_versions:
    - rbenv:
      - 2.2.2
    - exenv:
      - 1.0.5
```

### .bashrc

Recommend to append this to .bashrc in your server.

```bash
export ANYENV_ROOT="/usr/local/anyenv"
export PATH="${ANYENV_ROOT}/.anyenv/bin:$PATH"
if which anyenv > /dev/null; then eval "$(anyenv init -)"; fi
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

