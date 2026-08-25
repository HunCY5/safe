# Safe - iOS App
> 온디바이스 AI 카메라 기반 현장 근로자 안전관리 iOS 앱

 
<a href="https://apps.apple.com/kr/app/id6759786625">
    <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="App Store에서 다운로드" height="40" />
  </a>

<img width="1720" height="1080" alt="세잎썸네일" src="https://github.com/user-attachments/assets/316a0dbb-ff13-4ead-a087-e032cfc3e4dc" />




### 📱 프로젝트 소개

**세잎(Safe)** 은 카메라를 통해 현장 근로자의 **안전장비 착용 여부와 작업 자세를 실시간으로 분석**하는 안전관리 iOS 앱입니다.

온디바이스 AI(YOLO & MoveNet)를 활용하여 카메라 프레임을 서버로 전송하지 않고 기기 내부에서 보호구 탐지와 자세 추정을 수행합니다.


---


### ✨ 주요 기능

- **보호구 착용 여부 탐지** - 카메라를 비추면 안전모·안전조끼 착용 여부가 화면에 바로 표시됩니다.
  > `YOLOv11n` 온디바이스 탐지
- **작업 자세 평가** - 작업 중인 자세의 위험도가 등급으로 표시됩니다. 
  > `MoveNet` 관절 추정 + RULA·REBA·OWAS 기반 평가
- **위험 상황 기록** - 미착용·위험 자세가 이어지면 위험 로그가 자동으로 남습니다. 
  > `Firestore`·`Storage` 기록
- **실시간 통합 카메라** - 착용 여부와 자세 평가가 같은 화면에 함께 표시됩니다. 
  > 단일 프레임 스트림 처리
        

> 현재 App Store에 출시된 버전은 **데모 버전**으로, 카메라 기반 탐지 및 평가 기능을 중심으로 동작합니다.

---

### 🖥️ 화면 구성

<table align="center" width="100%">
  <tr>
    <td width="33.33%"><img src="https://github.com/user-attachments/assets/39b0297c-4d67-417c-ae72-75b4d9e5589d" width="100%" alt="홈 화면"></td>
    <td width="33.33%"><img src="https://github.com/user-attachments/assets/fecd34be-7c2c-4cb2-ada3-9e868a424d02" width="100%" alt="탐지 카메라"></td>
    <td width="33.33%"><img src="https://github.com/user-attachments/assets/5fb9ba3d-898e-4adb-921b-094e36af75c0" width="100%" alt="위험 로그 화면"></td>
  </tr>
</table>

---

### 🏗️ 시스템 아키텍처

<img width="2578" height="1998" alt="세잎_시스템아키텍처" src="https://github.com/user-attachments/assets/6e9c2505-03f3-46e6-b443-7c4ac40c480c" />


---

### ⚒️ 기술 스택

| 분류 | 기술 |
|------|------|
| **Language** | Swift 5 |
| **UI Framework** | UIKit (Programmatic UI) |
| **Architecture** | MVC |
| **Concurrency** | GCD (Grand Central Dispatch) |
| **Media & Vision** | AVFoundation, Vision |
| **On-Device AI** | Core ML (YOLOv11n), LiteRT / TensorFlow Lite (MoveNet) |
| **Backend** | Firebase (Auth, Firestore, Storage) |
| **Libraries** | SnapKit, Kingfisher |
| **Project & Dependency** | Tuist 4.45.1, CocoaPods |
| **CI/CD** | Xcode Cloud |

---

### 🗂️ 프로젝트 구조

```
safe/                          # 레포 루트 (Tuist 프로젝트)
├── Project.swift              # Tuist 프로젝트 설정
├── Podfile                    # CocoaPods 의존성 설정
├── Tuist/                     # Tuist 설정 및 의존성 정의
├── ci_scripts/                # Xcode Cloud post-clone 스크립트
│
└── safe/                      # 앱 타겟
    ├── Sources/
    │   ├── Camera/            # AVFoundation 기반 카메라 프레임 수집
    │   ├── ML/                # 온디바이스 AI · 자세 평가 엔진 (RULA · REBA · OWAS)
    │   ├── Model/             # 데이터 모델 · 보호구 탐지 · 위험 로그 저장
    │   ├── View/              # 커스텀 UI 컴포넌트 · 탐지 결과 오버레이
    │   └── ViewController/    # 화면 제어 - 로그인 / 안전감시 / 위험로그 / 근로자 / 프로필
    │
    └── Resources/             # 이미지 리소스 · YOLOv11n CoreML 모델(.mlpackage)
```


---

## 🔍 문제 해결

### 1. 실시간 탐지 화면에서 자세추정과 보호구 탐지가 카메라 세션과 좌표계를 따로 쓰던 문제, 단일 프레임 스트림 통합으로 해결

<img width="720" alt="탐지 파이프라인" src="https://github.com/user-attachments/assets/745a06e7-2ead-468d-82fa-5521cf812083"/> <br>

**📍 제약 상황**

