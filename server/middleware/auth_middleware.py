from fastapi import HTTPException, Header
import jwt


def auth_middleware(x_auth_token = Header()):
    try:
        # get the user token from the headers
        # 헤더로부터 유저의 토큰을 가져온다.
        if not x_auth_token:
            raise HTTPException(401, 'No auth token, access denied!')
        # decode the token
        # 토큰을 디코드 하다.
        verified_token = jwt.decode(x_auth_token, 'password_key', ['HS256'])

        if not verified_token:
            raise HTTPException(401, 'Token verification failed, authorization denied!')
        # get the id from the token
        # 토큰에서 아이디를 가져온다.
        uid = verified_token.get('id')
        return {'uid': uid, 'token': x_auth_token}
        # postgres db get the user info
        # 포스트그레스 데이터베이스에서 유저 정보를 가져온다.
    except jwt.PyJWTError:
        raise HTTPException(401, 'Token is valid, authorization failed!')
    # return the user info
    # 유저 정보를 반환한다.