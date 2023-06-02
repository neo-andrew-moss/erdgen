#!/usr/bin/env python

from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

with open('requirements.txt') as f:
    requirements = f.read().splitlines()

setup(
    author='Andrew Moss',
    author_email='andrew.moss@neofinancial.com',
    python_requires='>=3.6',
    name='erdgen',
    version='0.0.1rc1',
    description='Generate a DBML ERD from DBT YML relationships',
    license="MIT license",
    packages=find_packages(include=['erdgen', 'erdgen.*']),
    url="https://github.com/neo-andrew-moss/erdgen",
    include_package_data=True,
    long_description=long_description,
    long_description_content_type="text/markdown",
    install_requires=requirements
)