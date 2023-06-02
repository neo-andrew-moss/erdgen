format: 
	black ./dbt_erd_generator

lint:
	pylint ./dbt_erd_generator

release: dist
	twine upload dist/*

dist:
	python setup.py sdist
	ls -l dist
