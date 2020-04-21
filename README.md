# README - empfin-request automation

[![Build Status](https://travis-ci.org/kingdonb/empfin-request.svg?branch=master)](https://travis-ci.org/kingdonb/empfin-request)
[![codecov](https://codecov.io/gh/kingdonb/empfin-request/branch/master/graph/badge.svg)](https://codecov.io/gh/kingdonb/empfin-request)

* Ruby version - 

```
RUBY VERSION
   ruby 2.6.6p146

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
    One file is written as output, and its opening state is considered as part
    of the decision making matrix in test:system rails task, which provides a
    runtime environment for the EmpfinRequestForm::Main class to run in.  (The
    test:system task will attempt to skip processing for any rows that were
    already processed, through this mechanism.)
```

#### One File (output)
  - one file is expected to at least exist with no content, and it is written
      line-at-a-time, with a manifest of all tickets parsed from the input, and
      their keys, as well as a URL where they can be found. A full compliment
      of Request, Request Item, and Task Numbers are stored when a row finishes

```
original_key,on_behalf_of_department,original_id,business_application,req_id,ritm_id,task_id,req_url,ritm_url,task_url
CC: Finance -  #1512 ARP,Finance,1512,ARP,REQ0046506,RITM0047866,TASK0063186,https://ndtest.service-now.com/sc_request.do?sys_id=9d80e9a[...]%5EORDERBYDESCnumber
CC: Finance -  #1510 ARP,Finance,1510,ARP,REQ0046507,RITM0047867,TASK0063187,https://ndtest.service-now.com/sc_request.do?sys_id=4ca0a5e[...]%5EORDERBYDESCnumber
CC: Human Resources -  #1450 Workterra,Human Resources,1450,Workterra,REQ0046508,RITM0047868,TASK0063188,https://ndtest.service-now.com/sc_request.do?sys_id=dcb069e[...]%5EORDERBYDESCnumber
```

  - output file is constructed iteratively, as the test:system execution creates or updates tickets through visiting ServiceNow pages, scanning them and POSTing to them, the system test records the REQ,RITM,TASK as they are generated too, along with some status details gathered by visiting them, if those keys were already recorded once before.
  - In successive iteration, these files will be used to filter and skip records that were already processed. Any row with a "REQ" id recorded has been saved, and rows with RITM and TASK ids recorded are finished with their entry.

* How to run the robotic process

```
    bundle exec rails test:system
```

* with ENV and Configuration set as above, *WILL*
    result in new Requests being posted into ServiceNow, *in production*.

* Services (job queues, cache servers, search engines, etc.)
    The rake task depends on a live internet connection and the ServiceNow
    instance running at https://sn.nd.edu

Visit the source code at `app/models/concerns/empfin_request_form/constants.rb` and change that file to set `production` mode:

```
module EmpfinRequestForm::Constants
  #EMPFIN_REQUEST_URL = 'https://nd.service-now.com/com.glideapp.servicecatalog_cat_item_view.do?v=1&sysparm_id=9f4426e6db403200de73f5161d96198d'
  EMPFIN_REQUEST_URL = 'https://ndtest.service-now.com/com.glideapp.servicecatalog_cat_item_view.do?v=1&sysparm_id=9f4426e6db403200de73f5161d96198d'
```

Just comment/uncomment the part of the file that is labeled as testing/production.

Also, please run the tests after making any changes:

```
$ bundle exec rspec
```

