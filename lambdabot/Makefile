clean:
	rm -rf node_modules

install:
	yarn install

package:
	script/package.sh

sam-invoke:
	sam validate
	sam local invoke lambdabot -e fixtures/get-slash-request.json