- 자세추정 화면과 보호구 탐지 화면이 각각 카메라 캡처와 프리뷰를 따로 보유 → 한 화면에 올리자 프리뷰가 이중 구성
- 보호구 박스는 `AVCaptureVideoPreviewLayer` 좌표, 스켈레톤은 `UIImageView` 좌표로 계산 → **같은 장면을 두 좌표계 위에서 따로 해석**

**⚖️ 선택한 구조와 이유**

두 화면을 그대로 두고 결과만 합치면 카메라 세션이 두 벌로 남고, 한쪽 좌표계에 맞춰 다른 쪽을 변환하면 변환 지점이 화면마다 흩어집니다. 어느 쪽이든 같은 장면을 두 번 따로 해석한다는 점은 그대로였습니다. **프레임과 좌표계의 출처를 하나로 두기로 했습니다.**

**✅ 결과**

- 카메라 매니저 하나가 내보내는 `pixelBuffer`를 자세추정기와 보호구 탐지기가 함께 소비 — 세션·프리뷰 이중 구성 제거
- 보호구 오버레이를 스켈레톤과 같은 `OverlayView` 프레임에 고정하고 좌표 변환 경로를 한 함수로 통합 — 두 결과가 같은 사람을 가리킴
- `aspect-fill` 스케일 계산이 한 곳으로 모여 화면마다 다시 계산되지 않음
- Vision 입력 스케일 옵션을 `.centerCrop`으로 바꿔 화면 표시와 입력 크롭이 일치

<details>
<summary>근거</summary>

