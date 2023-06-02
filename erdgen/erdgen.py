"""cli"""
import click
from erdgen.src._ import generate_dbml_schema


@click.command()
@click.option("--directory", default=".", help="Directory to search for yml files")
@click.option(
    "--include_non_join_keys", default=False, help="Include non join keys", type=bool
)
def main(directory: str, include_non_join_keys: bool) -> None:
    """main"""
    print(generate_dbml_schema(directory, include_non_join_keys))
