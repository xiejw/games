import mysql.connector

# init once
_mydb = mysql.connector.connect(
  host="127.0.0.1",
  port=3301,
  user="dummy",
  passwd="dummy_passwd",
  database="connect_4"
)

_sql = "INSERT INTO records (state) VALUES (%s)"

def store_one_state(state_str):
    _mycursor = _mydb.cursor()
    val = (state_str,)
    _mycursor.execute(_sql, val)
    _mydb.commit()
    assert _mycursor.rowcount == 1, "SQL write failed."
