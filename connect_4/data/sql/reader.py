from .sql_db import _mydb


_read_sql = "SELECT state FROM records ORDER BY id DESC LIMIT %d;"

def read_records(max_num=20):
    cursor = _mydb.cursor()
    cursor.execute(_read_sql % max_num)
    results = cursor.fetchall()

    for i in results:
        print(i)
