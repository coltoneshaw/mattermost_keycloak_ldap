# -*- mode: ruby -*-
# vi: set ft=ruby :

MATTERMOST_VERSION = "guest-ldap-test"

MYSQL_ROOT_PASSWORD = 'mysql_root_password'
MATTERMOST_PASSWORD = 'really_secure_password'

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"

  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 4
  end

  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 8443, host: 8443
  config.vm.network "forwarded_port", guest: 8065, host: 8065
  config.vm.network "forwarded_port", guest: 3306, host: 13306
  config.vm.network "forwarded_port", guest: 389, host: 2389
  config.vm.hostname = 'mattermost'

  config.vm.provision "docker" do |d|
    d.run 'ldap',
      image: 'rroemhild/test-openldap',
      args: "-p 389:389"
    d.run 'mariadb', 
      args: "-p 3306:3306\
             -e MYSQL_ROOT_PASSWORD=#{MYSQL_ROOT_PASSWORD}"
    # d.run 'saml',
    #   image: 'jboss/keycloak',
    #   args: "-v /vagrant/realm.json:/setup/realm.json\
    #          -p 8080:8080\
    #          -e KEYCLOAK_USER=admin\
    #          -e KEYCLOAK_PASSWORD=secret\
    #          -e KEYCLOAK_IMPORT=/setup/realm.json"
  end
 
  config.vm.provision 'shell',
    path: "setup.sh",
    args: [MATTERMOST_VERSION, MYSQL_ROOT_PASSWORD, MATTERMOST_PASSWORD]
end
