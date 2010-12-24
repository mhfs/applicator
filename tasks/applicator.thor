module Applicator
  module Actions
    def check_user(name)
      current_user = run "whoami", :capture => true, :verbose => false
      unless current_user.chomp == "root"
        raise Thor::Error, "ERROR: you should run applicator tasks as root. Use su or sudo."
      end
      say_status :check_user, "ensured root"
    end

    def package(name)
      run "apt-get install -y -qq #{name}"
      say_status :package, "#{name} installed"
    end

    def startup(name)
      run "update-rc.d #{name} defaults", :verbose => false
      say_status :startup, "#{name} now loads on boot"
    end
  end

  class UpdateSystem < Thor::Group
    include Thor::Actions
    include Applicator::Actions

    desc "update the system packages"

    def environment_check
      check_user :root
    end

    def upgrade
      run "apt-get update"
      run "apt-get upgrade -y -qq"
    end

    # we'll need this to build gem native extensations
    def install_build_stuff
      package :'build-essential'
    end
  end

  class Mysql < Thor::Group
    include Thor::Actions
    include Applicator::Actions

    desc "Installs mysql"

    def environment_check
      check_user :root
    end

    def setup
      package :'mysql-server'
      startup :mysql
    end
  end

  class Nginx < Thor::Group
    include Thor::Actions
    include Applicator::Actions

    desc "Installs nginx with basic settings"

    def environment_check
      check_user :root
    end

    def setup
      package :nginx
      startup :nginx
    end
  end

  class Git < Thor::Group
    include Thor::Actions
    include Applicator::Actions

    desc "Installs git"

    def environment_check
      check_user :root
    end

    def setup
      package :'git-core'
    end
  end

  class User < Thor::Group
    include Thor::Actions
    include Applicator::Actions

    desc "creates and set up a sudo capable user"
    argument :username

    def environment_check
      check_user :root
    end

    def create_user
      run "adduser --disabled-password --gecos ',,,' #{username}"
    end

    def add_to_sudoers
      run "usermod -aG sudo mhfs"
    end

    def set_authorized_keys
      public_key = ask "Paste your public key:"
      create_file "/home/#{username}/.ssh/authorized_keys", public_key
      create_file "/etc/deploy_keys", "" unless File.exist?("/etc/deploy_keys")
      append_to_file "/etc/deploy_keys", public_key
    end
  end

  class Jekyll < Thor::Group
    include Thor::Actions
    # TODO move into superclass inherited by all applicator groups
    include Applicator::Actions

    desc "sets a jekyll site in nginx"
    argument :domain

    # TODO move into superclass inherited by all applicator groups
    def self.source_root
      File.dirname(__FILE__) + "/../templates"
    end

    def create_user
      run "adduser --disabled-password --gecos ',,,' --home /home/#{domain} #{username}"
      create_link "/home/#{domain}/.ssh/authorized_keys", "/etc/deploy_keys"
    end

    def install_software
      package :'python-setuptools'
      run "gem install --no-rdoc --no-ri jekyll RedCloth"
      run "easy_install Pygments"
    end

    def create_nginx_config
      template "nginx_jekyll.tt", "/etc/nginx/sites-available/#{domain}"
      link_file "/etc/nginx/sites-available/#{domain}", "/etc/nginx/sites-enabled/#{domain}", :symbolic => true
    end

    def reload_nginx
      run "/etc/init.d/nginx reload"
    end

    private

      def username
        domain.gsub ".", "_"
      end
  end
end

