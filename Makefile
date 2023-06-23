SHELL := /bin/bash

COLOR_RESET=\033[0m
COLOR_CYAN=\033[1;36m
COLOR_GREEN=\033[1;32m
COLOR_RED=\033[1;31m

src = erdgen
tst = tests
venv = env/bin/activate
pip = $(venv) && pip

.PHONY: install create-venv rm-venv deactivate-venv upgrade-pip install-dependencies install-pre-commit post-install freeze format lint typecheck pre-commit clean clean-build clean-pyc clean-mypy clean-test test version-patch version-minor version-major release dist

install: create-venv upgrade-pip install-dependencies install-pre-commit post-install

create-venv:
	@echo -e "$(COLOR_CYAN)Creating virtual environment...$(COLOR_RESET)"
	python -m venv env

rm-venv:
	@echo -e "$(COLOR_CYAN)Removing virtual environment$(COLOR_RESET)"
	$(RM) -rf env

deactivate-venv:
	@echo -e "$(COLOR_CYAN)Deactivating virtual environment$(COLOR_RESET)"
	source deactivate

upgrade-pip:
	@echo -e "$(COLOR_CYAN)Upgrading pip...$(COLOR_RESET)"
	source $(pip) install --upgrade pip >> /dev/null

install-dependencies:
	@echo -e "$(COLOR_CYAN)Installing dependencies...$(COLOR_RESET)"
	source $(pip) install -r requirements.txt

install-pre-commit:
	@echo -e "$(COLOR_CYAN)Installing pre-commit hooks...$(COLOR_RESET)"
	source $(venv) && pre-commit install

post-install:
	@echo -e "$(COLOR_GREEN)Install complete.$(COLOR_RESET)"
	@echo -e "$(COLOR_RED)YOU MUST ACTIVATE YOUR VIRTUAL ENVIRONMENT, RUN A: \"source env/bin/activate\"$(COLOR_RESET)"

freeze:
	source $(pip) freeze > requirements.txt

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
	$(RM) -fr build/
	$(RM) -fr dist/
	$(RM) -fr .eggs/
	find . -name '*.egg-info' -exec $(RM) -fr {} +
	find . -name '*.egg' -exec $(RM) -f {} +

clean-pyc:
	find . -name '*.pyc' -exec $(RM) -f {} +
	find . -name '*.pyo' -exec $(RM) -f {} +
	find . -name '*~' -exec $(RM) -f {} +
	find . -name '__pycache__' -exec $(RM) -fr {} +

clean-mypy:
	$(RM) -fr .mypy_cache/

clean-test:
	$(RM) -fr .pytest_cache

test:
	pytest $(tst)

version-patch:
	bump2version patch

version-minor:
	bump2version minor

version-major:
	bump2version major

release: typecheck dist
	twine upload dist/*

dist: clean
	python setup.py sdist
	ls -l dist
