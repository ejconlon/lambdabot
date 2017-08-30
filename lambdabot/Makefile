clean:
	rm -rf node_modules

install:
	yarn install

test:
	echo "Write some tests!"

package:
	script/package.sh

sam-validate:
	sam validate

sam-get:
	sam local invoke lambdabot -e fixtures/get-slash-request.json

sam-test:
	sam local invoke lambdabot -e fixtures/get-test-request.json

sam-post:
	sam local invoke lambdabot -e fixtures/post-hello-request.json

sam-api:
	sam local start-api

test-get:
	curl -v http://localhost:3000

test-post:
	curl -v -d '{"name":"foo"}' -H 'Content-Type: application/json' http://localhost:3000/hello

test-api:
	yarn run main
