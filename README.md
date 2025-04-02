# Flutter와 FastAPI를 이용한 음악 스트리밍 프로젝트

<p align="center">
  <img src="https://github.com/user-attachments/assets/fc0f1566-0628-4551-985a-1992715e3c08" alt="Image">
</p>

## 프로젝트 개요
본 프로젝트는 **Flutter 프레임워크**와 **FastAPI** 백엔드 기술, **PostgreSQL DB**, **Cloudinary** 을 활용하여 **음악 스트리밍 애플리케이션**을 구축했습니다. MVVM (Model-View-ViewModel) 아키텍처를 기반으로 사용자 인증부터 백그라운드 음악 재생까지 다양한 기능을 구현했습니다.
## 주요 기능
다음과 같은 주요 기능을 구현했습니다.
- **사용자 인증:** 로그인 및 회원 가입 기능
- **상태 유지:** 로그인 상태 유지
- **음악 업로드:** 사용자가 음악을 업로드할 수 있는 기능
- **최신곡 표시 및 재생:** 최신 음악 목록 표시 및 재생 기능
- **백그라운드 음악 재생:** 앱이 백그라운드에 있어도 음악 재생 유지 및 제어 옵션, 알림 기능
- **즐겨찾기 트랙 관리:** 사용자가 좋아하는 곡을 추가하고 관리하는 기능
- **최근 재생 목록:** 최근 재생한 곡 목록 표시

## 기술 스택
본 프로젝트는 다음과 같은 기술들을 사용했습니다.

### 클라이언트 (Flutter):
- **Flutter:** 사용자 인터페이스 (UI) 구축을 위한 크로스 플랫폼 프레임워크 및 **Dart** 언어 사용.
- **Riverpod:** 효율적이고 예측 가능한 **상태 관리** 라이브러리.
- **HTTP:** 서버와의 통신을 위한 HTTP 패키지 사용.
- **Just Audio:** 다양한 기능을 제공하는 **오디오 재생** 플러그인.
- **Audio Waveforms:** 오디오 파일의 **파형 시각화**를 위한 패키지.
- **Hive:** 빠르고 가벼운 **NoSQL 데이터베이스**를 이용한 로컬 데이터 저장.
- **Shared Preferences:** 간단한 키-값 쌍 형태의 **영구 데이터 저장**.

### 서버 (FastAPI):
- **Python:** 백엔드 로직 및 API 개발을 위한 프로그래밍 언어.
- **FastAPI:** 고성능 웹 프레임워크를 이용한 **API 구축**.
- **PostgreSQL:** 안정적인 **관계형 데이터베이스** 관리 시스템 (RDBMS).
- **Cloudinary:** 이미지 및 오디오 파일 **저장 및 관리**를 위한 클라우드 서비스.
- **Pydantic:** 요청 및 응답 데이터의 **유효성 검사**를 위한 라이브러리.
- **SQLAlchemy:** 데이터베이스 상호 작용을 위한 **SQL 툴킷 및 ORM**.
- **bcrypt:** 안전한 **비밀번호 해싱**을 위한 라이브러리.
- **JWT (JSON Web Token):** **사용자 인증 및 권한 부여**를 위한 표준.

## 아키텍처
본 프로젝트는 **MVVM (Model-View-ViewModel) 아키텍처** 패턴을 따랐습니다. 이는 다음과 같은 세 가지 주요 구성 요소로 이루어져 있습니다:

- **Model:** 애플리케이션의 **데이터와 비즈니스 로직**을 나타냅니다. 데이터베이스나 외부 소스로부터 데이터를 관리하는 역할을 수행합니다.
- **View:** 사용자에게 보이는 **UI 사용자 인터페이스**를 담당합니다. 뷰 모델에 정의된 데이터를 기반으로 화면을 표시하고, 사용자 액션을 뷰 모델에 전달합니다. (Flutter 위젯)
- **ViewModel:** **뷰와 모델 사이의 중재자** 역할을 합니다. 뷰로부터 전달된 사용자 액션을 처리하고, 모델로부터 데이터를 가져와 뷰에서 사용할 수 있는 형태로 가공하여 뷰에 제공합니다. (Riverpod Notifier 활용)

