import mysql.connector

# init once
_mydb = mysql.connector.connect(
  host="127.0.0.1",
  port=3301,
  user="dummy",
  passwd="dummy_passwd",
  database="connect_4"
)

def get_cursor(retries=3):
    # The connection might be offline already due to some reasons, say timeout.
    # So have retry logic here.
    i = 0
    while True:

        try:
            _mycursor = _mydb.cursor()
            return _mycursor

        except Exception as ex:
            print("===== Unexpected db error:", ex)
            i += 1
            if i > retries:
                raise RuntimeError("Exceed retries times.")

            print("Retrying...")
            _mydb.reconnect()


def commit():
    _mydb.commit()

def close():
    print("Close db.")
    global _mydb
    _mydb.close()
    _mydb = None

