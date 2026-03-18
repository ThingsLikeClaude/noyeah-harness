# noyeah-harness

### Claude Code를 위한 자율 실행 엔진 (Autonomous Execution Engine)

> **한 줄 요약**: "todo 앱 만들어줘" 한마디면 AI가 자동으로 설계하고, 테스트를 먼저 작성하고,
> 코드를 구현하고, 아키텍트가 검증할 때까지 반복합니다.

noyeah-harness는 [Claude Code](https://claude.ai/claude-code) 위에서 동작하는 **자율 실행 엔진**입니다.
단순히 코드를 생성하는 것을 넘어, 기획 → 설계 → 구현 → 검증 → 학습의 전체 개발 사이클을
자동화합니다.

> No? Yeah. 시키면 끝까지 한다.

---

## 목차

- [noyeah-harness가 뭔가요?](#noyeah-harness가-뭔가요)
- [누구를 위한 도구인가요?](#누구를-위한-도구인가요)
- [설치 및 시작하기](#설치-및-시작하기)
- [첫 번째 사용: 3분 체험](#첫-번째-사용-3분-체험)
- [핵심 개념 이해하기](#핵심-개념-이해하기)
- [14개 스킬 완전 가이드](#14개-스킬-완전-가이드)
- [12개 에이전트 역할 설명](#12개-에이전트-역할-설명)
- [3단계 티어 시스템](#3단계-티어-시스템)
- [내장 개발 방법론 (TDD/DDD/SDD)](#내장-개발-방법론-tddddd-sdd)
- [상태 관리 시스템](#상태-관리-시스템)
- [프로젝트 메모리](#프로젝트-메모리)
- [추천 워크플로우](#추천-워크플로우)
- [문제가 생겼을 때 (실패 복구)](#문제가-생겼을-때-실패-복구)
- [에코모드 (비용 절약)](#에코모드-비용-절약)
- [Hook 시스템](#hook-시스템)
- [프로젝트 구조](#프로젝트-구조)
- [자주 묻는 질문](#자주-묻는-질문)
- [기여하기](#기여하기)

---

## noyeah-harness가 뭔가요?

일상적인 비유로 설명하면:

**공장에 비유하면**, noyeah-harness는 공장 운영 시스템입니다. 공장에는 기획자, 건축가, 품질검사관,
조립공, 디버거 등 전문 인력이 있습니다. 작업 지시를 내리면 기획자가 설계하고, 건축가가
검토하고, 조립공이 만들고, 품질검사관이 확인합니다. 문제가 있으면 자동으로 고쳐서 다시
검사합니다. 이 모든 과정이 자동으로 돌아갑니다.

**기술적으로 설명하면**, noyeah-harness는 Claude Code의 서브에이전트(Agent) 기능을 활용하여
다음을 추가합니다:

- **지속성 루프 (Persistence Loop)**: 작업이 완료될 때까지 자동으로 반복
- **합의 기반 계획 (Consensus Planning)**: 3명의 AI가 토론하며 최적의 계획 도출
- **티어 기반 에이전트 라우팅**: 작업 난이도에 맞는 AI 모델 자동 선택
- **파일 기반 상태 관리**: 모든 진행 상황을 JSON 파일로 추적
- **프로젝트 메모리**: 이전 작업에서 배운 교훈을 기억하고 적용
- **TDD/DDD 자동 적용**: 테스트 주도 개발과 도메인 주도 설계가 자동으로 실행
- **팀 조율**: 최대 6명의 에이전트가 병렬로 협업
- **시각적 QA**: 스크린샷 기반 디자인 검증

---

## 누구를 위한 도구인가요?

| 사용자 유형 | noyeah-harness가 도와주는 방법 |
|------------|-------------------------------|
| **코딩 초보자** | "todo 앱 만들어줘" 한마디로 전체 개발 사이클 자동 실행 |
| **주니어 개발자** | TDD/DDD 방법론이 자동 적용되어 좋은 습관 학습 |
| **시니어 개발자** | 반복 작업 자동화, 에이전트 체인 커스터마이징 |
| **팀 리더** | 병렬 에이전트 팀으로 대규모 작업 분할 실행 |

---

## 설치 및 시작하기

### 필요한 것

1. **Claude Code** 설치 완료 (터미널에서 `claude` 명령이 동작하면 OK)
2. **Git** 설치 완료

### macOS / Linux

```bash
git clone https://github.com/ThingsLikeClaude/noyeah-harness.git ~/noyeah-harness
cd ~/noyeah-harness && ./install.sh
```

### Windows

```powershell
git clone https://github.com/ThingsLikeClaude/noyeah-harness.git $env:USERPROFILE\noyeah-harness
cd $env:USERPROFILE\noyeah-harness; .\install.ps1
```

설치 후 Claude Code를 재시작하면 바로 사용 가능합니다.

> **Windows 참고**: Windows에서는 심볼릭 링크 대신 파일 복사를 사용합니다.
> 업데이트 시 `install.ps1`을 다시 실행해야 변경사항이 반영됩니다.

### 내 프로젝트에 하니스 적용하기

```
/noyeah-init ~/my-project
```

이 명령 하나로:
1. `.harness/` 디렉토리 구조 생성
2. 훅 스크립트 복사 (자동 학습 리마인더, 회고 체크, 보안 가드, 시크릿 필터)
3. Claude Code 설정에 훅 등록
4. 프로젝트의 `CLAUDE.md`에 하니스 참조 블록 추가

이미 초기화한 프로젝트에 다시 실행해도 안전합니다 (기존 데이터 보존).

---

## 첫 번째 사용: 3분 체험

### 가장 간단한 시작

프로젝트 폴더에서 Claude Code를 열고:

```
도와줘
```

또는:

```
help
```

하니스의 **Guided Routing Protocol**이 작동하여 "무엇을 하고 싶으세요?"라고 물어본 뒤,
가장 적절한 스킬을 추천합니다.

### 첫 번째 Ralph 체험

```
/noyeah-ralph "README.md 파일을 만들어줘. 프로젝트 설명, 설치 방법, 사용 예시 포함"
```

**Ralph가 하는 일:**
1. 프로젝트 코드를 탐색하여 구조 파악
2. 작업 분류 (이 경우: docs → TDD 스킵)
3. executor 에이전트가 README 작성
4. verifier 에이전트가 모든 요구사항 충족 확인
5. architect 에이전트가 품질 리뷰
6. 승인되면 완료 보고

### 첫 번째 Autopilot 체험

```
/noyeah-autopilot "간단한 todo CLI 앱 만들어줘"
```

**Autopilot이 하는 일:**
1. 요구사항 확인 (필요시 질문)
2. 3명의 AI가 토론하며 계획 수립 (Ralplan)
   - 도메인 모델 자동 생성 (Todo 엔티티, 비즈니스 규칙)
3. 테스트 먼저 작성 (TDD RED 페이즈)
4. 코드 구현 (TDD GREEN 페이즈)
5. QA 사이클링 (최대 5라운드)
6. 최종 검증 및 완료 보고

---

## 핵심 개념 이해하기

noyeah-harness를 이해하기 위해 알아야 할 7가지 개념:

### 1. 스킬 (Skill)

**스킬**은 `/noyeah-`로 시작하는 명령어입니다. 각 스킬은 특정 워크플로우를 정의합니다.

```
/noyeah-ralph "로그인 기능 구현해줘"    <- 이것이 스킬 호출
```

스킬은 `skills/` 폴더의 `SKILL.md` 파일에 정의되어 있습니다. Claude Code가 이 파일을
읽고 지시대로 행동합니다. 14개 스킬이 있습니다.

### 2. 에이전트 (Agent)

**에이전트**는 특정 역할을 가진 AI 어시스턴트입니다. 사람으로 치면 전문가입니다.

- **executor**: 코드를 실제로 작성하는 개발자
- **architect**: 코드를 검토하는 수석 아키텍트
- **planner**: 구현 계획을 세우는 기획자
- **test-engineer**: 테스트를 작성하는 QA 엔지니어

에이전트는 `agents/` 폴더의 `.md` 파일에 정의됩니다. 12개 에이전트가 있습니다.

### 3. 티어 (Tier)

**티어**는 에이전트의 능력 수준입니다. 작업 난이도에 따라 자동으로 선택됩니다.

| 티어 | AI 모델 | 비유 | 용도 |
|------|---------|------|------|
| LOW | haiku | 인턴 | 빠른 검색, 문서 작성 |
| STANDARD | sonnet | 시니어 개발자 | 구현, 테스트, 디버깅 |
| THOROUGH | opus | CTO | 아키텍처 설계, 보안 감사, 계획 수립 |

### 4. 상태 (State)

**상태**는 현재 진행 중인 작업의 스냅샷입니다. `.harness/state/` 폴더에 JSON 파일로 저장됩니다.

```json
{
  "active": true,
  "iteration": 3,
  "current_phase": "executing",
  "task": "로그인 기능 구현"
}
```

`/noyeah-status`로 언제든 현재 상태를 확인할 수 있습니다.

### 5. 계획 (Plan)

**계획**은 코드를 작성하기 전에 AI들이 토론하여 만든 구현 전략입니다.
`.harness/plans/` 폴더에 마크다운 파일로 저장됩니다.

계획에는 다음이 포함됩니다:
- 문제 정의
- 방법론 분류 (TDD 적용 여부, DDD 적용 여부)
- 도메인 모델 (해당 시)
- 3-6단계의 구현 스텝
- 리스크 평가
- 테스트 전략

### 6. 모드 (Mode)

**모드**는 현재 활성화된 워크플로우입니다. 여러 모드가 동시에 활성화될 수 있습니다.

예: Autopilot 모드 안에서 Ralph 모드가 실행되고, Ralph 안에서 Ultrawork가 병렬 작업을
처리할 수 있습니다.

### 7. 페이즈 (Phase)

**페이즈**는 모드 내에서의 진행 단계입니다.

```
Ralph: starting → executing → verifying → complete
                               ↘ fixing → executing (반복)
```

---

## 14개 스킬 완전 가이드

### 핵심 실행 스킬 (일상적으로 사용)

#### `/noyeah-ralph` — 지속성 루프 ("끝날 때까지 멈추지 마")

가장 많이 사용하는 스킬입니다. 작업이 완료되고 아키텍트가 승인할 때까지 자동으로
반복합니다. 최대 10회 반복.

```
/noyeah-ralph "사용자 프로필 페이지 구현해줘"
```

**작동 방식:**
1. 컨텍스트 스냅샷 생성
2. 방법론 결정 (TDD enforce? skip?)
3. 반복 실행: 구현 → 테스트 → 검증
4. 아키텍트 리뷰
5. 문제 있으면 자동 수정 후 재검증
6. 승인되면 완료

**언제 사용**: 명확한 작업이 있고, 완료까지 자동으로 돌리고 싶을 때

---

#### `/noyeah-autopilot` — 완전 자동 파이프라인 ("아이디어부터 코드까지 알아서 해줘")

아이디어 하나로 전체 개발 사이클을 자동 실행합니다.

```
/noyeah-autopilot "REST API로 사용자 관리 시스템 만들어줘"
```

**작동 방식:**
1. 요구사항 수집 (Deep Interview)
2. 합의 기반 계획 수립 (Ralplan: 3명의 AI가 토론)
3. TDD 기반 구현 (Ralph: 테스트 먼저 → 구현 → 검증)
4. QA 사이클링 (UltraQA: 최대 5라운드)
5. 다관점 검증 (3명의 리뷰어가 병렬 검토)
6. 정리 및 보고

**언제 사용**: 처음부터 끝까지 자동으로 돌리고 싶을 때, 큰 기능 개발

---

#### `/noyeah-ultrawork` — 병렬 작업 디스패치 ("이것들을 동시에 해줘")

독립적인 작업 여러 개를 동시에 실행합니다.

```
/noyeah-ultrawork "1. 타입 정의 추가 2. 인증 모듈 테스트 작성 3. API 문서 업데이트"
```

**작동 방식:**
- 각 작업을 적절한 에이전트에게 동시 배정
- 작업이 독립적이어야 함 (서로 의존하면 안 됨)
- 완료 후 통합 결과 보고

**언제 사용**: 서로 겹치지 않는 작업 2-6개를 빠르게 처리하고 싶을 때

---

### 계획 및 분석 스킬

#### `/noyeah-ralplan` — 합의 기반 계획 ("제대로 계획하고 시작하자")

3명의 AI 전문가가 순서대로 토론하여 계획을 수립합니다.

```
/noyeah-ralplan "캐싱 레이어를 Redis와 인메모리 둘 다 지원하도록 재설계"
```

**작동 방식:**
1. **Planner** (기획자): 도메인 모델 + 구현 계획 작성
2. **Architect** (건축가): "이 계획의 가장 큰 약점은?" 도전
3. **Critic** (비평가): "대안은 진짜인가? 리스크는 제대로 평가됐나?" 검증

3명 모두 승인해야 계획이 확정됩니다. 최대 3라운드 수정.

**언제 사용**: 3개 이상 파일을 수정하는 작업, 아키텍처 결정이 필요한 작업

---

#### `/noyeah-deep-interview` — 요구사항 탐색 ("뭐가 필요한지 같이 정리하자")

소크라테스식 질문으로 요구사항을 구체화합니다.

```
/noyeah-deep-interview "인증 시스템에 뭐가 필요할까?"
/noyeah-deep-interview --quick "검색 기능 요구사항 정리"
```

**작동 방식:**
- Quick 모드: 5개 질문으로 핵심 파악
- Full 모드: 15개 질문으로 상세 탐색
- 코드베이스를 먼저 탐색한 후 맞춤 질문

**언제 사용**: 요구사항이 모호할 때, 무엇을 만들어야 할지 명확하지 않을 때

---

### QA 및 검증 스킬

#### `/noyeah-ultraqa` — QA 사이클링 ("모든 테스트를 통과시켜")

테스트 → 진단 → 수정을 최대 5라운드 반복합니다.

```
/noyeah-ultraqa
```

**언제 사용**: 테스트가 실패하는데 원인을 모를 때, 전체 테스트 스위트를 통과시키고 싶을 때

---

#### `/noyeah-visual-verdict` — 시각적 QA ("디자인대로 만들어졌나 확인해줘")

스크린샷을 촬영하고 디자인 참조와 비교하여 점수를 매깁니다.

```
/noyeah-visual-verdict
```

**평가 항목**: 레이아웃, 타이포그래피, 색상, 컴포넌트, 반응성

**언제 사용**: UI가 디자인 시안과 일치하는지 확인할 때

---

### 팀 및 협업 스킬

#### `/noyeah-team` — 멀티 에이전트 팀 ("팀을 구성해서 같이 작업하자")

여러 에이전트가 팀으로 협업합니다. 리더가 조율하고 워커들이 병렬 실행합니다.

```
/noyeah-team 3:executor "인증, 결제, 알림 모듈 각각 구현"
```

**작동 방식:**
- 최대 6명의 워커 에이전트
- 리더 (Claude)가 작업 분배 및 통합 조율
- `team ralph`: 팀 실행 + Ralph 검증 연결 가능

**언제 사용**: 대규모 작업을 팀으로 분담하고 싶을 때

---

### 유틸리티 스킬

#### `/noyeah-ecomode` — 비용 절약 모드 ("토큰 아껴줘")

모든 에이전트의 티어를 한 단계씩 낮춥니다.

```
/noyeah-ecomode on
eco ralph "캐싱 레이어 구현"
```

**규칙:**
- THOROUGH → STANDARD, STANDARD → LOW
- **예외**: 보안 리뷰는 항상 THOROUGH (절대 다운그레이드 안 됨)
- TDD enforce 모드의 test-engineer는 최소 STANDARD 유지

**언제 사용**: 비용을 절약하고 싶을 때 (결과 품질이 약간 낮아질 수 있음)

---

#### `/noyeah-retro` — 회고 ("뭘 배웠지?")

완료된 작업에서 교훈을 추출하여 프로젝트 메모리에 저장합니다.

```
/noyeah-retro
```

**저장하는 것**: 결정 사항, 발견된 패턴, 실패에서 배운 교훈, 제약 조건

**언제 사용**: Ralph나 Autopilot이 완료된 후, 학습 내용을 기록하고 싶을 때

---

#### `/noyeah-init` — 프로젝트 초기화 ("이 프로젝트에 하니스 설치해줘")

대상 프로젝트에 noyeah-harness 런타임을 설치합니다.

```
/noyeah-init ~/my-project
```

**설치되는 것**: `.harness/` 디렉토리, 훅 스크립트, 설정 병합, CLAUDE.md 참조 블록

---

#### `/noyeah-cancel` — 중단 ("전부 멈춰")

활성 모드를 깨끗하게 종료합니다.

```
/noyeah-cancel           # 현재 활성 모드 종료
/noyeah-cancel --force   # 모든 상태 파일 초기화
```

---

#### `/noyeah-status` — 상태 대시보드 ("지금 뭐가 돌아가고 있어?")

모든 활성 모드의 진행 상황을 시각적으로 표시합니다.

```
/noyeah-status
```

**표시 내용:**
- 각 모드의 상태: `[ACTIVE]` / `[DONE]` / `[FAIL]` / `[OFF]`
- 프로그레스 바: `[=========>    ] 7/10 iterations`
- Autopilot 파이프라인 체크리스트
- 실패 시 복구 안내
- 프로젝트 메모리 요약

---

#### `/noyeah-resume` — 재개 ("중단된 곳에서 이어해줘")

세션이 중단된 후 마지막 저장된 상태에서 작업을 재개합니다.

```
/noyeah-resume
```

---

## 12개 에이전트 역할 설명

### 지휘관 그룹 (Frontier Orchestrator)

코드를 직접 작성하지 않습니다. 판단하고, 지시하고, 검증합니다.

| 에이전트 | 비유 | 역할 | 티어 |
|---------|------|------|------|
| **planner** | 프로젝트 매니저 | 구현 계획 수립, 도메인 모델링, 방법론 분류 | THOROUGH |
| **architect** | 수석 아키텍트 | 코드 리뷰, 설계 검증 (읽기 전용, 코드 수정 안 함) | THOROUGH |
| **critic** | 품질 감사관 | 계획의 약점 공격, ADR(Architecture Decision Record) 작성 | THOROUGH |
| **security-reviewer** | 보안 전문가 | OWASP Top 10 스캔, 비밀키 감지, 의존성 감사 (읽기 전용) | THOROUGH |

### 실행 그룹 (Deep Worker)

실제 코드를 작성하고, 테스트하고, 수정합니다.

| 에이전트 | 비유 | 역할 | 티어 |
|---------|------|------|------|
| **executor** | 시니어 개발자 | 계획에 따라 코드 구현, 최소한의 변경으로 요구사항 충족 | STANDARD |
| **verifier** | QA 리드 | 완료 증거 전문가, "정말 끝났는가?" 를 PASS/FAIL로 판단 | STANDARD |
| **debugger** | 디버깅 전문가 | 5단계 프로토콜: 재현 → 증거수집 → 가설 → 수정 → 검증 | STANDARD |
| **test-engineer** | TDD 전문가 | 실패 테스트 작성(RED), 테스트 프레임워크 설정, 도메인 인식 테스트 | STANDARD |
| **build-fixer** | 빌드 엔지니어 | 빌드 에러를 최소한의 변경으로 수정 | STANDARD |
| **integrator** | 통합 전문가 | 병렬 에이전트의 출력이 충돌할 때 병합 해결 | STANDARD |

### 속행 그룹 (Fast Lane)

빠른 작업, 간단한 조회, 문서 작성에 특화됩니다.

| 에이전트 | 비유 | 역할 | 티어 |
|---------|------|------|------|
| **explorer** | 정찰병 | 코드베이스에서 정보 빠르게 찾기, 2-5문장으로 보고 | LOW |
| **writer** | 기술 작가 | API 문서, README, 인라인 주석 작성 | LOW |

---

## 3단계 티어 시스템

### 자동 티어 선택

noyeah-harness는 작업 성격에 따라 자동으로 적절한 티어를 선택합니다:

```
사용자: "TODO 앱 만들어줘"

자동 결정:
  계획 수립  → THOROUGH (opus)  : planner, architect, critic
  코드 구현  → STANDARD (sonnet) : executor, test-engineer
  문서 작성  → LOW (haiku)       : writer
  최종 리뷰  → STANDARD+ (sonnet/opus) : architect
```

### 3가지 차원

**1. 티어 (Depth / Cost)**

| 티어 | 모델 | 용도 |
|------|------|------|
| **LOW** | haiku | 빠른 검색, 제한된 체크, 스타일 리뷰, 문서 작성 |
| **STANDARD** | sonnet | 구현, 디버깅, 테스트, 검증 |
| **THOROUGH** | opus | 아키텍처, 보안, 복잡한 다파일 분석, 계획 수립 |

**2. 포스처 (Operating Style)**

| 포스처 | 행동 | 역할 |
|--------|------|------|
| **frontier-orchestrator** | 위임하고, 검증하고, 판단 | planner, architect, critic |
| **deep-worker** | 직접 구현하고, 수정하고, 테스트 | executor, debugger, verifier |
| **fast-lane** | 빠른 분류, 간결한 출력 | explorer, writer |

**3. 역할 (Agent Identity)**

| 역할 | 기본 티어 | 포스처 | 파일 |
|------|----------|--------|------|
| executor | STANDARD | deep-worker | agents/executor.md |
| architect | THOROUGH | frontier-orchestrator | agents/architect.md |
| planner | THOROUGH | frontier-orchestrator | agents/planner.md |
| verifier | STANDARD | deep-worker | agents/verifier.md |
| debugger | STANDARD | deep-worker | agents/debugger.md |
| critic | THOROUGH | frontier-orchestrator | agents/critic.md |
| security-reviewer | THOROUGH | frontier-orchestrator | agents/security-reviewer.md |
| build-fixer | STANDARD | deep-worker | agents/build-fixer.md |
| test-engineer | STANDARD | deep-worker | agents/test-engineer.md |
| integrator | STANDARD | deep-worker | agents/integrator.md |
| explorer | LOW | fast-lane | agents/explorer.md |
| writer | LOW | fast-lane | agents/writer.md |

### 티어 선택 규칙

1. 대부분의 코드 변경: **STANDARD** 시작
2. 읽기 전용/비침투적 작업: **LOW**
3. 보안/인증, 아키텍처 결정, 10개+ 파일 변경: **THOROUGH**로 승격
4. Ralph 완료 검증: 최소 **STANDARD** architect 리뷰
5. 보안 리뷰: 에코모드와 무관하게 **항상 THOROUGH**

---

## 내장 개발 방법론 (TDD/DDD/SDD)

noyeah-harness에는 3가지 개발 방법론이 **자동으로** 내장되어 있습니다.
사용자가 명시적으로 요청하지 않아도 적절한 상황에서 자동 적용됩니다.

### TDD (Test-Driven Development) — 테스트 주도 개발

**"코드를 쓰기 전에 테스트를 먼저 써라"**

작동 방식:
1. **RED**: test-engineer가 실패하는 테스트 + 최소 스텁 파일 작성
2. **GREEN**: executor가 테스트를 통과시키는 코드 구현
3. **REFACTOR**: 테스트 통과 확인 후 리팩토링

**자동 분류:**
- 기능 개발, 버그 수정, 로직 변경 리팩토링 → `tdd_mode: enforce` (TDD 강제)
- 설정 변경, 문서 작업 → `tdd_mode: skip` (TDD 건너뜀)

**프로젝트에 테스트 프레임워크가 없으면?**
test-engineer가 적절한 프레임워크를 추천하고, executor가 설치합니다.
(Node.js: vitest 추천, Python: pytest 추천)

### DDD (Domain-Driven Design) — 도메인 주도 설계

**"코드 구조를 비즈니스 도메인에 맞춰라"**

작동 방식:
1. Planner가 작업을 분석하여 도메인 엔티티를 식별
2. 2개 이상의 도메인 개념이 있으면 자동으로 **Domain Model** 섹션 생성
3. 구현 스텝이 도메인 모델에 정렬

**Domain Model 예시 (자동 생성):**
```
## Domain Model

### Core Entities
- **Todo**: 할 일 항목 관리 (제목, 완료 여부, 우선순위)
- **Priority**: 우선순위 레벨 (높음/중간/낮음)

### Value Objects
- **DueDate**: 마감일 (불변, 유효성 검사 포함)

### Business Rules
- 완료된 Todo는 다시 미완료로 변경할 수 없다
- 마감일이 지난 Todo는 자동으로 "지연" 표시
```

**자동 분류:**
- 2개+ 도메인 엔티티 → `ddd_mode: applied` (DDD 적용)
- 단일 엔티티, 버그 수정, 설정 → `ddd_mode: skipped` (DDD 건너뜀)

### SDD (Subagent-Driven Development) — 에이전트 주도 개발

**"전문가들이 각자 역할을 수행하며 협업한다"**

이것은 noyeah-harness의 에이전트 체계 자체입니다. 별도 설정 없이 항상 동작합니다.

```
planner (기획) → architect (검토) → critic (검증) → executor (구현) → verifier (확인)
```

### 방법론 분류 흐름

```
사용자: "todo 앱 만들어줘"
  ↓
Planner 분석:
  - task_type: feature (새 기능)
  - 도메인 엔티티: Todo, Priority, DueDate (3개)
  ↓
자동 결정:
  - tdd_mode: enforce  (기능 개발이므로 TDD 강제)
  - ddd_mode: applied   (3개 엔티티이므로 DDD 적용)
  ↓
실행 순서:
  1. Domain Model 작성
  2. test-engineer: 실패 테스트 + 스텁 작성 (RED)
  3. executor: 테스트 통과 구현 (GREEN)
  4. 검증 + 아키텍트 리뷰
```

```
사용자: "README 업데이트해줘"
  ↓
자동 결정:
  - tdd_mode: skip      (문서 작업)
  - ddd_mode: skipped    (도메인 없음)
  ↓
실행 순서:
  1. executor: README 직접 작성
  2. 검증 + 아키텍트 리뷰
```

---

## 상태 관리 시스템

### `.harness/` 디렉토리 구조

```
.harness/
  state/                          # 모드 상태 파일 (자동 관리)
    ralph-state.json              # Ralph 루프 상태
    autopilot-state.json          # Autopilot 파이프라인 상태
    ralplan-state.json            # 계획 수립 상태
    ultraqa-state.json            # QA 사이클 상태
    ultrawork-state.json          # 병렬 작업 상태
    team-state.json               # 팀 조율 상태
    ecomode-state.json            # 에코모드 상태
    visual-verdicts.json          # 시각적 QA 점수

  context/                        # 작업 컨텍스트 스냅샷
    {slug}-{timestamp}.md         # 작업별 맥락 문서

  plans/                          # 승인된 계획
    plan-{slug}.md                # Ralplan으로 생성된 계획

  memory/                         # 세션 간 영속 메모리
    project-memory.json           # 결정, 패턴, 교훈

  templates/                      # 템플릿 파일
    project-memory-seed.json      # 메모리 초기 시드

  notepad/                        # 세션 메모장
    notes.md                      # 자유 형식 메모

  codebase-map/                   # 프로젝트 구조 개요
    map.md                        # 코드베이스 지도

  logs/                           # 실행 이력
    harness-YYYY-MM-DD.jsonl      # 타임스탬프 로그

  hooks/                          # 훅 스크립트
    retro-check.js                # Ralph 완료 후 회고 리마인더
    learning-remind.js            # 세션 시작 시 학습 리마인더

  sessions/                       # 세션 추적
```

### 페이즈 전환 (Phase Transitions)

각 모드는 정해진 페이즈 순서를 따릅니다. 이 순서는 **Frozen Contract** (변경 불가)입니다.

| 모드 | 페이즈 흐름 |
|------|------------|
| **Ralph** | `starting` → `executing` → `verifying` → `complete` / `failed` / `cancelled` |
| | `verifying` → `fixing` → `executing` (수정 루프) |
| **Autopilot** | `intake` → `planning` → `executing` → `qa` → `validation` → `complete` |
| **UltraQA** | `running_checks` → `diagnosing` → `fixing` → `complete` / `failed` |
| **Ralplan** | `planner_proposing` → `architect_reviewing` → `critic_validating` → `approved` / `revision` |

### Git에 저장되는 것 vs 안 되는 것

| 저장됨 (Git 추적) | 저장 안 됨 (gitignore) |
|-------------------|----------------------|
| `plans/` — 계획서 | `state/` — 실행 상태 |
| `memory/` — 교훈 | `logs/` — 실행 로그 |
| `codebase-map/` — 구조 개요 | `sessions/` — 세션 정보 |
| `hooks/` — 훅 스크립트 | `notepad/` — 임시 메모 |
| `context/` — 컨텍스트 | |
| `templates/` — 템플릿 | |

---

## 프로젝트 메모리

noyeah-harness는 이전 작업에서 배운 교훈을 기억하고 다음 작업에 자동 적용합니다.

### 메모리 타입

| 타입 | 저장하는 것 | 예시 |
|------|-----------|------|
| **decision** | 아키텍처/설계 결정 | "PostgreSQL을 MongoDB 대신 선택 — 관계형 무결성 필요" |
| **pattern** | 반복되는 코드 관행 | "모든 API 핸들러는 Zod → 서비스 → 응답 패턴을 따름" |
| **learning** | 실패에서 배운 교훈 | "DB 모킹이 마이그레이션 버그를 숨김 — 실제 DB 사용하기" |
| **constraint** | 알려진 제약 | "CI 파이프라인 타임아웃 10분" |
| **preference** | 사용자 선호 | "함수형 스타일 선호, 클래스 컴포넌트 X" |

### 학습 자동 주입

에이전트를 디스패치할 때, 관련 학습 항목이 자동으로 프롬프트에 주입됩니다.

```
## PAST LEARNINGS (auto-injected)
1. [confidence: 0.9, seen: 3x] DB 모킹이 마이그레이션 버그를 숨김
   When: 데이터베이스 관련 기능 테스트 시
   Do: 통합 테스트에서 실제 DB 연결 사용
```

### 메모리 시드 템플릿

새 프로젝트 초기화 시 (`/noyeah-init`) 예제 메모리 엔트리가 포함된 시드 파일이 생성됩니다.
각 예제는 `"type": "template"`으로 표시되어 실제 시스템에 영향을 주지 않습니다.
읽은 후 삭제하세요.

### 메모리 저장 시점

| 이벤트 | 저장하는 것 |
|--------|-----------|
| `/noyeah-ralplan` 완료 후 | 핵심 결정사항, ADR |
| `/noyeah-ralph` 반복 이슈 발생 | 배운 교훈 |
| 보안 리뷰 완료 후 | 발견된 패턴 |
| 사용자가 선호 표명 시 | 즉시 저장 |

---

## 추천 워크플로우

### "뭘 써야 할지 모르겠어"

```
도와줘
```
→ Guided Routing이 적절한 스킬을 추천합니다.

### 간단한 버그 수정

```
/noyeah-ralph "로그인 시 404 에러 수정"
```
→ 자동 분류: bugfix, tdd: enforce (회귀 테스트 작성)

### 새 기능 개발 (추천 기본 워크플로우)

```
/noyeah-ralplan "사용자 프로필 편집 기능 추가"
→ 계획 승인 후:
/noyeah-ralph "승인된 계획 실행"
```

### 처음부터 끝까지 자동

```
/noyeah-autopilot "REST API로 사용자 관리 시스템 구현"
```

### 여러 작업 동시에

```
/noyeah-ultrawork "1. 타입 export 추가 2. 인증 테스트 작성 3. API 문서 업데이트"
```

### 팀으로 대규모 작업

```
/noyeah-team 3:executor "인증, 결제, 알림 모듈 각각 구현"
```

### 비용 절약 모드

```
eco ralph "캐싱 레이어 구현"
```

### 피해야 할 패턴

| 하지 마세요 | 이유 | 대신 이렇게 |
|------------|------|------------|
| 오타 수정에 Ralph 사용 | 과도한 오버헤드 | 직접 수정 |
| 의존적인 작업에 Ultrawork | 레이스 컨디션 | Team 모드 또는 순차 실행 |
| 목표 없이 Autopilot | 범위 확장, 방향 상실 | Deep Interview 먼저 |
| 큰 기능에 Ralplan 건너뛰기 | 적대적 리뷰 없음 | 10+ 파일이면 항상 계획 먼저 |
| 보안 리뷰에 Ecomode | 보안은 최대 깊이 필요 | 보안은 항상 THOROUGH |

---

## 문제가 생겼을 때 (실패 복구)

### 빠른 해결 가이드

| 상황 | 해결 |
|------|------|
| 전부 멈춰 | `/noyeah-cancel` |
| 상태 파일 꼬임 | `/noyeah-cancel --force` |
| 세션 중단됨 | `/noyeah-resume` |
| 뭐가 돌고 있는지 모르겠음 | `/noyeah-status` |

### 상세 실패 모드

**Ralph가 10회 반복 후 실패:**
- 원인: 작업 범위가 너무 크거나, 테스트 인프라 부족, 순환 의존성
- 해결: `/noyeah-cancel` → 작업을 `/noyeah-ralplan`으로 더 작은 단위로 분할

**UltraQA가 5사이클 후 실패:**
- 원인: 불안정한 테스트, 환경 문제, 설계 결함
- 해결: 불안정 테스트 먼저 수정, 환경 점검

**아키텍트가 3회 이상 거부:**
- 원인: 기본 접근 방식이 잘못됨
- 해결: `/noyeah-deep-interview`로 요구사항 재확인 → `/noyeah-ralplan`으로 재설계

자세한 내용: [`docs/failure-recovery.md`](docs/failure-recovery.md)

---

## 에코모드 (비용 절약)

에코모드는 모든 에이전트의 티어를 한 단계 낮춥니다:

```
THOROUGH (opus) → STANDARD (sonnet)
STANDARD (sonnet) → LOW (haiku)
```

### 에코모드 예외 (절대 다운그레이드 안 됨)

| 항목 | 이유 |
|------|------|
| 보안 리뷰 | OWASP 스캔은 항상 최대 깊이 필요 |
| TDD enforce 모드의 test-engineer | 좋은 테스트 작성에는 STANDARD 이상 필요 |
| Integrator 병합 해결 | 병합 충돌은 정확성 필수 |
| Ralph 아키텍트 리뷰 | 최종 품질 게이트 |

### TDD와 에코모드 상호작용

- 에코모드는 `tdd_mode: enforce`를 `optional`로 다운그레이드 가능
- 하지만 `skip`으로는 절대 불가
- 보안 관련 TDD (인증, 암호화)는 에코모드와 무관하게 항상 `enforce`

---

## Hook 시스템

noyeah-harness는 4개의 자동 훅을 제공합니다:

### 1. retro-check (PostToolUse 이벤트)

Write/Edit 도구 사용 후 발동. Ralph가 완료되었는데 최근 5분 내 학습 기록이 없으면
`/noyeah-retro` 실행을 리마인드합니다.

### 2. learning-remind (SessionStart 이벤트)

세션 시작 시 발동. 프로젝트 메모리에 저장된 학습 항목 수를 알려줍니다.

### 3. remote-command-guard (PreToolUse 이벤트)

Bash 명령 실행 전 발동. 위험한 명령 (`rm -rf`, `git push --force` 등)을 감지하고
경고합니다.

### 4. secret-filter (PostToolUse 이벤트)

파일 작성/수정 후 발동. 시크릿 패턴 (API 키, 토큰 등)이 코드에 포함되었는지 검사합니다.

### 훅 철학

- **프롬프트 기반 로직** (핵심 루프): SKILL.md에 내장 (Ralph 반복, Autopilot 페이즈)
- **스크립트 기반 넛지** (관측성): 가벼운 리마인더 및 가드, 실행을 차단하지 않음

---

## 프로젝트 구조

```
noyeah-harness/
  CLAUDE.md                           # 오케스트레이션 브레인 (Claude가 읽는 핵심 파일)
  README.md                           # 이 파일 (사용 설명서)
  LICENSE                             # MIT 라이선스
  settings.json                       # 권한 및 훅 설정 템플릿
  mcp-servers.json                    # 추천 MCP 서버 설정
  install.sh                          # macOS/Linux 설치 스크립트
  install.ps1                         # Windows 설치 스크립트
  uninstall.sh                        # 제거 스크립트

  skills/                             # 14개 워크플로우 정의
    noyeah-ralph/SKILL.md             #   지속성 루프
    noyeah-autopilot/SKILL.md         #   완전 자동 파이프라인
    noyeah-ultrawork/SKILL.md         #   병렬 디스패치
    noyeah-ralplan/SKILL.md           #   합의 기반 계획
    noyeah-ecomode/SKILL.md           #   비용 절약 모드
    noyeah-ultraqa/SKILL.md           #   QA 사이클링
    noyeah-team/SKILL.md              #   팀 조율
    noyeah-deep-interview/SKILL.md    #   요구사항 탐색
    noyeah-visual-verdict/SKILL.md    #   시각적 QA
    noyeah-retro/SKILL.md             #   회고
    noyeah-init/SKILL.md              #   프로젝트 초기화
    noyeah-cancel/SKILL.md            #   중단
    noyeah-status/SKILL.md            #   상태 대시보드
    noyeah-resume/SKILL.md            #   재개

  agents/                             # 12개 에이전트 역할 정의
    executor.md                       #   구현 전문가
    architect.md                      #   아키텍처 리뷰어
    planner.md                        #   기획자 (방법론 분류 + DDD 포함)
    verifier.md                       #   완료 증거 전문가
    debugger.md                       #   루트 코즈 분석가
    critic.md                         #   적대적 리뷰어
    security-reviewer.md              #   보안 감사관
    build-fixer.md                    #   빌드 수리공
    test-engineer.md                  #   TDD 전문가 (스텁 + 도메인 인식)
    writer.md                         #   기술 문서가
    explorer.md                       #   코드베이스 정찰병
    integrator.md                     #   병합 전문가

  hooks/                              # 훅 스크립트
    retro-check.js                    #   회고 리마인더
    learning-remind.js                #   학습 리마인더
    remote-command-guard.js           #   위험 명령 가드
    secret-filter.js                  #   시크릿 감지 필터
    settings-template.json            #   훅 설정 템플릿

  rules/                              # 자동 로드 규칙 (7개)
    completion-contract.md            #   완료 계약 규칙
    context-intake.md                 #   컨텍스트 수집 규칙
    delegation-rules.md               #   에이전트 위임 규칙
    keyword-detection.md              #   키워드 감지 규칙
    memory-protocol.md                #   메모리 프로토콜
    state-management.md               #   상태 관리 규칙
    tier-system.md                    #   티어 시스템 규칙

  setup/                              # 설정 유틸리티
    project-memory-seed.json          #   메모리 초기 시드 템플릿
    settings.local.template.json      #   로컬 설정 템플릿

  docs/                               # 14개 문서 + 4개 계약
    tutorial.md                       #   초보자 튜토리얼
    failure-recovery.md               #   실패 복구 가이드
    quickstart.md                     #   30초 빠른 시작
    workflows.md                      #   추천 워크플로우
    architecture.md                   #   아키텍처 설계
    agent-tiers.md                    #   티어 시스템
    session-management.md             #   세션 관리
    overlay-system.md                 #   런타임 컨텍스트
    hook-system.md                    #   훅 시스템
    project-memory.md                 #   프로젝트 메모리
    notepad.md                        #   세션 메모장
    codebase-map.md                   #   코드베이스 지도
    learning-injection.md             #   학습 자동 주입
    contracts/
      ralph-state-contract.md         #   Ralph 상태 스키마 (frozen)
      cancel-contract.md              #   취소 프로토콜 (frozen)
      core-contracts.md               #   5개 핵심 에이전트 I/O 계약
      dispatch-templates.md           #   6개 비핵심 에이전트 디스패치 템플릿

  .harness/                           # 런타임 디렉토리 (위 "상태 관리 시스템" 참조)
```

---

## 자주 묻는 질문

### Q: Claude Code 없이 사용할 수 있나요?

**아니요.** noyeah-harness는 Claude Code의 Agent 도구를 사용하여 서브에이전트를 디스패치합니다.
Claude Code 없이는 동작하지 않습니다.

### Q: 비용이 얼마나 드나요?

Claude Code 사용 비용만 들어갑니다. noyeah-harness 자체는 무료입니다.
에코모드 (`/noyeah-ecomode`)를 사용하면 비용을 약 40-60% 절약할 수 있습니다.

### Q: 어떤 프로그래밍 언어를 지원하나요?

Claude Code가 지원하는 모든 언어를 지원합니다. 특별히 제한은 없습니다.
TDD 자동 부트스트랩은 현재 Node.js(vitest/jest)와 Python(pytest)에 최적화되어 있습니다.

### Q: 기존 프로젝트에 사용해도 안전한가요?

**네.** `/noyeah-init`은 `.harness/` 디렉토리만 생성하고, 기존 코드를 수정하지 않습니다.
CLAUDE.md에 참조 블록을 추가하지만, 이것도 마커로 관리되어 안전합니다.

### Q: 여러 사람이 같은 프로젝트에서 사용할 수 있나요?

**네.** `.harness/plans/`, `.harness/memory/`, `.harness/codebase-map/`은 Git에 추적되어
팀원 간 공유됩니다. 상태 파일(`state/`, `logs/`)은 gitignore 처리됩니다.

### Q: Ralph가 무한 루프에 빠지면?

최대 10회 반복으로 제한됩니다. 10회 후에도 완료되지 않으면 자동으로 `failed` 상태로
전환됩니다. `/noyeah-cancel`로 정리 후 작업을 분할하세요.

### Q: Autopilot과 Ralph의 차이는?

- **Ralph**: "이 작업을 끝날 때까지 해줘" (실행 + 검증 루프)
- **Autopilot**: "아이디어부터 코드까지 전부 알아서 해줘" (기획 + 실행 + QA + 검증)

Autopilot은 내부적으로 Ralph를 사용합니다.

### Q: 커스텀 에이전트를 추가할 수 있나요?

**네.** `agents/` 폴더에 새 `.md` 파일을 만들고, CLAUDE.md의 에이전트 테이블에
추가하면 됩니다.

### Q: CC Harness와의 차이는?

noyeah-harness는 CC Harness의 리브랜딩 버전입니다. 핵심 기능은 동일하며,
스킬 접두사가 `/h-` 에서 `/noyeah-`로 변경되었습니다.

| | noyeah-harness | CC Harness |
|---|---|---|
| 스킬 접두사 | `/noyeah-` | `/h-` |
| 브랜딩 | No? Yeah. | CC Harness |
| 기능 | 동일 | 동일 |

---

## 업데이트

```bash
cd ~/noyeah-harness && git pull
```

Windows의 경우 `install.ps1`을 다시 실행합니다:

```powershell
cd $env:USERPROFILE\noyeah-harness; .\install.ps1
```

---

## 기여하기

noyeah-harness는 MIT 라이선스로 공개되어 있습니다.

### 기여 방법

1. 이 저장소를 Fork
2. 기능 브랜치 생성 (`git checkout -b feat/my-feature`)
3. `/noyeah-ralplan`으로 계획 수립 (3+ 파일 변경 시)
4. `/noyeah-ralph`로 구현 + 검증
5. Pull Request 생성

### 프로젝트 통계

- **14** 스킬 (워크플로우 정의)
- **12** 에이전트 (역할 프롬프트)
- **7** 자동 로드 규칙
- **4** 훅 스크립트 (가드 + 관측성)
- **14** 문서 + **4** 계약서
- **~7,000줄** 문서 및 프롬프트

---

## 라이선스

MIT License. See [LICENSE](LICENSE) for details.

---

> **시작이 어렵다면**: `도와줘` 또는 `help`을 입력하세요.
> 하니스가 당신에게 맞는 다음 단계를 안내해 드립니다.
