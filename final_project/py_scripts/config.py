PREFIX = "miem"
DB_HOST = "rc1b-o3ezvcgz5072sgar.mdb.yandexcloud.net"
DB_PORT = 6432
DB_NAME = "db"
DB_LOGIN = "hseguest"
DB_PASSWORD = "hsepassword"


PROJECT_DIR = "final_project"
FILES_DIR = f"{PROJECT_DIR}/files"
ARCHIVE_DIR = f"{PROJECT_DIR}/archive"

COLUMNS_RENAME = {
    "transaction_id": "trans_id",
    "transaction_date": "trans_date",
    "amount": "amt",
    "card_num": "card_num",
    "oper_type": "oper_type",
    "oper_result": "oper_result",
    "terminal": "terminal",
    "date": "entry_dt",
    "passport": "passport_num",
}
