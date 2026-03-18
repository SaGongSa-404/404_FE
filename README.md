(프로젝트명)
## RotationHouse
RotationHouse는 404호 팀의 React Native Expo 기반 모바일 앱 프로젝트입니다. 집안일 관리 및 공유를 위한 협업 앱입니다.

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

![intellij](https://img.shields.io/badge/intellij_idea-000000?style=for-the-badge&logo=intellijidea&logoColor=white)
![vscode](https://img.shields.io/badge/vscode-000000?style=for-the-badge&logo=vscode&logoColor=white)
![androidstudio](https://img.shields.io/badge/android_studio-3DDC84?style=for-the-badge&logo=androidstudio&logoColor=white)  

![docker](https://img.shields.io/badge/docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![nginx](https://img.shields.io/badge/nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)
![redis](https://img.shields.io/badge/redis-FF4438?style=for-the-badge&logo=redis&logoColor=white)
![github-action](https://img.shields.io/badge/github_actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)

![react](https://img.shields.io/badge/react_native-61DAFB?style=for-the-badge&logo=react&logoColor=white)
![jetpack-compose](https://img.shields.io/badge/jetpack_compose-4285F4?style=for-the-badge&logo=jetpackcompose&logoColor=white)
![spring](https://img.shields.io/badge/spring-6DB33F?style=for-the-badge&logo=spring&logoColor=white)

| 스택 | 설명 | 용도 |
|-----|-----|-----|
| 스택1 | 스택에 대한 설명 | 프로젝트 쓰임새 |
| ... | ... | ... |

## 🖼️ 스크린샷

## 🤝 개발협업
### 🌲 Branch 전략
- **main**: 배포/안정 브랜치
- **develop**: 개발 통합 브랜치
- **feat/기능명**: 개인 작업 브랜치 (예: feat/12-login-ui, feat/13-task-create)

브랜치 생성 및 작업 흐름:
1. develop 브랜치에서 개인 브랜치를 따기
2. 작업 완료 후 PR 올리기
3. 리뷰 후 develop에 머지

### 🍪 Pull Request
PR 제목: feat: [기능명] (#이슈번호)
예: feat: 로그인 UI 구현 (#12)

### 📝 커밋 메시지 규칙
- feat: 새로운 기능 추가
- fix: 버그 수정
- docs: 문서 수정
- style: 코드 스타일 변경
- refactor: 코드 리팩토링
- test: 테스트 추가
- chore: 기타 변경

예: feat: 로그인 UI 구현 (#12)

## 🛠 설치방법
### 💻 Frontend (React Native Expo)
1. Node.js 설치 (버전 18 이상 권장)
2. npm 또는 yarn 설치
3. 프로젝트 클론 후 디렉토리 이동
4. `npm install` 실행
5. `npx expo start`로 개발 서버 시작
6. 모바일 기기에 Expo Go 앱 설치 후 QR 코드 스캔하여 테스트

### 💻 Backend

## 🧑‍💻 팀원 (404호)
| <img width="100" src="https://github.com/cotidie.png"> | <img width="100" src="https://github.com/github.png"> | 
|:----------------------:|:----------------------:|
| [장원석](https://github.com/cotidie) | [팀원](https://github.com/cotidie) |
| 💻 Android | 💻 역할 |
| 15기 | 기수 |

## 📁 파일 구조
```
app/
  _layout.tsx                 // 전체 앱 공통 레이아웃
  index.tsx                   // 첫 진입 분기 (splash or login)
  
  auth/
    login.tsx
    create-or-join.tsx

  home/
    create-home.tsx
    join-home.tsx
    select-layout.tsx
    custom-layout.tsx
    cleanliness-standard.tsx
    voting-waiting.tsx

  chore/
    add.tsx
    detail.tsx
    substitute-request.tsx

  (tabs)/
    _layout.tsx               // 하단 탭 레이아웃
    schedule.tsx
    space.tsx
    notifications.tsx
    settings.tsx

components/
  ui/
    PrimaryButton.tsx
    AppInput.tsx
    AppCard.tsx
    TagChip.tsx
    SectionHeader.tsx

  chore/
    DateRangePicker.tsx
    FrequencyModal.tsx
    SpaceSelector.tsx
    ChoreCard.tsx

  feedback/
    SatisfactionSelector.tsx
    WeeklyReportCard.tsx

state/
  auth-store.ts
  home-store.ts
  chore-store.ts
  notification-store.ts

types/
  auth.ts
  chore.ts
  home.ts
  notification.ts
  common.ts

constants/
  theme.ts
  colors.ts
  spacing.ts
  text.ts

assets/
  images/
  icons/

hooks/
  useAuth.ts
  useChoreForm.ts
  useColorScheme.ts
```
(개요, 프로젝트 소개)

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

(백엔드, 프론트, 협업에 사용한 툴, 라이브러리, 프레임워크)

![intellij](https://img.shields.io/badge/intellij_idea-000000?style=for-the-badge&logo=intellijidea&logoColor=white)
![vscode](https://img.shields.io/badge/vscode-000000?style=for-the-badge&logo=vscode&logoColor=white)
![androidstudio](https://img.shields.io/badge/android_studio-3DDC84?style=for-the-badge&logo=androidstudio&logoColor=white)  

![docker](https://img.shields.io/badge/docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![nginx](https://img.shields.io/badge/nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)
![redis](https://img.shields.io/badge/redis-FF4438?style=for-the-badge&logo=redis&logoColor=white)
![github-action](https://img.shields.io/badge/github_actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)

![react](https://img.shields.io/badge/react-61DAFB?style=for-the-badge&logo=react&logoColor=white)
![jetpack-compose](https://img.shields.io/badge/jetpack_compose-4285F4?style=for-the-badge&logo=jetpackcompose&logoColor=white)
![spring](https://img.shields.io/badge/spring-6DB33F?style=for-the-badge&logo=spring&logoColor=white)

| 스택 | 설명 | 용도 |
|-----|-----|-----|
| 스택1 | 스택에 대한 설명 | 프로젝트 쓰임새 |
| ... | ... | ... |

 ## 🖼️ 스크린샷

 ## 🤝 개발협업
 ### 🌲 Branch 
```
main ------- backend/<이름>/(<이슈번호>-)<작업명>    (백엔드 작업)
     \------ frontend/<이름>/(<이슈번호>-)<작업명>   (프론트 작업)

ex) backend/wonseok/#10-add-animation
ex) frontend/wonseok/fix-login-not-allowed   (이슈가 없으면)
```
브랜치 관리 전략은 `main`과 개인 브랜치만이 존재하는 간단한 Github Flow를 따릅니다.
- `main` 브랜치는 항상 작동 가능한 안정된 상태여야 한다.
  - 직접 커밋하지 않으며, Pull Request만으로 변경한다.
- 개인 브랜치에서 작업을 진행한다.
- 브랜치명은 작업 내용과 직군이 구체적으로 드러나도록 한다.
  - 브랜치명에 `backend`, `frontend`를 구분한다.
  - 띄어쓰기는 하이픈(`-`)으로 구분한다.
  - 브랜치명은 전부 소문자를 사용한다.

프로젝트에 CI/CD를 구성하는 등 규모가 커지면 `develop` 브랜치를 추가하거나 `git flow`로 전환할 수 있습니다. 

 ### 🍪 Pull Request
```
main    ---●---●---●---------● abc (Squash Merge)
                \           /
개인브랜치          a---b---c   ('abc' 합쳐진 하나의 커밋으로 병합)

PR 제목: [Backend/Frontend] <이슈번호> <작업명>
ex) [Backend] #10 프로필 화면에서 로그인 불가하던 문제 해결
ex) [Backend] 프로필 화면에서 로그인 불가하던 문제 해결     (이슈가 없으면)
```
`main` 브랜치의 커밋은 Pull Request 단위로 쌓으며 이를 위해 **Squash Merge**를 원칙으로 합니다. **Squash Merge**는 브랜치가 병합될 때 커밋들이 PR 제목으로 합쳐지게 됩니다. 커밋은 개인마다 기준이 조금씩 다른 반면, PR/브랜치는 이슈 단위로 생성하므로 일관된 기준으로 커밋을 쌓을 수 있어 히스토리 추적을 용이하게 합니다.
- 커밋 제목은 **PR 제목**으로 한다.
    - Backend/Frontend를 구분한다.
    - 작업 내용을 구체적으로 드러나게 적는다.
- 커밋 내용은 **PR 내용**으로 한다.
    - 브랜치에서의 변경점을 상세히 적는다.
- Pull Request는 작은 작업 단위(200줄 이내 권장)로 한다.

 ## 🛠 설치방법
(다른 개발자가 이 프로젝트를 테스트해볼 수 있도록 프론트, 백엔드 설치/실행 절차 안내)

### 💻 Frontend

### 💻 Backend

 ## 🧑‍💻 팀원
| <img width="100" src="https://github.com/cotidie.png"> | <img width="100" src="https://github.com/github.png"> | 
|:----------------------:|:----------------------:|
| [장원석](https://github.com/cotidie) | [팀원](https://github.com/cotidie) |
| 💻 Android | 💻 역할 |
| 15기 | 기수 |

 
