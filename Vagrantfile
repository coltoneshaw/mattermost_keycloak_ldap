# -*- mode: ruby -*-
# vi: set ft=ruby :

MATTERMOST_VERSION = '5.32.1'
DATABASE_USER_PASS = 'really_secure_password'
DATABASE_ROOT_PASS = 'Password42!'
DATABASE_USER='mmuser'
DATABASE_NAME='mattermost'



# options are local / domain
# this replaces all instances of 127.0.0.1 with the domain or your ip address.
INSTALL_TYPE='local'

# if using the local install use your machine address here.
LOCAL_HOST_ADDRESS='127.0.0.1'


Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"

  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 4
  end
  


  config.vm.provision "docker" do |d|
    d.run 'ldap',
      image: 'rroemhild/test-openldap',
      args: "-p 10389:10389\
             -p 10636:10636"
    # d.run 'ldapadmin',
    #   image: 'osixia/phpldapadmin',
    #   args: '-p 6443:6443 \
    #           --env PHPLDAPADMIN_LDAP_HOSTS=127.0.0.1:6443'
    d.run 'postgres', 
      args: "--name=postgres_Server \
              -p 5432:5432\
              -e POSTGRES_PASSWORD=#{DATABASE_ROOT_PASS} \
              -e POSTGRES_USER=mmuser \
              -e POSTGRES_PASSWORD=#{DATABASE_USER_PASS} \
              -e POSTGRES_DB=mattermost \
              -v /opt/postgres/data:/var/lib/postgresql/data \
              -h '*' \
              -d postgres"
  end

  config.vm.network "forwarded_port", guest: 8065, host: 8065
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 5432, host: 15432
 
  ## if using the domain install uncomment the below line.
  #config.vm.network "private_network", ip: "192.168.1.100"


  config.vm.provision 'shell',
    path: "setup.sh",
    args: [MATTERMOST_VERSION, DATABASE_USER_PASS,INSTALL_TYPE, LOCAL_HOST_ADDRESS]

    config.vm.provision "docker" do |saml|
      saml.run 'saml',
        image: 'jboss/keycloak',
        args: "-v /vagrant/realm.json:/setup/realm.json\
               -p 8080:8080\
               -e KEYCLOAK_USER=admin\
               -e KEYCLOAK_PASSWORD=secret\
               -e PROXY_ADDRESS_FORWARDING=true\
               -e KEYCLOAK_IMPORT=/setup/realm.json"
    end
end


