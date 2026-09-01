# 0xcaff/codex-web 실행 환경 구성 상태

## 목적

공식 Codex 데스크톱 UI에 가까운 `0xcaff/codex-web`을 현재 Docker 컨테이너에서 실행할 수 있도록 소스, Node 도구체인, 의존성, 빌드 산출물과 관리 스크립트를 준비한다.

## 대상

- 경로: `/workspace/codex-web`
- upstream: `https://github.com/0xcaff/codex-web`
- 고정 커밋: `8cc728dc11a5745ef8afa0c8d60fb6fcb064b77e`

## 작업 계획

1. [x] 기존에 구성한 Codex Web 서버 프로세스 종료
2. [x] upstream 저장소 clone 및 커밋 고정
3. [x] 다운로드·prepare·빌드 스크립트의 실행 범위와 공급망 경계 검토
4. [x] 프로젝트 전용 Node/npm 런타임 구성
5. [x] lockfile 기반 의존성 설치 및 npm audit
6. [x] 공식 Codex UI 자산 준비와 서버·브라우저 번들 빌드
7. [x] 격리된 listener에서 정적 화면과 IPC bridge smoke test
8. [x] 인증 없는 외부 노출을 막는 루프백 전용 관리 방식 적용
9. [x] 시작·중지·상태 명령과 Docker 접속 조건 문서화

## 안전 경계

- 기존 `codex-remote`, `codex-update-watchdog` tmux 세션과 공용 app-server daemon을 종료하지 않는다.
- upstream prepare 스크립트가 내려받는 URL·아카이브·실행 파일을 확인하기 전에는 실행하지 않는다.
- `codex-web`에는 자체 인증이 없으므로 검토 중에는 외부 인터페이스에 바인딩하지 않는다.
- 실제 인증 정보, `~/.codex` 내용, 토큰 및 capability URL을 로그나 상태 문서에 기록하지 않는다.

## 완료 결과

- 기존 Codex Web listener: 모두 종료
- 새 서버: `0.0.0.0:8214`에서 실행 중
- Node.js: 프로젝트 내부 Node 24.20.0
- UI 자산: 버전 `26.707.30751`, 저장소에 고정된 SHA-256 일치 확인
- 빌드: browser/server 성공, `better-sqlite3` rebuild 성공
- smoke test: `/` HTTP 200, UI root 및 preload 번들 확인
- 관리: `scripts/codex-web-local.sh`의 start/stop/restart/status/logs 사용
- Docker 연결: 컨테이너 IP `172.18.0.2:8214`에서 응답 확인. 호스트 포트 매핑은 현재 컨테이너에 없음
- 다운로드 캐시: 사용자 요청에 따라 `.cache` 삭제 완료

## 남은 판단 사항

- `npm audit --omit=dev`: high 11건. upstream lockfile을 보존하기 위해 자동 수정하지 않음
- Linux Docker 호스트에서는 `http://172.18.0.2:8214`로 직접 접속 가능
- 고정 주소가 필요하면 컨테이너 재생성 시 `-p 127.0.0.1:8214:8214` 적용 필요

## Web Pet 추가

- [x] Electron `BrowserWindow` 기반 `/avatar-overlay` 실행 경로 확인
- [x] Pet 전용 라우트를 같은 페이지의 투명 iframe으로 연결
- [x] 열기·닫기·현재 상태 IPC를 브라우저 로컬 상태로 처리
- [x] browser/server 빌드 성공
- [x] DOM 열기·닫기 및 `/avatar-overlay` 라우팅 격리 테스트 성공
- [ ] 실제 화면 최종 확인: 컨테이너에 Chromium 시스템 라이브러리가 없어 사용자 브라우저에서 확인 필요

## Docker 프로젝트 폴더 선택기

- [x] `Projects > Edit project > Sources > Add folder` 메시지를 웹 폴더 선택기로 연결
- [x] 기존 프로젝트 편집 모달 뒤에 가려지지 않도록 선택기를 최상위 레이어로 분리
- [x] 탐색 시작점과 허용 범위를 Docker 컨테이너의 `/workspace`로 제한
- [x] 선택 결과를 컨테이너 경로로 Electron 호환 프로젝트 등록 처리에 전달
- [ ] 사용자 브라우저에서 강력 새로고침 후 실제 클릭·폴더 추가 확인
