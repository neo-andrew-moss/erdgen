# `erdgen`

> DBT YML ERD Generator

[![pypi](https://img.shields.io/pypi/v/erdgen?style=for-the-badge)](https://pypi.org/project/erdgen/)

## Overview

This Python program generates Database Markup Language (DBML) Entity Relationship Diagram's (ERD) from the relationships node in your dbt YML files. The script parses the YML files, extracts relationships and columns, and outputs a DBML schema.

The program is pretty opinionated. It requires each YML file to only contain one model. Further, the "relationships" node in dbt yml is a made-up construct.

This program is useful for automated ERD generation if your dbt project doesn't have referential integrity or explicit SQL relationships. If your SQL models have defined SQL relationships there are better tools for automated ERD generation.

## Usage

```bash
python -m erdgen --directory <directory> --include_non_join_keys <True/False>
```

### Args

- `--directory`: Directory to search for YAML files. The default value is the current directory ('.').
- `--include_non_join_keys`: Boolean flag to indicate whether to include non-join keys in the DBML. The default value is `False`.

The DBML will be printed to the console. You can redirect this output to a file if desired.

## YML File Structure

The YML files are expected to have the following structure:

```yml
version: 2

models:
    - name: Computer
      description: beep boop beep
      columns:
          - name: computerId
            description: The unique identifier of computer
          # other non-join key columns as necessary
      relationships:
          - name: files
            description: The files are in the computer!?
            type: one_to_many
            table: computer_files
            join:
                - local: computerId
                  remote: computerId
```

**note**: Each YML file should contain only one model under the `models` node.

### Relationships

The `relationships` node in the YML files represents the relationship between the current model and other models. It is composed of several sub-nodes:

- `name`: The name of the relationship.
- `description`: A brief description of the relationship.
- `type`: The type of the relationship. It can be `one_to_one`, `one_to_many`, `many_to_one`, or `many_to_many`.
- `table`: The name of the other model involved in the relationship.
- `join`: A list of the columns that are used for the join between the current model and the other model. Each item in the list is composed of `local` and - `remote` nodes, representing the column in the current model and the column in the other model, respectively.

## Output

The output is a DBML schema that includes the tables, columns, and references based on the relationships defined in the YML files. The output is printed to the console.

## Notes

- If a YML model file has no `relationships`, and `include_non_join_keys` is `False`, all columns from the YML are included in the DBML table. This is helpful as other models may have a `relationship` to this model, and there is no way to know which column is being referenced (well there is but I didn't bother figuring this out)
- Regardless of whether `include_non_join_keys` is `True` or `False`, columns that contain `Id` or `id` in them are always included. These are likely join keys that do not have a relationship yet.

## Improvements

- All data types are int, account for the actual data type via metadata in the YML file
- All relationships are 1:1, account for the cardinality via the relationship `type`
- What about `.yaml` files lol

## DEV

### Create venv

```bash
python -m venv env
```

### Activate venv

- unix

```bash
source env/bin/activate
```

- windows

```bash
env\Scripts\activate.bat
```

### Install Packages

```bash
pip install -r requirements.txt
```

## Format

```bash
make format
```

```bash
make lint
```

## TODO

- Add better error handling and reporting
- Perhaps add a debug/verbose mode
- make it less jank
