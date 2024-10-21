import jwt

def generate(role):
    token = jwt.encode({"role":f"{role}"}, "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz", algorithm="HS256")
    return token