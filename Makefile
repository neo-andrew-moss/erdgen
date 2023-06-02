format: 
	black ./erdgen

lint:
	pylint ./erdgen

release: dist
	twine upload dist/*

dist:
	python setup.py sdist
	ls -l dist
