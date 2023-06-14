src = erdgen
tst = tests

format:
	isort $(src) $(tst)
	black $(src) $(tst)

lint:
	pylint $(src) $(tst)

typecheck:
	mypy $(src) $(tst)

clean: clean-build clean-pyc clean-test

clean-build:
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test:
	rm -fr .pytest_cache

test:
	pytest $(tst)

release: dist
	twine upload dist/*

dist: clean
	python setup.py sdist
	ls -l dist
