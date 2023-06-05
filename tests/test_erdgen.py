import pytest
import os
from tempfile import TemporaryDirectory
from erdgen.src._ import (
    load_yml,
    generate_dbml,
    generate_dbml_schema,
    extract_relationships,
    extract_columns,
)

sample_yaml_content = """
version: 2
models:
 - name: Computer
   description: beep boop beep
   columns:
     - name: computerId
       description: The unique identifier of computer
   relationships:
     - name: files
       description: The files are in the computer!?
       type: one_to_many
       table: computer_files
       join:
         - local: computerId
           remote: computerId
"""


def test_load_yml():
    with TemporaryDirectory() as tempdir:
        test_file_path = os.path.join(tempdir, "model.yml")
        with open(test_file_path, "w") as f:
            f.write(sample_yaml_content)
        parsed = load_yml(test_file_path)
        assert isinstance(parsed, dict)
        assert parsed["models"][0]["name"] == "Computer"
        assert len(parsed["models"][0]["relationships"]) == 1


def test_extract_columns():
    with TemporaryDirectory() as tempdir:
        test_file_path = os.path.join(tempdir, "model.yml")
        with open(test_file_path, "w") as f:
            f.write(sample_yaml_content)
        columns = extract_columns(test_file_path)
        assert len(columns) == 1
        assert columns[0][0] == "computerId"
        assert columns[0][1] == "int"


def test_extract_relationships():
    with TemporaryDirectory() as tempdir:
        test_file_path = os.path.join(tempdir, "model.yml")
        with open(test_file_path, "w") as f:
            f.write(sample_yaml_content)
        relationships = extract_relationships(test_file_path)
        assert len(relationships) == 1
        assert relationships[0][0] == "files"
        assert relationships[0][1] == "computer_files"
        assert relationships[0][3] == "computerId"


def test_generate_dbml():
    with TemporaryDirectory() as tempdir:
        test_file_path = os.path.join(tempdir, "model.yml")
        with open(test_file_path, "w") as f:
            f.write(sample_yaml_content)
        dbml_output = generate_dbml(test_file_path)
        assert isinstance(dbml_output, str)
        assert "Table model" in dbml_output
        assert "computerId int [ref: - computer_files.computerId]" in dbml_output
