# -*- mode: ruby -*-
# vi: set ft=ruby :

MATTERMOST_VERSION = "5.28.1"

MYSQL_ROOT_PASSWORD = 'mysql_root_password'
MATTERMOST_PASSWORD = 'really_secure_password'

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"

  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 4
  end
  
  config.vm.network "private_network", ip: "192.168.1.100"

  config.vm.provision "docker" do |d|
    d.run 'ldap',
      image: 'rroemhild/test-openldap',
      args: "-p 389:389"
    d.run 'ldapadmin',
      image: 'osixia/phpldapadmin:0.9.0',
      args: '-p 6443:6443 \
        --env PHPLDAPADMIN_LDAP_HOSTS=127.0.0.1:6443'
    d.run 'mariadb', 
      args: "-p 3306:3306\
             -e MYSQL_ROOT_PASSWORD=#{MYSQL_ROOT_PASSWORD}\
             -e MYSQL_USER=mmuser\
             -e MYSQL_PASSWORD=#{MATTERMOST_PASSWORD}\
             -e MYSQL_DATABASE=mattermost"
    d.run 'saml',
      image: 'jboss/keycloak',
      args: "-v /vagrant/realm.json:/setup/realm.json\
             -p 8080:8080\
             -e KEYCLOAK_USER=admin\
             -e KEYCLOAK_PASSWORD=secret\
             -e PROXY_ADDRESS_FORWARDING=true\
             -e KEYCLOAK_IMPORT=/setup/realm.json"
  end
 
  config.vm.provision 'shell',
    path: "setup.sh",
    args: [MATTERMOST_VERSION, MYSQL_ROOT_PASSWORD, MATTERMOST_PASSWORD]
end
