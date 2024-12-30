import os
from datetime import datetime

import pandas as pd
from sqlalchemy import text
from sqlalchemy.engine import Connection

from final_project.py_scripts.config import ARCHIVE_DIR, COLUMNS_RENAME


def get_today_date() -> str:
    """
    Get today's date in the format DDMMYYYY.

    Returns:
        str: A string representing today's date in the format DDMMYYYY.
    """
    today_date = datetime.now().strftime("%d%m%Y")
    print("Date", today_date)
    return today_date


def read_file(file_path: str) -> pd.DataFrame:
    """
    Reads a file and returns its contents as a pandas DataFrame.

    Parameters:
    file_path (str): The path to the file to be read.

    Returns:
    pd.DataFrame: A DataFrame containing the contents of the file.

    Raises:
    ValueError: If the file format is not supported.

    Notes:
    - For .txt files, it assumes the delimiter is ";" and converts the "amount" column to float.
    - For .xlsx and .xls files, it reads the file using pandas read_excel function.
    - The DataFrame columns are renamed according to the COLUMNS_RENAME dictionary.
    """
    file_extension = os.path.splitext(file_path)[1].lower()

    if file_extension == ".txt":  # transactions
        df = pd.read_csv(file_path, delimiter=";")
        df["amount"] = df["amount"].apply(lambda x: float(x.replace(",", ".")))
    elif file_extension in [".xlsx", ".xls"]:
        df = pd.read_excel(file_path)
    else:
        msg = f"Unknow file format: {file_extension}"
        raise ValueError(msg)
    print(f"Read from {file_path}")
    return df.rename(COLUMNS_RENAME, axis=1)


def archive_file(file_path: str) -> None:
    """
    Archives the specified file by renaming it and moving it to the archive directory.

    If the archive directory does not exist, it will be created.

    Args:
        file_path (str): The path to the file that needs to be archived.

    Raises:
        FileNotFoundError: If the specified file does not exist.
        OSError: If there is an error creating the archive directory or renaming the file.

    Example:
        archive_file('/path/to/your/file.txt')
    """
    if not os.path.exists(ARCHIVE_DIR):
        os.makedirs(ARCHIVE_DIR)
        print(f"Created archive directory: {ARCHIVE_DIR}")

    file_name, file_extension = os.path.splitext(os.path.basename(file_path))
    new_file_name = f"{file_name}{file_extension}.backup"
    archive_path = os.path.join(ARCHIVE_DIR, new_file_name)
    os.rename(file_path, archive_path)
    print(f"File {file_path} renamed and archived to {archive_path}")


def delete_table(connection: Connection, table_name: str) -> None:
    """
    Deletes all rows from the specified table in the database.

    This function executes a TRUNCATE TABLE command on the specified table,
    removing all rows and resetting any associated sequences. The operation
    is performed with the CASCADE option, which also truncates any tables
    that have foreign-key references to the specified table.

    Args:
        connection (Connection): The database connection object.
        table_name (str): The name of the table to be truncated.

    Returns:
        None

    Raises:
        sqlalchemy.exc.SQLAlchemyError: If an error occurs during the execution
        of the TRUNCATE TABLE command.

    Example:
        delete_table(connection, 'my_table')
    """
    connection.execute(text(f"TRUNCATE TABLE {table_name} CASCADE"))
    print(f"TRUNCATE TABLE {table_name} complete")


def delete_list_of_tables(connection: Connection, tables: list[str]) -> None:
    """
    Deletes a list of tables from the database.

    Args:
        connection (Connection): The database connection object.
        tables (list[str]): A list of table names to be deleted.

    Returns:
        None
    """
    for table in tables:
        delete_table(connection, table)
