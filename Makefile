run:
	bundle exec shotgun config.ru --port 3000 --server thin

swagger:
	rm -f doc/swagger_doc.json
	wget http://localhost:3000/swagger_doc.json -O doc/swagger_doc.json
	swagger-to-md doc/swagger_doc.json  > doc/swagger.md

deps:
	npm install -g swagger-to-md
	pip install --upgrade --user awsebcli

.PHONY: run
