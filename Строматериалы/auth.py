from database import get_user


def authenticate_user(login, password):
    if not login or not password:
        return None

    user = get_user(login, password)

    return user