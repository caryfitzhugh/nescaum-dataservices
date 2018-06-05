run: start-db
	SESSION_SECRET=test bundle exec shotgun config.ru --port 4000 --server thin

swagger:
	rm -f doc/swagger_doc.json
	wget http://localhost:4000/swagger_doc.json -O doc/swagger_doc.json
	swagger-to-md doc/swagger_doc.json  > doc/swagger.md

start-db:
	docker-compose up postgres-service
	bundle exec rake db:migrate
	bundle exec rake db:install_postgis

vendor:
	bundle install --deployment

deps:
	npm install -g swagger-to-md
	pip install --upgrade --user awsebcli

test: test-db-up
	APP_ENV=test bundle exec rake test

test-db-up:
	docker-compose -p nds_test-persist -f docker-compose-test.yml up postgres-service
	APP_ENV=test bundle exec rake db:migrate

test-db-down:
	docker-compose -p nds_test-persist -f docker-compose-test.yml down -v

tunnel:
	ssh -L 5009:geoserver-db.c9se39llh7gh.us-east-1.rds.amazonaws.com:5432 ec2-user@54.173.250.109

.PHONY: run
