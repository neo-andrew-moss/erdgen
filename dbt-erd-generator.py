import os
import yaml
from functools import reduce
from jinja2 import Template


def load_yml(file):
    with open(file, "r") as stream:
        try:
            return yaml.safe_load(stream)
        except yaml.YAMLError as e:
            print(e)


def extract_columns(file, include_non_join_keys=False):
    data = load_yml(file)
    columns = data["models"][0]["columns"]
    relationships = data["models"][0].get("relationships", [])
    join_cols = [rel["join"][0]["local"] for rel in relationships]

    if include_non_join_keys or not relationships:
        return [(col["name"], "int") for col in columns]
    else:
        return [
            (col["name"], "int")
            for col in columns
            if col["name"] in join_cols or "Id" in col["name"] or "id" in col["name"]
        ]


def extract_relationships(file):
    data = load_yml(file)
    relationships = data["models"][0].get("relationships", [])
    return [
        (
            rel["name"],
            rel["table"],
            rel["type"],
            rel["join"][0]["local"],
            rel["join"][0]["remote"],
        )
        for rel in relationships
    ]


def generate_dbml(file, include_non_join_keys=False):
    table_name = os.path.splitext(os.path.basename(file))[0]
    columns = extract_columns(file, include_non_join_keys)
    relationships = extract_relationships(file)

    columns_with_refs = []
    for name, _ in columns:
        column = {"name": name, "is_ref": False}
        for _, table, _, local, remote in relationships:
            if name == local:
                column.update(
                    {"is_ref": True, "ref_table": table, "ref_column": remote}
                )
        columns_with_refs.append(column)

    models = [
        {
            "name": table_name,
            "columns": columns_with_refs,
        }
    ]

    dbml_template = Template(
        """
    {% for model in models %}
    Table {{ model.name }} {
        {% for column in model.columns %}
        {{ column.name }} int{% if column.is_ref %} [ref: - {{ column.ref_table }}.{{ column.ref_column }}]{% endif %}
        {% endfor %}
    }
    {% endfor %}
    """
    )

    return dbml_template.render(models=models)


def generate_dbml_schema(directory, include_non_join_keys=False):
    yml_files = [
        os.path.join(directory, file)
        for file in os.listdir(directory)
        if file.endswith(".yml")
    ]
    dbml_files = map(lambda file: generate_dbml(file, include_non_join_keys), yml_files)
    return reduce(lambda a, b: a + b, dbml_files, "")


print(generate_dbml_schema(".", include_non_join_keys=True))
