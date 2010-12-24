module Applicator
  module Actions
    def check_user(name)
      current_user = run "whoami", :capture => true, :verbose => false
      unless current_user.chomp == "mhfs"
        raise Thor::Error, "ERROR: you should run applicator tasks as root. Use su or sudo."
      end
      say_status :check_user, "ensured root"
    end

    def package(name)
      run "apt-get install -y -qq #{name}", :verbose => false
      say_status :package, "installed #{name}"
    end

    def startup(name)
      run "update-rc.d #{name} defaults", :verbose => false
      say_status :startup, "#{name} now loads on boot"
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
end

