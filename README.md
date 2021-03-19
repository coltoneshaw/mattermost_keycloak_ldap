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

## Setup steps

1. Modify the variables at the top of the Vagrant file. Specifically the Mattermost Version.
2. Add a file labled `e20license.txt` to the root directory of this install before running `vagrant up`.
3. Create the folder `/mattermost_archives` if this does not already exist in the root.
4. Run `vagrant up`.

## Setup SAML

- If SAML login is not working try to remove the cert under System Console > SAML and re-add it - filename: `samlcert.crt`.

### Create new SAML Users:
1. Log into Keycloak at `https://127.0.0.1:8080`
2. Manage > Users > Add new User
3. fill out the information. Ideally match this to someone from LDAP. This requires an email
4. Save the user.
5. Under users again find the user > Credentials and add a password.
6. Uncheck 'temp password'
7. Save.

You should now be able to log in with this user via SAML.

## To Do

 - [ ] Get phpLDAPAdmin working
 - [ ] Connect Keycloak to OpenLDAP
 - [ ] Auto-generate some guest SAML users
 - [ ] Use `mmctl` to generate the team
 - [ ] Upgrade everything to TLS with auto-generated certs. (See `create_cert.sh` for a preview)