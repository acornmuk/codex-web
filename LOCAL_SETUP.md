# 로컬 실행 환경

이 프로젝트는 Docker 컨테이너 안의 `/workspace/codex-web`에 구성되어 있다.

## 현재 구성

- Node.js: 프로젝트 내부 `.tools/node-v24.20.0-linux-x64`
- Codex CLI: `/root/.local/bin/codex`
- 기본 바인딩: `0.0.0.0:8214`
- 현재 컨테이너 IP: `172.18.0.2`

## 관리 명령

```bash
cd /workspace/codex-web
./scripts/codex-web-local.sh start
./scripts/codex-web-local.sh status
./scripts/codex-web-local.sh logs
./scripts/codex-web-local.sh stop
```

웹의 프로젝트 폴더 선택기는 기본적으로 Docker 컨테이너의 `/workspace`만
탐색한다. 호스트 폴더를 사용하려면 먼저 해당 폴더를 컨테이너의
`/workspace/<project-name>` 아래로 마운트해야 한다. 다른 컨테이너 경로를
사용할 때는 서버 시작 전에 `CODEX_WEB_WORKSPACE_ROOT`로 지정할 수 있다.

소스 또는 UI 버전을 다시 준비하려면 다음 명령을 실행한다.

```bash
cd /workspace/codex-web
./scripts/setup-local.sh
```

## Docker 호스트 브라우저에서 열기

서버는 Docker 호스트 연결을 받을 수 있도록 컨테이너 인터페이스의 8214번
포트에 바인딩한다. Linux Docker 호스트에서는 다음 주소로 직접 연결할 수 있다.

<http://172.18.0.2:8214>

컨테이너 IP는 재생성 시 바뀔 수 있다. 고정된 `http://127.0.0.1:8214` 주소를
사용하려면 컨테이너 실행 옵션에 `-p 127.0.0.1:8214:8214`를 추가한다. 현재
컨테이너는 포트 매핑 없이 생성됐고 Docker 소켓도 연결되지 않아, 실행 중인
컨테이너 내부에서 이 호스트 설정을 추가할 수는 없다.

`codex-web` 자체에는 로그인/접근 제어가 없다. 호스트 포트 매핑은 반드시
`127.0.0.1`로 제한하고, 인터넷이나 신뢰할 수 없는 LAN에 직접 공개하면 안 된다.

## 알려진 설치 경고

2026-09-01 기준 lockfile 그대로 `npm audit --omit=dev`를 실행하면 high 11건이
보고된다. upstream 의존성 범위를 임의로 변경하지 않기 위해 자동 수정은
적용하지 않았다. 호스트 포트 매핑을 로컬 루프백으로 제한해야 하는 이유 중 하나다.

## Web Pet

Electron의 별도 투명 창 대신 현재 Codex 웹페이지 우측 하단에 Pet 전용 iframe을
표시하도록 로컬 패치를 적용했다. `Settings > Personalization > Pets`에서 Pet을
선택하고 `Wake Pet`을 누르면 표시되며 `Tuck Away Pet` 또는 Pet의 닫기 버튼으로
숨길 수 있다.

Pet은 브라우저 탭 내부에만 표시된다. 데스크톱의 다른 프로그램 위에 항상 떠 있는
Electron 방식은 지원하지 않으며, 현재 위치는 우측 하단으로 고정된다.
