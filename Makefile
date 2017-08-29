deps-sam:
	npm install -g aws-sam-local@0.2.0 --tilde

deps-terraform:
	./script/deps-terraform.sh

atom:
	atom .
