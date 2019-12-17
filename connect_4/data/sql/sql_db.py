import mysql.connector

# init once
_mydb = mysql.connector.connect(
  host="127.0.0.1",
  port=3301,
  user="dummy",
  passwd="dummy_passwd",
  database="connect_4"
)

