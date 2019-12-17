from .sql_db import _mydb

_sql = "INSERT INTO records (state) VALUES (%s)"

def store_record(record_str):
    _mycursor = _mydb.cursor()
    val = (record_str,)
    _mycursor.execute(_sql, val)
    _mydb.commit()
    assert _mycursor.rowcount == 1, "SQL write failed."
