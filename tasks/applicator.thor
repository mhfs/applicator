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
  end

  class MySql < Thor::Group
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

  class MainUser < Thor::Group
    include Thor::Actions
    include Applicator::Actions

    desc "creates and set up my basic user"

    def environment_check
      check_user :root
    end

    def create_user
      run 'adduser --disabled-password --gecos "Marcelo Silveira,,," mhfs'
    end

    def add_to_sudoers
      run "usermod -aG sudo mhfs"
    end

    def set_authorized_keys
      public_key = ask "Paste your public key"
      create_file "/home/mhfs/.ssh/authorized_keys", public_key
    end
  end
end

