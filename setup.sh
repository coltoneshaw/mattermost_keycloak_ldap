#!/bin/bash

mattermost_version=$1
DATABASE_USER_PASS=$2
INSTALL_TYPE=$3
LOCAL_HOST_ADDRESS=$4
DATABASE_USER=mmuser
DATABASE_NAME=mattermost


apt-get -qq -y update
apt-get install -y -q ldapscripts jq haproxy xmlsec1 postgresql-client -y

# Install haproxy
mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.orig.cfg
cp /vagrant/haproxy.cfg /etc/haproxy/haproxy.cfg
service haproxy restart

rm -rf /opt/mattermost

## adding local links

if [ "$INSTALL_TYPE" = "local" ] && [ "$LOCAL_HOST_ADDRESS" != "127.0.0.1" ]
        then
                ## changing references to the mattermost app
                grep -rl "127.0.0.1:8065" /vagrant/config.json | xargs sed -i "s/127.0.0.1:8065/$LOCAL_HOST_ADDRESS:8065/g" /vagrant/config.json

                ##changing SAML settings
                grep -rl "127.0.0.1:8080" /vagrant/config.json | xargs sed -i "s/127.0.0.1:8080/$LOCAL_HOST_ADDRESS:8080/g" /vagrant/config.json
                grep -rl "127.0.0.1:8065" /vagrant/realm.json | xargs sed -i "s/127.0.0.1:8065/$LOCAL_HOST_ADDRESS:8065/g" /vagrant/config.json

elif [ "$INSTALL_TYPE" = "local" ] && [ "$LOCAL_HOST_ADDRESS" = "127.0.0.1" ]
	then
	break
else

        ## this should not touch the LDAP line in the config.
        grep -rl "127.0.0.1:8065" /vagrant/config.json | xargs sed -i "s/127.0.0.1:8065/mattermost.planex.com/g" /vagrant/config.json

        ##changing SAML settings
        grep -rl "127.0.0.1:8080" /vagrant/config.json | xargs sed -i "s/127.0.0.1:8080/saml.planex.com/g" /vagrant/config.json

        ## replacing the redirect URL
        grep -rl "127.0.0.1:8065" /vagrant/realm.json | xargs sed -i "s/127.0.0.1:8065/mattermost.planex.com/g" /vagrant/config.json
        
		## could not get this to target the right location yet. leaving as allow all.
		#sed -i 's/"redirectUris": ["*"],/"redirectUris": ["http://mattermost.planex.com/login/sso/saml"],' /vagrant/realm.json

fi


echo "127.0.0.1 mattermost.planex.com" >> /etc/hosts
echo "127.0.0.1 saml.planex.com" >> /etc/hosts
echo "127.0.0.1 ldap.planex.com" >> /etc/hosts

archive_filename="mattermost-$mattermost_version-linux-amd64.tar.gz"
archive_path="/vagrant/mattermost_archives/$archive_filename"
archive_url="https://releases.mattermost.com/$mattermost_version/$archive_filename"

if [[ ! -f $archive_path ]]; then
	wget --quiet $archive_url -O $archive_path
fi

if [[ ! -f $archive_path ]]; then
	echo "Could not find archive file, aborting"
	echo "Path: $archive_path"
	exit 1
fi

cp $archive_path ./

tar -xzf mattermost*.gz

rm mattermost*.gz
mv mattermost /opt

mkdir /opt/mattermost/data

mv /opt/mattermost/config/config.json /opt/mattermost/config/config.orig.json
cp /vagrant/samlcert.crt /opt/mattermost/samlcert.crt
cat /vagrant/config.json | sed "s/MATTERMOST_PASSWORD/$DATABASE_USER_PASS/g" > /tmp/config.json
jq -s '.[0] * .[1]' /opt/mattermost/config/config.orig.json /tmp/config.json > /opt/mattermost/config/config.json
rm /tmp/config.json


useradd --system --user-group mattermost
chown -R mattermost:mattermost /opt/mattermost
chmod -R g+w /opt/mattermost

cp /vagrant/mattermost.service /lib/systemd/system/mattermost.service
systemctl daemon-reload

cd /opt/mattermost
if [[ -f /vagrant/e20license.txt ]]; then
	echo "Installing E20 License"
	bin/mattermost license upload /vagrant/e20license.txt
fi
bin/mattermost user create --email admin@planetexpress.com --username admin --password admin --system_admin
bin/mattermost team create --name planet-express --display_name "Planet Express" --email "professor@planetexpress.com"
bin/mattermost team add planet-express admin@planetexpress.com


## fixing permission problem
chown -R mattermost:mattermost /opt/mattermost


systemctl start mattermost

echo "update Teams set allowopeninvite='t' where name='planet-express';" | psql "host=127.0.0.1 port=5432 dbname=$DATABASE_NAME user=$DATABASE_USER password=$DATABASE_USER_PASS"

printf '=%.0s' {1..80}
echo 
echo '                     VAGRANT UP!'
echo "GO TO http://$LOCAL_HOST_ADDRESS:8065 and log in with \`professor\`"
echo
printf '=%.0s' {1..80}
