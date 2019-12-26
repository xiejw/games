import sys

from .sql_db import _mydb

_sql = "INSERT INTO records (state) VALUES (%s)"

def store_record(record_str):
    # The connection might be offline already due to some reasons. So have retry
    # logic here.
    i = 0
    while True:
        try:
            _mycursor = _mydb.cursor()
            break
        except:
            print("===== Unexpected db error", sys.exc_info()[0])
            i += 1
            if i > 3:
                raise RuntimeError("Exceed retries times.")

            print("Retrying")
            _mydb.reconnect()


    val = (record_str,)
    _mycursor.execute(_sql, val)
    _mydb.commit()
    assert _mycursor.rowcount == 1, "SQL write failed."
