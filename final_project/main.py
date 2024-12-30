#!/usr/bin/env python

from datetime import datetime

from sqlalchemy import create_engine, text

from final_project.py_scripts.config import (
    DB_HOST,
    DB_LOGIN,
    DB_NAME,
    DB_PASSWORD,
    DB_PORT,
    PROJECT_DIR,
)
from final_project.py_scripts.stg_local_files import stg_local_files
from final_project.py_scripts.stg_pg_tables import stg_pg_tables

engine = create_engine(
    f"postgresql://{DB_LOGIN}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)


def execute_project(date: str):
    main_script = open(f"{PROJECT_DIR}/main.ddl").read()

    accounts_scd1 = open(f"{PROJECT_DIR}/sql_scripts/accounts_scd1.sql").read()
    cards_scd1 = open(f"{PROJECT_DIR}/sql_scripts/cards_scd1.sql").read()
    clients_scd1 = open(f"{PROJECT_DIR}/sql_scripts/clients_scd1.sql").read()
    terminals_scd1 = open(f"{PROJECT_DIR}/sql_scripts/terminals_scd1.sql").read()

    accounts_scd2 = open(f"{PROJECT_DIR}/sql_scripts/accounts_scd2.sql").read()
    cards_scd2 = open(f"{PROJECT_DIR}/sql_scripts/cards_scd2.sql").read()
    clients_scd2 = open(f"{PROJECT_DIR}/sql_scripts/clients_scd2.sql").read()
    terminals_scd2 = open(f"{PROJECT_DIR}/sql_scripts/terminals_scd2.sql").read()

    fact_tables = open(f"{PROJECT_DIR}/sql_scripts/fact_tables.sql").read()

    report_script = open(f"{PROJECT_DIR}/sql_scripts/create_report.sql").read()

    with engine.connect() as connection:
        connection.execute(text(main_script))

        stg_pg_tables(connection)
        stg_local_files(connection, date)

        connection.execute(text(clients_scd1))
        connection.execute(text(accounts_scd1))
        connection.execute(text(cards_scd1))
        connection.execute(text(terminals_scd1))

        connection.execute(text(clients_scd2))
        connection.execute(text(accounts_scd2))
        connection.execute(text(cards_scd2))
        connection.execute(text(terminals_scd2))

        connection.execute(text(fact_tables))

        connection.execute(
            text(
                report_script.replace(
                    "CURRENT_DATE",
                    f"""'{datetime.strptime(date, "%d%m%Y").strftime("%Y-%m-%d")}'""",
                )
            )
        )

        connection.commit()


if __name__ == "__main__":

    # normal mode
    from final_project.py_scripts.utils import get_today_date

    dt = get_today_date()
    execute_project(dt)

    # # прогнать все файлы и дни
    # drop_all = open("final_project/sql_scripts/drop_everything.sql").read()
    # with engine.connect() as conn:
    #     conn.execute(text(drop_all))
    #     conn.commit()

    # for dt in ["01032021", "02032021", "03032021"]:
    #     print("########## Day ##########", dt)
    #     execute_project(dt)
