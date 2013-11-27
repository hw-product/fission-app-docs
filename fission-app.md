# Fission (front end)

**Repository:** [https://github.com/heavywater/fission-app][fission-app]

## Overview

The Fission app (a rails app) manages user registration, authentication/permissions, etc. 

The fission-app is using [Squeel][squeel].

## Permissions

The Fission app employs a basic CRUD model for user authentication, and follows a tree-structure permission model. An `identity` authenticates a `user` who is a member of an `account` (or multiple accounts), and access permissions are scoped to accounts.

## Notes

* following tree-structure permission model 
* using squeel (https://github.com/ernie/squeel) 

## Setup

* Install ruby and rails

    ``` bash
    add-apt-repository ppa:brightbox/ruby-ng
    ```

* Clone repository
* Bundle

    ``` bash
    bundle install
    bundle --binutils
    ```

* Install PostgreSQL (config/database.yml)
* Configure PG
    
    ``` bash
    create user fission with password fission
    alter user fission CREATDB
    create database name fission_app_development
    alter database fission_app_development owner to fission
    grant permissions to database
    ```

* Run rake

    ``` bash
    rake db:migrate
    ```
* Start rails

    ``` bash
    ./bin/rails s
    RAILS_ENV=test ALLOW_NO_AUTH=true ./bin/rails s
    curl http://localhost:3000/users/6 -H "Accept: application/json"
    ```



[fission-app]: https://github.com/heavywater/fission-app
[squeel]: https://github.com/activerecord-hackery/squeel
