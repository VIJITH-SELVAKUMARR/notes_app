import sqlite3

conn = sqlite3.connect('db.sqlite3')
cursor = conn.cursor()

cursor.execute("SELECT * from auth_user")
rows = cursor.fetchall()

for row in rows:
    print(row)

conn.close()