이러한 아키텍처는 **관심사의 분리**를 통해 코드의 유지보수성, 테스트 용이성 및 확장성을 향상시킵니다.

## 상태 관리
**Riverpod** 라이브러리를 사용하여 애플리케이션의 **상태를 효율적으로 관리**합니다. Riverpod는 Provider 패턴을 개선하여 **전역 상태를 안전하고 쉽게 관리**할 수 있도록 하며, 위젯 트리 어디에서든 상태에 쉽게 접근할 수 있도록 해줍니다. **ProviderScope 위젯**은 Riverpod에서 생성된 모든 Provider를 관리하고 접근할 수 있는 범위를 제공하기 위해 애플리케이션의 위젯 트리 최상단에 위치합니다.

## 백엔드 상세 정보
**FastAPI**를 사용하여 구축된 백엔드는 클라이언트 애플리케이션과 통신하는 **API 엔드포인트**를 제공합니다. **PostgreSQL** 데이터베이스를 사용하여 사용자 정보, 음악 메타데이터 등의 데이터를 **영구적으로 저장**합니다. 대용량 음악 및 썸네일 파일은 **Cloudinary** 클라우드 스토리지 서비스에 저장하고, 저장된 파일의 URL을 데이터베이스에 기록하는 방식으로 관리합니다.

## 로컬 데이터 저장
사용자의 최근 재생 목록 및 기타 로컬 데이터는 **Hive** NoSQL 데이터베이스를 사용하여 **빠르고 효율적으로 저장 및 관리**합니다.

## Feature-wise 개발
"feature-wise development" 방식을 따랐습니다. 이는 각 **기능별로 관련된 모델, 뷰, 뷰 모델 등을 포함하는 폴더를 분리**하여 코드를 구성하는 방식입니다. 이러한 접근 방식은 코드의 **구성을 개선**하고, 특정 기능을 **쉽게 제거하거나 수정**할 수 있도록 하여 코드베이스의 **유지보수성을 향상**시키는 주요 이점을 제공합니다.

## 로컬 개발 환경 설정 (참고)
1. **Git:** 프로젝트 코드를 복제하기 위해 필요합니다.
2. **Flutter SDK:** 클라이언트 애플리케이션을 빌드하고 실행하기 위해 설치해야 합니다. Flutter 공식 문서를 참고하여 설치하십시오.
3. **Python 3.7 이상:** 서버 애플리케이션을 실행하기 위해 필요합니다.
4. **pip:** Python 패키지 관리자입니다.
5. **가상 환경 (Virtual Environment):** 프로젝트 의존성을 격리하기 위해 설정하는 것을 권장합니다. 터미널에서 프로젝트 디렉토리로 이동 후 python3 -m venv venv 명령어를 실행하여 생성하고, source venv/bin/activate 명령어를 실행하여 활성화합니다.
6. **FastAPI 및 의존성 설치:** 서버 디렉토리에서 pip install -r requirements.txt (제공된 경우) 또는 pip install fastapi uvicorn python-multipart psycopg2-binary passlib[bcrypt] python-jose[cryptography] cloudinary 등의 필요한 패키지를 설치합니다.
7. **PostgreSQL:** 데이터베이스 서버를 설치하고 실행해야 합니다.
8. **Cloudinary 계정:** 미디어 파일 저장을 위해 Cloudinary 계정이 필요합니다.

## 오류해결

프로젝트를 진행하면서 발생했던 주요 문제점들과 해결 방법을 서버와 클라이언트 측면에서 정리해보았습니다.

### 서버 측 오류

1. **데이터베이스 관계 처리 문제**
  * 음악 삭제 시 외래 키 제약조건으로 인한 문제가 발생했습니다.
  * Favorite 테이블의 레코드를 먼저 삭제한 후 Song 레코드를 삭제하는 순서로 해결했습니다.
  * 데이터베이스 설계 시 관계 설정의 중요성 알게 되었습니다.