- 코드 — [`PPEDetectionOverlayView.swift:56-94`](https://github.com/HunCY5/safe/blob/9fff0b70b428ea3d581c00e9d2ab97568f9d6874/safe/Sources/View/PPEDetectionOverlayView.swift#L56-L94) · [`CGSize+TFLite.swift:42-59`](https://github.com/HunCY5/safe/blob/9fff0b70b428ea3d581c00e9d2ab97568f9d6874/safe/Sources/ML/Extensions/CGSize%2BTFLite.swift#L42-L59) · [`RiskDetectionViewController.swift:706-734`](https://github.com/HunCY5/safe/blob/44dd87af257b774bb1e903f9fd49b6b70212430e/safe/Sources/ViewController/SafetyManager/RiskDetectionViewController%20.swift#L706-L734)
- 커밋 — [`bd0dcf2`](https://github.com/HunCY5/safe/commit/bd0dcf2) [`a59dcf4`](https://github.com/HunCY5/safe/commit/a59dcf4) [`43605f9`](https://github.com/HunCY5/safe/commit/43605f9) [`fa59759`](https://github.com/HunCY5/safe/commit/fa59759)
- 검증 — iPhone 실기기에서 두 오버레이가 같은 사람을 가리키는지 확인

</details>

---

### 2. 다중 인물 프레임에서 보호구 판정 대상이 매 프레임 갈아타던 문제, IoU 기반 트랙 잠금으로 해결

<img width="720" alt="단일 트랙 잠금" src="https://github.com/user-attachments/assets/2763f7c8-5de9-4925-b6b4-0591fa66fec4" /> <br>

**📍 제약 상황**

- 함께 돌리는 자세추정 모델이 단일 인물 추정용 → 보호구 판정도 같은 한 사람으로 좁혀야 함
- 판정 대상 선택이 **매 프레임 우선순위 계산으로만 이뤄짐** → 탐지 여부·면적·중앙 근접 순위가 조금만 바뀌어도 대상이 교체

**⚖️ 선택한 구조와 이유**

매 프레임 우선순위를 다시 계산하면 순위가 조금만 흔들려도 대상이 바뀌고, 반대로 첫 후보를 끝까지 붙잡으면 그 사람이 화면을 벗어난 뒤에도 놓지 못합니다. 두 방식 모두 대상 선택을 한 프레임의 계산 결과에만 맡기기 때문입니다. **한 번 고른 대상은 겹침이 유지되는 동안 유지하기로 했습니다.**

**✅ 결과**

- 선택한 트랙의 식별자를 `lockedTrackID`로 따로 보관 — 매 프레임 재선정 경로 제거
- 겹침이 `lockIouKeep` 이상이면 유지, `lockIouDrop` 아래가 `lockMissLimit` 프레임 이어지면 잠금 해제 후 기존 우선순위로 재선정
- 유지·해제 임계값을 다르게 두어 경계선에서의 잠금 진동 차단
- 자세추정 대상과 보호구 판정 대상이 같은 사람으로 유지 — 두 결과가 서로 다른 사람을 가리키지 않음

<details>
<summary>근거</summary>

- 코드 — [`PPEDetector.swift:37-42`](https://github.com/HunCY5/safe/blob/44dd87af257b774bb1e903f9fd49b6b70212430e/safe/Sources/Model/PPEDetection/PPEDetector.swift#L37-L42) · [`:70-75`](https://github.com/HunCY5/safe/blob/44dd87af257b774bb1e903f9fd49b6b70212430e/safe/Sources/Model/PPEDetection/PPEDetector.swift#L70-L75) · [`:313-353`](https://github.com/HunCY5/safe/blob/44dd87af257b774bb1e903f9fd49b6b70212430e/safe/Sources/Model/PPEDetection/PPEDetector.swift#L313-L353)
- 커밋 — [`ee9ef3c`](https://github.com/HunCY5/safe/commit/ee9ef3c) [`b370fb5`](https://github.com/HunCY5/safe/commit/b370fb5) [`0b6c5a6`](https://github.com/HunCY5/safe/commit/0b6c5a6)

</details>

---

### 3. 보호구 판정 화면에서 라벨이 프레임마다 뒤집히고 조끼가 오검출되던 문제, 임계값·다수결·상체 영역 제한으로 해결

<img width="720" alt="보호구 판정 안정화" src="https://github.com/user-attachments/assets/0a957f30-17b6-4a13-8641-10a1c23f9dfa" /> <br>

**📍 제약 상황**

- 착용·미착용을 **프레임 단위 최댓값 신뢰도만으로 즉시 결정** → 같은 사람의 라벨이 `Helmet`과 `No Helmet` 사이를 매 프레임 오감
- 사람 박스 하단·배경에 잡힌 조끼 박스가 착용으로 집계되고, 트랙이 한 프레임만 끊겨도 박스가 사라짐

**⚖️ 선택한 구조와 이유**

임계값을 올려 확신이 설 때만 판정하면 멀리 있거나 가려진 작업자가 아예 잡히지 않고, 반대로 낮추면 오검출과 깜빡임이 함께 늘어납니다. 두 방향 모두 한 프레임의 신뢰도 하나만 보고 최종 라벨을 정하기 때문에 생기는 문제였습니다. **판정은 프레임 하나가 아니라 시간에 걸쳐 쌓인 것으로 내리기로 했습니다.**

**✅ 결과**

- 트랙마다 착용 판정 히스토리를 `smoothWindow` 길이만큼 유지해 다수결로 최종 라벨 결정 — 프레임 단위 즉시 판정 제거
- 조끼는 사람 박스의 `상체 구간`에 중심이 들어올 때만 집계 — 하단·배경 오검출 경로 제거
- 활성 트랙이 잠시 비면 `outputHoldFrames` 동안 직전 결과 유지 — 한 프레임 끊김으로 박스가 사라지지 않음
- 클래스별 임계값과 `deltaMargin`으로 미착용 신호를 우선 채택 — 애매한 프레임에서 안전 쪽으로 판정

<details>
<summary>근거</summary>

- 코드 — [`PPEDetectionModel.swift:33-71`](https://github.com/HunCY5/safe/blob/44dd87af257b774bb1e903f9fd49b6b70212430e/safe/Sources/Model/PPEDetection/PPEDetectionModel.swift#L33-L71) · [`PPEDetector.swift:360-369`](https://github.com/HunCY5/safe/blob/44dd87af257b774bb1e903f9fd49b6b70212430e/safe/Sources/Model/PPEDetection/PPEDetector.swift#L360-L369) · [`:406-419`](https://github.com/HunCY5/safe/blob/44dd87af257b774bb1e903f9fd49b6b70212430e/safe/Sources/Model/PPEDetection/PPEDetector.swift#L406-L419)
- 커밋 — [`811fa3c`](https://github.com/HunCY5/safe/commit/811fa3c) [`a4a0c64`](https://github.com/HunCY5/safe/commit/a4a0c64) [`bf287c8`](https://github.com/HunCY5/safe/commit/bf287c8) [`d062baa`](https://github.com/HunCY5/safe/commit/d062baa)

</details>

---

## 👥 팀원 소개

| **iOS Developer** | **iOS Developer** |
| :---: | :---: |
| <a href="https://github.com/HunCY5"><img src="https://github.com/HunCY5.png" width="200px" style="border-radius: 50%;" alt="HunCY5"/></a> | <a href="https://github.com/ChanSolShin"><img src="https://github.com/ChanSolShin.png" width="200px" style="border-radius: 50%;" alt="ChanSolShin"/></a> |
| [**HunCY5**](https://github.com/HunCY5) | [**ChanSolShin**](https://github.com/ChanSolShin) |

## 📌 브랜치 전략

| 브랜치 | 용도 | 병합 대상 |
|--------|------|------|
| `main` | 앱스토어 출시용 | - |
| `release` | 출시 준비 | `main`, `develop` |
| `hotfix` | 배포 버전 버그 수정 | `main`, `develop` |
| `develop` | 개발 완료 | `release` |
| `feature` | 기능 개발 | `develop` |

## 📌 커밋 컨벤션

| 태그 | 설명 |
|------|------|
| `feat` | 새로운 기능 추가·변경 |
| `fix` | 버그 수정 |
| `chore` | 빌드·의존성·리소스·CI 등 |
| `refactor` | 코드 리팩토링 |
| `docs` | 문서 수정 |
