SHELL := /bin/bash

COLOR_RESET=\033[0m
COLOR_CYAN=\033[1;36m
COLOR_GREEN=\033[1;32m
COLOR_RED=\033[1;31m

src = erdgen
tst = tests

install: create-venv upgrade-pip install-dependencies install-pre-commit post-install

create-venv:
	@echo -e "$(COLOR_CYAN)Creating virtual environment...$(COLOR_RESET)" && \
	python -m venv env

rm-venv:
	@echo -e "$(COLOR_CYAN)Removing virtual environment$(COLOR_RESET)" && \
	rm -rf env

deactivate-venv:
	@echo -e "$(COLOR_CYAN)Deactivating virtual environment$(COLOR_RESET)" && \
	source deactivate

upgrade-pip:
	@echo -e "$(COLOR_CYAN)Upgrading pip...$(COLOR_RESET)" && \
	source env/bin/activate && \
	pip install --upgrade pip >> /dev/null

install-dependencies:
	@echo -e "$(COLOR_CYAN)Installing dependencies...$(COLOR_RESET)" && \
	source env/bin/activate && \
	pip install -r requirements.txt

install-pre-commit:
	@echo -e "$(COLOR_CYAN)Installing pre-commit hooks...$(COLOR_RESET)" && \
	source env/bin/activate && \
	pre-commit install

post-install:
	@echo -e "$(COLOR_GREEN)Install complete.$(COLOR_RESET)"
	@echo -e "$(COLOR_RED)YOU MUST ACTIVATE YOUR VIRTUAL ENVIRONMENT, RUN A: \"source env/bin/activate\"$(COLOR_RESET)"

freeze:
	source env/bin/activate && \
	pip freeze > requirements.txt

format:
	isort $(src) $(tst)
	black $(src) $(tst)

lint:
	pylint $(src) $(tst)

typecheck:
	mypy $(src) $(tst)

pre-commit:
	pre-commit run --all-files

clean: clean-build clean-pyc clean-test clean-mypy

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

clean-mypy:
	rm -fr .mypy_cache/

clean-test:
	rm -fr .pytest_cache

test:
	pytest $(tst)

version-patch:
	bump2version patch

version-minor:
	bump2version patch

version-major:
	bump2version patch

release: typecheck dist
	twine upload dist/*

dist: clean
	python setup.py sdist
	ls -l dist
