import os
from datetime import datetime

from sqlalchemy.engine import Connection

from final_project.py_scripts.config import FILES_DIR, PREFIX
from final_project.py_scripts.utils import archive_file, delete_list_of_tables, read_file


def load_local_files_to_stg(
    connection: Connection, file_path: str, table_name: str, today_date: str
) -> None:
    """
    Load local files into a staging table in the database.

    Parameters:
    connection (Connection): The database connection object.
    file_path (str): The path to the local file to be loaded.
    table_name (str): The name of the staging table where the data will be inserted.
    today_date (str): The current date in the format 'ddmmyyyy'.

    Returns:
    None

    This function reads a local file into a DataFrame, processes the DataFrame by adding
    'create_dt' and 'update_dt' columns if the table name contains 'terminals', and then
    inserts the DataFrame into the specified staging table in the database. The data is
    appended to the table if it already exists.
    """
    df = read_file(file_path)
    if "terminals" in table_name:
        df["create_dt"] = datetime.strptime(today_date, "%d%m%Y")
        df["update_dt"] = datetime.strptime(today_date, "%d%m%Y")
    df.to_sql(table_name, connection, if_exists="append", index=False)
    print(f"Date {file_path} inserted into {table_name}")


def stg_local_files(connection: Connection, today_date: str) -> None:
    """
    Stages local files into the database.

    This function processes a set of local files, loads their data into staging tables in the database,
    and optionally archives the files after loading. The files are expected to be named with a specific
    pattern that includes the current date.

    Args:
        connection (Connection): The database connection object.
        today_date (str): The current date in 'YYYYMMDD' format, used to identify the files to be processed.

    Returns:
        None
    """

    files_to_tables = {
        f"passport_blacklist_{today_date}.xlsx": f"{PREFIX}_stg_passport_blacklist",
        f"terminals_{today_date}.xlsx": f"{PREFIX}_stg_terminals",
        f"transactions_{today_date}.txt": f"{PREFIX}_stg_transactions",
    }

    delete_list_of_tables(connection, list(files_to_tables.values())[::-1])

    for file_name, table_name in files_to_tables.items():
        file_path = os.path.join(FILES_DIR, file_name)

        if os.path.exists(file_path):
            load_local_files_to_stg(connection, file_path, table_name, today_date)
            archive_file(file_path)
