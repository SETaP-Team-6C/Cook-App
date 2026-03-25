import bcrypt

password = "123456".encode("utf-8")
hashed = bcrypt.hashpw(password,bcrypt.gensalt())

print(hashed.decode())
