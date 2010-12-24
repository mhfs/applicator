Steps
-----

1. Install REE

    wget http://rubyforge.org/frs/download.php/71100/ruby-enterprise_1.8.7-2010.02_i386_ubuntu10.04.deb

    dpkg -i ruby-enterprise_1.8.7-2010.02_i386_ubuntu10.04.deb

2. Take care of gems

    gem uninstall -aIx rails rake rack pg passenger mysql fastthread activesupport activeresource activerecord actionpack actionmailer sqlite3-ruby

    gem install thor

