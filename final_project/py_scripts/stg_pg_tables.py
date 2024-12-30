from sqlalchemy import text
from sqlalchemy.engine import Connection

from final_project.py_scripts.config import PREFIX
from final_project.py_scripts.utils import delete_list_of_tables


def load_pg_tables_to_stg(
    connection: Connection,
    source_table_name: str,
    target_table_name: str,
    columns: list[str],
) -> None:
    """
    Copies data from a source table to a target table in a PostgreSQL database.

    This function performs an insert operation from the source table to the target table,
    selecting specified columns. If a column named 'update_dt' is present in the columns list,
    it will be replaced with 'create_dt' in the target table to handle Slowly Changing Dimension
    Type 1 (SCD1) scenarios.

    Args:
        connection (Connection): The database connection object.
        source_table_name (str): The name of the source table from which data will be copied.
        target_table_name (str): The name of the target table to which data will be copied.
        columns (list[str]): A list of column names to be copied from the source table to the target table.

    Returns:
        None

    Raises:
        sqlalchemy.exc.SQLAlchemyError: If there is an error executing the SQL statement.
    """
    column_names = ", ".join(columns)
    column_selected = ", ".join(
        ["create_dt" if col == "update_dt" else col for col in columns]
    )  # set update_dt as create_dt for SCD1

    connection.execute(
        text(
            f"INSERT INTO {target_table_name} ({column_names}) "
            f"SELECT {column_selected} "
            f"FROM {source_table_name}"
        )
    )
    print(
        f"Copied data from {source_table_name} to {target_table_name} with columns: {column_names}"
    )


def stg_pg_tables(connection: Connection) -> None:
    """
    Stages PostgreSQL tables by mapping source tables to destination staging tables
    and loading data from source to destination.

    Args:
        connection (Connection): The database connection object.

    The function performs the following steps:
    1. Defines a mapping of source tables to destination staging tables.
    2. Defines the columns for each source table.
    3. Deletes existing data from the destination staging tables in reverse order.
    4. Loads data from each source table to the corresponding destination staging table.
    """
    pg_table_mapping = {
        "info.clients": f"{PREFIX}_stg_clients",
        "info.accounts": f"{PREFIX}_stg_accounts",
        "info.cards": f"{PREFIX}_stg_cards",
    }

    pg_table_columns = {
        "info.clients": [
            "client_id",
            "last_name",
            "first_name",
            "patronymic",
            "date_of_birth",
            "passport_num",
            "passport_valid_to",
            "phone",
            "create_dt",
            "update_dt",
        ],
        "info.accounts": [
            "account",
            "valid_to",
            "client",
            "create_dt",
            "update_dt",
        ],
        "info.cards": [
            "card_num",
            "account",
            "create_dt",
            "update_dt",
        ],
    }

    delete_list_of_tables(connection, list(pg_table_mapping.values())[::-1])

    for src_table, dest_table in pg_table_mapping.items():
        load_pg_tables_to_stg(
            connection, src_table, dest_table, pg_table_columns[src_table]
        )
