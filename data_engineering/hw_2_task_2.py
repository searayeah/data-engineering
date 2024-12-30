from typing import Literal

import pandas as pd
import psycopg2
from sqlalchemy import create_engine

PREFIX = "miem"
MEDICINE_XLSX_PATH = "data_engineering/medicine.xlsx"
OUTPUT_XLSX_PATH = f"data_engineering/{PREFIX}_med_results.xlsx"
OUTPUT_DB_NAME = f"{PREFIX}_med_results"

DB_HOST = "rc1b-o3ezvcgz5072sgar.mdb.yandexcloud.net"
DB_PORT = 6432
DB_NAME = "db"
DB_LOGIN = "hseguest"
DB_PASSWORD = "hsepassword"


def check_result(row: dict) -> str | None:
    if row["is_simple"] == "Y":
        if row["value"].lower().startswith("полож") or "+" in row["value"]:
            return "Положительный"
    else:
        if float(row["value"]) < float(row["min_value"]):
            return "Понижен"
        if float(row["value"]) > float(row["max_value"]):
            return "Повышен"
    return None


def solve_task(
    tests_data: list, patients_data: list, mode: Literal["easy", "hard"]
) -> pd.DataFrame:

    tests_df = pd.DataFrame(
        tests_data,
        columns=["test_id", "test_name", "min_value", "max_value", "is_simple"],
    )
    patients_df = pd.DataFrame(
        patients_data, columns=["patient_id", "person_name", "phone"]
    )

    # читаю xlsx файл
    data = pd.read_excel(MEDICINE_XLSX_PATH, sheet_name=mode)
    data.columns = ["patient_id", "test_id", "value"]
    data["test_id"] = data["test_id"].astype("str")

    # join с de.med_an_name
    data = data.merge(tests_df, on="test_id", how="left")

    # join с de.med_name
    data = data.merge(patients_df, on="patient_id", how="left")

    # новая колонка result с результатами сравнения с референсными значениями диапазонов
    data["result"] = data.apply(check_result, axis=1)

    # если result != null, значит анализ положительный или повышен/понижен
    bad_results = data[data["result"].notna()]

    # если hard версия, то дополнительнвый group by для выявляния 2+ плохих анализов
    if mode == "hard":
        bad_results_count = (
            bad_results.groupby("patient_id").size().reset_index(name="bad_test_count")
        )

        patients_with_multiple_bad_results = bad_results_count[
            bad_results_count["bad_test_count"] >= 2
        ]

        bad_results = bad_results.merge(
            patients_with_multiple_bad_results[["patient_id"]],
            on="patient_id",
            how="inner",
        )

    bad_results = bad_results[["phone", "person_name", "test_name", "result"]]
    bad_results.columns = ["Телефон", "Имя", "Название анализа", "Заключение"]

    print("MODE:", mode)
    print(bad_results)

    return bad_results


if __name__ == "__main__":
    connection = psycopg2.connect(
        dbname=DB_NAME, user=DB_LOGIN, password=DB_PASSWORD, host=DB_HOST, port=DB_PORT
    )
    cursor = connection.cursor()

    cursor.execute("SELECT id, name, min_value, max_value, is_simple FROM de.med_an_name")
    tests = cursor.fetchall()

    cursor.execute("SELECT id, name, phone FROM de.med_name")
    patients = cursor.fetchall()

    cursor.close()
    connection.close()

    easy_df = solve_task(tests, patients, "easy")
    hard_df = solve_task(tests, patients, "hard")

    # загружу с sqlalchemy, так как pandas плохо поддерживает psycopg2
    db_url = (
        f"postgresql+psycopg2://{DB_LOGIN}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    )

    engine = create_engine(db_url)

    hard_df.to_sql(OUTPUT_DB_NAME, con=engine, index=False, if_exists="replace")

    hard_df.to_excel(OUTPUT_XLSX_PATH, index=False)