2. **API 엔드포인트 에러 처리**
  * /auth/signup 엔드포인트에서 400 에러가 발생하는 문제가 있었습니다.
  * 적절한 에러 메시지와 예외 처리를 추가하여 개선했습니다.
  * 이는 API 설계 시 견고한 에러 처리의 중요성을 보여줍니다.

### 클라이언트 측 오류

1. **로그아웃 시 상태 관리 문제**
  * 로그아웃 시 currentUserNotifierProvider가 null이 되면서 발생하는 null 참조 오류
  * 음악 재생 중 로그아웃 시 MusicSlab과 MusicPlayer 위젯에서 발생하는 크래시
  * 해결: 로그아웃 전에 currentSongNotifier를 리셋하고, 각 위젯에 null 체크를 추가

2. **파일 선택기(FilePicker) 관련 문제**
  * 이미지와 오디오 파일 선택 시 xFile 속성 접근 오류
  * 안드로이드 에뮬레이터에서 파일 접근 권한 문제
  * 해결: path 속성을 직접 사용하도록 수정하고, 파일 선택 로직 개선

3. **음악 재생 상태 관리 문제**
  * 로그아웃 후에도 음악이 계속 재생되는 문제
  * 음악 재생 중 앱 종료/백그라운드 전환 시 상태 관리 문제
  * 해결: CurrentSongNotifier에 적절한 상태 리셋 로직 추가

4. **UI 업데이트 지연 문제**
  * 곡 삭제/숨김 처리 후 UI가 즉시 업데이트되지 않는 문제
  * 좋아요 기능 사용 시 UI 반영 지연
  * 해결: ref.invalidate()를 사용하여 관련 프로바이더 무효화

5. **에러 처리 및 사용자 피드백 부족**
  * 파일 업로드 실패 시 명확한 에러 메시지 부재
  * 네트워크 오류 발생 시 사용자에게 적절한 피드백 부족
  * 해결: showSnackBar를 통한 사용자 피드백 추가 및 에러 처리 로직 개선

## 프로젝트 학습 사전

- **MVVM Architecture**: Model-View-ViewModel의 약자로, 사용자 인터페이스 개발을 위한 디자인 패턴입니다. 데이터 모델, 사용자 인터페이스 뷰, 뷰의 데이터를 관리하는 뷰 모델로 구성됩니다.
- **Riverpod**: Flutter를 위한 반응형 캐시 및 상태 관리 프레임워크로, Provider 패턴을 개선하여 전역 상태를 안전하고 쉽게 관리할 수 있도록 합니다.
- **PostgreSQL**: 객체-관계형 데이터베이스 관리 시스템 (ORDBMS)으로, 안정성, 기능 확장성, 표준 준수를 강조합니다.
- **Cloudinary**: 클라우드 기반의 이미지 및 비디오 관리 서비스로, 미디어 업로드, 저장, 변환, 최적화, 전달을 용이하게 합니다.
- **Hive**: 빠르고 가벼운 키-값 NoSQL 데이터베이스로, Flutter 애플리케이션에서 로컬 데이터를 효율적으로 저장하고 검색하는 데 사용됩니다.
- **JWT (JSON Web Token)**: 당사자 간에 정보를 JSON 객체로 안전하게 전송하기 위한 개방형 산업 표준입니다. 주로 사용자 인증 및 권한 부여에 사용됩니다.
- **Hashing**: 임의의 길이의 데이터를 고정된 길이의 값으로 변환하는 과정으로, 주로 비밀번호와 같은 민감한 정보를 안전하게 저장하기 위해 사용됩니다. 단방향 함수이므로 원래 데이터를 복원할 수 없습니다.
- **Feature-wise Development**: 애플리케이션의 각 기능을 독립적인 모듈 또는 폴더로 구성하는 개발 방식입니다. 코드의 조직화와 유지보수성을 향상시킵니다.
