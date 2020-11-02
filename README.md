# Mattermost w/ OpenLDAP and Keycloak SAML

## Problem

You need to test login for SAML guest users against a custom build

## Solution

This Vagrant machine will spin up a few things in addition to Mattermost:

 - haproxy, a reverse proxy which handles routing traffic (Docker)
 - mysql for a database (Docker)
 - OpenLDAP, in the form of the great `rroemhild/test-openldap` test server (Docker)
 - phpLDAPAdmin (not working) (Docker)
 - Keycloak for SAML (Docker)

The realm, users, and Mattermost are all configured. To access it, edit your hosts file to add these entries, then run `vagrant up` to start the machine.

```
192.168.1.100 mattermost.planex.com, saml.planex.com, ldapadmin.planex.com, stats.planex.com
```

The admin credentials for Mattermost are: `admin`/`admin`. When you first log in be sure to set the team to `Anyone can join`.

Once it's up you can log in via Keycloak with the following email/password combinations

 - `user`/`password`
 - `admin`/`secret`

You can also log in with LDAP using any of the users from [here](https://github.com/rroemhild/docker-test-openldap), e.g.

 - `professor`/`professor` (System Admin)
 - `fry`/`fry`
 - `zoidberg`/`zoidberg`

 They're also available for LDAP group sync

## To Do

 - [ ] Get phpLDAPAdmin working
 - [ ] Connect Keycloak to OpenLDAP
 - [ ] Auto-generate some guest SAML users
 - [ ] Use `mmctl` to generate the team
 - [ ] Upgrade everything to TLS with auto-generated certs. (See `create_cert.sh` for a preview)