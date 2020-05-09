from .sql_db import get_cursor


_read_sql = "SELECT state FROM records ORDER BY id DESC LIMIT %d;"

def read_records(max_num=20):
    cursor = get_cursor()
    cursor.execute(_read_sql % max_num)
    results = cursor.fetchall()

    return [x[0] for x in results]
    cursor.close()
