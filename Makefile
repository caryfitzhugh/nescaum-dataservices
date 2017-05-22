run:
	bundle exec shotgun config.ru --port 3000 --server thin

swagger:
	rm -f doc/swagger_doc.json
	wget http://localhost:3000/swagger_doc.json -O doc/swagger_doc.json

.PHONY: run
