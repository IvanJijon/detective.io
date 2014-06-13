# Makefile -- Detective.io

NEO4J_VERSION = 1.9.1

VENV          = venv
ENV           = ./.env

COVERAGE      = `which coverage`

CUSTOM_D3	  = ./app/static/components/custom_d3/d3.js

all: install startdb run

run: clean
	. $(ENV) ; python -W ignore::DeprecationWarning manage.py runserver --nothreading

###
# Installation rules
###

$(VENV) :
	virtualenv venv --no-site-packages --distribute --prompt=Detective.io

pip_install:
	# Install pip packages
	. $(ENV) ; pip install -r requirements.txt

npm_install:
	# Install npm packages
	npm install

$(CUSTOM_D3):
	# Install a custom d3 package
	make -C `dirname $(CUSTOM_D3)`

bower_install:
	# Install bower packages
	./node_modules/.bin/bower install

neo4j_install:
	# Install neo4j locally
	./install_local_neo4j.bash $$NEO4J_VERSION

install: $(VENV) pip_install npm_install $(CUSTOM_D3) bower_install neo4j_install

###
# Clean rules
###

clean:
	rm **/*.pyc -f

fclean: clean
	rm $(CUSTOM_D3)

###
# Neo4j rules
###

stopdb:
	./lib/neo4j/bin/neo4j stop || true

startdb:
	./lib/neo4j/bin/neo4j start || ( cat ./lib/neo4j/data/log/*.log && exit 1 )

###
# Test rules
###

test:
	make stopdb
	rm -Rf ./lib/neo4j/data/graph.db
	rm -f dev.db
	make startdb
	./manage.py syncdb -v 0 --noinput --pythonpath=. --settings=app.settings_tests
	python -W ignore::DeprecationWarning $(COVERAGE) run --source=app.detective ./manage.py test detective --pythonpath=. --settings=app.settings_tests
	coveralls
