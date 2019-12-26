from .sql_db import get_cursor, commit

_sql = "INSERT INTO records (state) VALUES (%s)"

def store_record(record_str):
    mycursor = get_cursor()
    val = (record_str,)
    mycursor.execute(_sql, val)
    commit()
    assert mycursor.rowcount == 1, "SQL write failed."
