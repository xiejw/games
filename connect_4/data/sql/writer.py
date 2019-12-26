from .sql_db import get_cursor

_sql = "INSERT INTO records (state) VALUES (%s)"

def store_record(record_str):
    _mycursor = get_cursor()
    val = (record_str,)
    _mycursor.execute(_sql, val)
    _mydb.commit()
    assert _mycursor.rowcount == 1, "SQL write failed."
