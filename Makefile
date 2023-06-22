SHELL := /bin/bash

COLOR_RESET=\033[0m
COLOR_CYAN=\033[1;36m
COLOR_GREEN=\033[1;32m

src = erdgen
tst = tests

dev-install: install

install: create-venv upgrade-pip install-dependencies install-pre-commit farewell

rm-venv:
	rm -rf env

create-venv:
	@echo -e "$(COLOR_CYAN)Creating virtual environment...$(COLOR_RESET)" && \
	python -m venv env

activate-venv:
	source env/bin/activate && \
	@echo -e "$(COLOR_CYAN)venv activated$(COLOR_RESET)"

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

format:
	@echo -e "$(COLOR_CYAN)Formatting...$(COLOR_RESET)" && \
	isort $(src) $(tst)
	black $(src) $(tst)

freeze:
	pip freeze > requirements.txt

lint:
	pylint $(src) $(tst)

typecheck:
	mypy $(src) $(tst)

pre-commit:
	pre-commit run --all-files

clean: clean-build clean-pyc clean-test farewell

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

version-patch:
	bump2version patch

version-minor:
	bump2version minor

version-major:
	bump2version major

release: dist
	twine upload dist/*

dist: clean
	python setup.py sdist
	ls -l dist

farewell:
	@echo -e "$(COLOR_GREEN)All done!$(COLOR_RESET)"
