run:
	bundle exec shotgun config.ru --port 3000 --server thin

swagger:
	rm -f doc/swagger_doc.json
	wget http://localhost:3000/swagger_doc.json -O doc/swagger_doc.json
	swagger-to-md doc/swagger_doc.json  > doc/swagger.md

start-db:
	docker-compose up postgres-service

vendor:
	bundle install --deployment

deps:
	npm install -g swagger-to-md
	pip install --upgrade --user awsebcli

test: test-db-up
	bundle exec rake test

test-db-up:
	docker-compose -p nds_test-persist -f docker-compose-test.yml up postgres-service

test-db-down:
	docker-compose -p nds_test-persist -f docker-compose-test.yml down -v

.PHONY: run
