# necscaum-dataservices
Data services for Nescaum / regional data services.

## Spec
The API spec is at [swagger.md](./doc/swagger.md)

## Dev Notes


Don't know why, but since EBS runs everything as root, this worked for me:
on eb, switch to root.
```
sudo su
cd /var/app/current
bundle exec irb

>> require './nds_app'
```

Then you should have the full access to the app.

## Dev server
```
bundle install
bundle exec rackup
```
