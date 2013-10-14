has_sauce = $(SAUCE_USERNAME)
ifndef $(has_sauce)
	test-env = test-local
else
	test-env = test-sauce
endif



build: less
	@:

less_files := strider.less config.less build.less dashboard.less projects.less
css_files := $(patsubst %.less,public/stylesheets/css/%.css,$(less_files))

less: $(css_files)

public/stylesheets/css/%.css: public/stylesheets/less/%.less
	./node_modules/.bin/lessc $< > $@

watch:
	watch make

serve:
	@./bin/strider


test: test-smoke test-unit test-browser test-style

test-smoke:
	# TODO


test-unit:
	@./node_modules/.bin/mocha -R tap test/test_middleware.js
	@./node_modules/.bin/mocha -R tap test/test_ansi.js
	@./node_modules/.bin/mocha -R tap test/test_api.js
	@./node_modules/.bin/mocha -R tap test/functional/test.js

test-browser: $(test-env)
	# Either test-local or test-sauce

test-style: lint

test-sauce-pre:
ifndef SAUCE_USERNAME
	$(error You need env: SAUCE_USERNAME)
endif
ifndef SAUCE_ACCESS_KEY
	$(error You need env: SAUCE_ACCESS_KEY)
endif
	# Sauce Connect: https://saucelabs.com/docs/connect
	# USER: $(SAUCE_USERNAME)
	# KEY:  $(SAUCE_ACCESS_KEY)

test-sauce: test-sauce-pre test-integration-sauce test-client-sauce

test-local:
	mocha test/client/

test-integration-sauce:
	./node_modules/mocha-selenium/bin/mocha-selenium.js -c test/selenium.json -p -e sauce test/integration/*_test.js

test-client-sauce:
	./node_modules/mocha-selenium/bin/mocha-selenium.js -c test/selenium.json -p -e sauce test/client/dashboard.js test/client/projects.js


tolint := *.js *.json lib routes public/javascripts/pages public/javascripts/modules

lint:
	@./node_modules/.bin/jshint --verbose $(tolint)

strider_sub := strider-env strider-simple-worker strider-python strider-sauce strider-custom

link:
	npm link $(strider_sub)

unlink:
	npm install $(strider_sub)

.PHONY: test lint watch build less
