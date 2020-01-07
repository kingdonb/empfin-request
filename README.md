# README - empfin-request automation

* Ruby version - 

```
RUBY VERSION
   ruby 2.6.5p114

BUNDLED WITH
   1.17.3
```

* System dependencies

```
    Opens a web browser and depends on a human user who can 2-factor authenticate
    ENV: USERNAME_PASSWORD_BASE64
    expected to contain the output of `echo 'username:password' |base64`
eg: dXNlcm5hbWU6cGFzc3dvcmQK
```

* Configuration

```
    The test:system rake task is configured to read from a file
    (new-cc-file.csv)
    which contains CSV data, which may include newlines. It is parsed into
    array of hashes using the smarter_csv gem.
```

* Database creation

```
    There is no database
```

* Database initialization

```
    Two files are created as output, although their opening state may be
    considered as part of the runtime decision making matrix in test:system
    rake task. (The test:system task will attempt to skip processing for any
    rows that were already processed, through this mechanism.)
```

* How to run the test suite

```
    bundle exec rails test:system
```

    * with ENV and Configuration set as above, WILL
    result in new Requests being posted into ServiceNow, in production.

* Services (job queues, cache servers, search engines, etc.)
    The rake task depends on a live internet connection and the ServiceNow
    instance running at https://sn.nd.edu

* Deployment instructions

```
    The rake task is the totality of the program, and there is not any
    deployment needed as this is a one-time operation.
```

* ...
