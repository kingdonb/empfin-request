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

### Database initialization

```
    Two files are created as output, although their opening state may be
    considered as part of the runtime decision making matrix in test:system
    rake task. (The test:system task will attempt to skip processing for any
    rows that were already processed, through this mechanism.)
```

#### Two Files (output)
  - one file is constructed at-once, with a manifest of all tickets parsed from the input, and their keys
      eg. output-cc-file.csv

```
Finance,1512,ARP
Finance,1510,ARP
Human Resources,1450,Workterra
Human Resources,1225,HR I-9 Notify
Human Resources,1224,HR I-9 Notify
```

  - one file is constructed iteratively, as the test:system execution creates or updates tickets through visiting ServiceNow pages, scanning them and POSTing to them, the system test records the REQ,RITM,TASK as they are generated too, along with some status details gathered by visiting them, if those keys were already recorded once before.
  - (In successive iteration, these files will be used to filter and skip records that were already processed.)

* How to run the test suite

```
    bundle exec rails test:system
```

* with ENV and Configuration set as above, *WILL*
    result in new Requests being posted into ServiceNow, *in production*.

* Services (job queues, cache servers, search engines, etc.)
    The rake task depends on a live internet connection and the ServiceNow
    instance running at https://sn.nd.edu

There are two places where "app_host" is set, in the source code at `test/test_helper.rb`:
#  Capybara.app_host = 'https://sn.nd.edu'
  Capybara.app_host = 'https://ndtest.service-now.com'

and in the source code again at `app/models/concerns/empfin_request_form/constants.rb`:

```
module EmpfinRequestForm::Constants
  #EMPFIN_REQUEST_URL = 'https://nd.service-now.com/com.glideapp.servicecatalog_cat_item_view.do?v=1&sysparm_id=9f4426e6db403200de73f5161d96198d'
  EMPFIN_REQUEST_URL = 'https://ndtest.service-now.com/com.glideapp.servicecatalog_cat_item_view.do?v=1&sysparm_id=9f4426e6db403200de73f5161d96198d'
```


* Deployment instructions

```
    The rake task is the totality of the program, and there is not any
    deployment needed as this is a one-time operation.
```

* ...
