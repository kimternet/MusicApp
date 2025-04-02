import uuid
from fastapi import APIRouter, File, UploadFile, Form, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from middleware.auth_middleware import auth_middleware
import cloudinary
import cloudinary.uploader
import os
from dotenv import load_dotenv

from models.favorite import Favorite
from models.song import Song
from pydantic_schemas.favorite_song import FavoriteSong
from sqlalchemy.orm import joinedload




router = APIRouter()

# Configuration       
load_dotenv()
cloudinary.config( 
    cloud_name = os.getenv("CLOUDINARY_CLOUD_NAME"), 
    api_key = os.getenv("CLOUDINARY_API_KEY"), 
    api_secret = os.getenv("CLOUDINARY_API_SECRET"),
    secure=True
)

@router.post('/upload', status_code=201)
def upload_song(song: UploadFile=File(...), 
                thumbnail: UploadFile=File(...), 
                artist: str = Form(...), 
                song_name: str = Form(...), 
                hex_code: str = Form(...),
                db: Session = Depends(get_db),
                auth_dict = Depends(auth_middleware)):
    song_id = str(uuid.uuid4())
    song_res = cloudinary.uploader.upload(song.file, resource_type='auto', folder='songs/{song_id}')
    thumbnail_res = cloudinary.uploader.upload(thumbnail.file, resource_type='image', folder='thumbnails/{song_id}')

    new_song = Song(
        id = song_id,
        song_name = song_name,
        artist = artist,
        hex_code = hex_code,
        song_url = song_res['url'],
        thumbnail_url = thumbnail_res['url']
    )

    db.add(new_song)
    db.commit()
    db.refresh(new_song)

    return new_song

@router.get('/list')
def list_songs(db: Session=Depends(get_db), 
               auth_details=Depends(auth_middleware)):
    songs = db.query(Song).all()
    return songs

@router.post('/favorite')
def favorite_song(song: FavoriteSong, 
                  db: Session=Depends(get_db), 
                  auth_details=Depends(auth_middleware)):
    # song is already favorited by the user
    user_id = auth_details['uid']

    fav_song = db.query(Favorite).filter(Favorite.song_id == song.song_id, Favorite.user_id == user_id).first()

    if fav_song:
        db.delete(fav_song)
        db.commit()
        return {'message': False}
    else:
        new_fav = Favorite(id=str(uuid.uuid4()), song_id=song.song_id, user_id=user_id)
        db.add(new_fav)
        db.commit()
        return {'message': True}
    
@router.get('/list/favorites')
def list_fav_songs(db: Session=Depends(get_db), 
               auth_details=Depends(auth_middleware)):
    user_id = auth_details['uid']
    fav_songs = db.query(Favorite).filter(Favorite.user_id == user_id).options(
        joinedload(Favorite.song),
    ).all()
    
    return fav_songs

@router.delete('/{song_id}')
def delete_song(song_id: str, 
                db: Session=Depends(get_db), 
                auth_details=Depends(auth_middleware)):
    """특정 음악을 삭제합니다."""
    # 음악이 존재하는지 확인
    song = db.query(Song).filter(Song.id == song_id).first()
    
    if not song:
        raise HTTPException(status_code=404, detail="음악을 찾을 수 없습니다.")
    
    # 먼저 즐겨찾기 관계를 삭제 (외래 키 제약조건)
    db.query(Favorite).filter(Favorite.song_id == song_id).delete()
    
    # 음악 데이터 삭제
    db.delete(song)
    db.commit()
    
    # Cloudinary에서 파일 삭제 (선택적)
    try:
        # 파일 경로에서 public_id 추출
        song_public_id = song.song_url.split('/')[-1].split('.')[0]
        thumbnail_public_id = song.thumbnail_url.split('/')[-1].split('.')[0]
        
        # Cloudinary에서 파일 삭제
        cloudinary.uploader.destroy(f"songs/{song_id}/{song_public_id}")
        cloudinary.uploader.destroy(f"thumbnails/{song_id}/{thumbnail_public_id}")
    except Exception as e:
        # 파일 삭제 실패해도 DB 데이터는 이미 삭제됨
        print(f"Cloudinary 파일 삭제 실패: {str(e)}")
    
    return {"message": "음악이 성공적으로 삭제되었습니다."}