import jwt

def generate(role):
    token = jwt.encode({"role":f"{role}"}, "12345678901234567890123456789012", algorithm="HS256")
    return token