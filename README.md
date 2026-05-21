 # (프로젝트명)
**WiGul**  
충동구매인 줄 알면서도 멈추지 못하는 순간, 너구리와 함께 구매의 필요성을 점검해 보아요

 ## 📝 주요기능

 ## 🔨 기술스택 
<!-- 
(백엔드, 프론트, 협업에 사용한 툴, 라이브러리, 프레임워크)

기술스택 배지 추가하는 방법 
1. https://simpleicons.org/ 에서 기술스택명 검색
2. 기술스택의 로고, 컬러 HEX 코드를 아래와 같이 입력
  - https://img.shields.io/badge/<표시될 이름>-<컬러 HEX>?style=for-the-badge&logo=<로고명>
3. 해당 URL로 마크다운 이미지 첨부
  - ![이미지명](URL) 형식
-->

| 스택 | 설명 | 용도 |
|-----|-----|-----|
| 스택1 | 스택에 대한 설명 | 프로젝트 쓰임새 |
| ... | ... | ... |

 ## 🛠 설치방법

### 💻 Frontend

1. **환경 설정**

   ```bash
   cp .env.example .env
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

   `build_runner`는 `@riverpod` / `freezed` / `json_serializable`을 쓰는 feature 작업 시 필요합니다.

2. **로컬 API 연동**

   백엔드를 로컬에서 실행한 뒤, 테스트 유저를 발급해 `.env`에 넣습니다.

   ```http
   POST http://localhost:8080/api/dev/users/test
   ```

   응답의 `userId`를 `.env`의 `DEV_USER_ID`에 붙여 넣습니다.

3. **인증 모드 (`.env`의 `DEV_AUTH_MODE`)**

   | 값 | 용도 |
   |-----|------|
   | `x_user_id` | OAuth 전, `/api/v1/**` API만 먼저 연동할 때 |
   | `bearer` | 로그인 후 SecureStorage에 access token이 있을 때 |

   Android 에뮬레이터에서 `localhost`로 백엔드에 접속이 안 되면 `API_BASE_URL`을 `http://10.0.2.2:8080`으로 바꿉니다.

   화면별 API 호출은 `lib/features/**/services`에서 `apiClientProvider`와 `ApiEndpoints`를 사용합니다.

### 💻 Backend

 ## 🧑‍💻 팀원
| <img width="100" src="https://github.com/minseoriii.png"> | <img width="100" src="https://github.com/ymin431.png"> | <img width="100" src="https://github.com/stfifo.png"> | 
|:----------------------:|:----------------------:|:----------------------:|
| [김민서](https://github.com/minseoriii) | [이유민](https://github.com/ymin431) | [최지은](https://github.com/stfifo) |
| 💻 Android | 💻 Android | 💻 Android |
| 23기 | 21기 | 23기 |

 
