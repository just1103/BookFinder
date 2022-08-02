# BookFinder
## 📚 프로젝트 소개
> [Google Books API](https://developers.google.com/books/docs/overview)를 통해 도서 검색 결과를 목록/상세 화면에 나타냅니다.

- Deployment Target : iOS 14.0
- Architecture : MVVM-C
- 라이브러리 : RxSwift, SwiftLint / 의존성 관리도구 : SPM
- 코딩 컨벤션, 커밋 컨벤션 등 자세한 내용은 [Wiki](https://github.com/just1103/BookFinder/wiki)를 참고해주세요.

## Foldering
```
BookFinder
├── App
├── Presentation
│   ├── SearchListPage
│   │   ├── View
│   │   └── ViewModel
│   └── DetailPage
│       ├── View
│       └── ViewModel
├── Model
├── Network
│   └──  Entities
├── Protocols
├── Extensions
├── Utilities
└── Resources
BookFinderTests
└── Mock
```

## 목차
- [Feature1. 네트워크 및 목록 화면 구현](##feature1.-네트워크-및-목록-화면-구현)
    + [주요 기능](#1-1-주요-기능)
    + [구현 내용](#1-2-구현-내용)
    + [Trouble Shooting](#1-3-trouble-shooting)
- [Feature2. 상세 화면 구현](##feature2.-상세-화면-구현)
    + [주요 기능](#2-1-주요-기능)
    + [구현 내용](#2-2-구현-내용)
    + [Trouble Shooting](#2-3-trouble-shooting)
- [보완할 점](##보완할-점)

## Feature1. 네트워크 및 목록 화면 구현
### 1-1 주요 기능
- 사용자가 검색한 도서 데이터를 서버에서 받아와 목록으로 나타냅니다.
- `URLSession`을 통해 네트워크 통신을 구현했습니다. (MockURLSession을 통한 테스트 실행)
- `SearchController`에 검색키워드를 입력할 때마다 `CollectionView`가 즉시 업데이트됩니다.
- 목록 최하단으로 Scroll하면 서버에서 다음 페이지의 데이터를 받아오도록 `Pagination`을 구현했습니다.
- `ActivityIndicator`를 통해 로딩 애니메이션을 보여줍니다. (추가 구현)
- 이미지 `Cache`를 구현했습니다. (추가 구현)
- `JSONParserTests`, `MockNetworkProviderTests`, `NetworkProviderTests`를 통한 테스트 를 진행했습니다. (추가 구현)

*배경 및 리뷰 노트 등은 관련 PR ["검색키워드를 입력하면 서버 데이터를 전달받아 목록 화면에 나타냅니다."](https://github.com/just1103/BookFinder/pull/1)를 참고해주세요.

|목록 화면|
|-|
|<img src="https://i.imgur.com/kercCN2.gif" width="200">|

### 1-2 구현 내용
#### 1. 네트워크 구현 및 API 추상화
`RxSwift`를 활용하여 비동기 작업을 처리했습니다. 서버에서 받아온 데이터는 `Observable` 타입으로 반환하고, ViewModel에서 ViewController에 전달 (Binding)하여 화면에 나타내도록 구현했습니다. 이때 데이터를 화면에 나타내는 최말단 시점에만 `Subscribe`하여 Stream이 끊기지 않는 구조를 유지했습니다. 

또한 API를 `열거형`으로 관리하는 경우, API를 추가할 때마다 새로운 case를 생성하여 열거형이 비대해지고, 열거형 관련 switch문을 매번 수정해야 하는 번거로움이 있었습니다.  따라서 API마다 독립적인 `구조체` 타입으로 관리되도록 변경하고, URL 프로퍼티 외에도 `HttpMethod` 프로퍼티를 추가한 APIProtocol 타입을 채택하도록 개선했습니다. 이로써 코드유지 보수가 용이하며, 협업 시 각자 담당한 API 구조체 타입만 관리하면 되기 때문에 충돌을 방지할 수 있습니다.

#### 2. MockURLSession을 통한 네트워크 테스트
아래의 목적을 위해 `MockURLSession`을 구현했습니다.
- 실제 서버와 통신할 경우 테스트의 속도가 느려짐
- 인터넷 연결상태에 따라 테스트 결과가 달라지므로 테스트 신뢰도가 떨어짐
- 실제 서버와 통신을 하며 서버에 테스트 데이터가 불필요하게 업로드되는 Side-Effect가 발생함

#### 3. MVVM-C 적용
`Coordinator`를 통해 의존성 주입을 관리하고, 화면전환 역할을 전담하도록 했습니다. 이를 위해 `navigationController`를 `생성자 주입`으로 하위 ChildCoordinator에 전달하고, 화면전환 시 해당 `navigationController`가 다음 화면을 push 하도록 했습니다.

#### 4. DiffableDataSource 및 Snapshot 활용
사용자가 검색 키워드를 입력할 때마다 목록을 업데이트하도록 구현하기 위해 `DiffableDataSource`를 활용했습니다. `reloadData()`를 호출할 필요가 없으므로 CollectionView Cell이 업데이트될 때마다 애니메이션이 적용되어 UX 측면에서 유리하다고 판단했습니다. 

또한 RxSwift를 통해 ViewModel과 ViewController를 Binding 시켜 역할을 분리했습니다. 예를 들어 사용자가 목록화면에서 스크롤을 최하단으로 내리면, `ViewModel`은 서버를 통해 데이터를 업데이트하고, `ViewController`는 Snapshot을 apply하여 화면을 다시 그리도록 했습니다.

#### 5. ActivityIndicator 관련 Delegate 패턴 적용
서버 데이터를 받아오는 동안 로딩 애니메이션을 나타내기 위해 `ActivityIndicator`를 구현했습니다. 하지만 ActivityIndicator를 보여주는 시점 (ex. 목록 최하단으로 Scroll하여 다음 페이지를 나타낼 시점 등)은 `ViewModel`이 알고 있으므로 `ViewController`를 `delegate`로 설정했습니다.

또한 ViewModel에서 delegate를 호출하는 방식으로 ActivityIndicator에 접근할 경우 `Main 스레드`를 통해 화면에 나타내야 하므로 `DispatchQueue`를 활용했습니다.

#### 6. SearchController를 통한 검색창 구현
UISearchController를 활용하여 NavigationBar 내부에 검색창이 위치하도록 했습니다. `SearchBar` 대신 `UISearchController`을 사용한 이유는 목록을 Scroll할 때 자동으로 검색창을 숨기고, 검색창에 텍스트를 입력할 때 자동으로 Navigation Title을 숨기는 등 사용자에게 보다 직관적인 UX를 구현할 수 있기 때문입니다.

### 1-3 Trouble Shooting
#### 1. SearchBar에 공백을 입력하면 서버에서 error를 반환하는 문제
SearchBar에 공백만 입력하면 화면이 업데이트되지 않는 문제가 발생했습니다. 원인은 API query에 빈문자 또는 공백만 전달하면 서버에서 error를 반환하여 stream이 끊기는 것으로 파악했습니다.

따라서 SearchText가 빈문자이거나 공백으로만 구성된 문자열인 경우, 서버에 데이터를 요청하지 않도록 예외 처리했습니다.

#### 2. Mock 데이터 활용 시 Bundle에 접근하지 못하는 문제
`JSON Parsing` 테스트를 할 때, `Bundle.main.path`를 통해 Mock 데이터에 접근하도록 했는데, path에 nil이 반환되는 문제가 발생했습니다. LLDB 확인 결과 Mock 데이터 파일이 포함된 Bundle은 `BookFinderTests.xctest`이며, 테스트 코드를 실행하는 주체는 `App Bundle`임을 파악했습니다. 

따라서 현재 executable의 Bundle 개체를 반환하는 `Bundle.main` (즉, App Bundle)이 아니라, 테스트 코드를 실행하는 주체를 가르키는 `Bundle(for: type(of: self))` (즉, XCTests Bundle)로 path를 수정하여 문제를 해결했습니다.

#### 3. 서버 데이터 특성을 고려하여 Model 타입 및 UI 구성
subtitle, publishedData 등 일부 데이터가 누락된 경우가 빈번하여 `JSON Parsing` 에러를 방지하기 위해 DTO 타입의 모든 프로퍼티를 `옵셔널 타입`으로 지정했습니다.

마찬가지로 이미지 URL 포함 유무도 데이터마다 다르기 때문에 URL이 없는 경우 임의의 `SF Symbol` 이미지를 나타내어 에러 화면으로 인식되는 것을 방지했습니다.

#### 4. estimatedHeight 사용 시 특정 버전에서 crash 발생
CompositionalLayout에서 `estimatedHeight`를 사용할 때, iOS 15.0 이상 15.3 이하 버전에서 crash가 발생했습니다. 이에 대응하기 위해 사용자의 기기 버전이 iOS 15.0~15.3인 경우 Alert를 띄워 사용자에게 업데이트를 권하도록 구현했습니다.

## Feature2. 상세 화면 구현
### 2-1 주요 기능
- 검색 목록의 도서 Cell을 탭하면 상세 화면으로 이동합니다.
- 가로/세로 모드 전환에 반응합니다.

*배경 및 구체적인 작업 내용은 관련 PR ["목록 화면에서 도서 Cell을 탭하면 상세 화면을 나타냅니다."](https://github.com/just1103/BookFinder/pull/2)를 참고해주세요.

|상세 화면|가로/세로 모드 전환|
|-|-|
|<img src="https://i.imgur.com/TocbU4B.gif" width="200">|<img src="https://i.imgur.com/wN706Ke.gif" width="200">|

### 2-2 구현 내용 
#### 1. DetailCoordinator 추가 및 Delegate 패턴 적용
상세 화면은 목록 화면과 연결되므로 `SeachListCoordinator`의 childCoordinators에 `DetailCoordinator`를 추가했습니다. 메모리 관리를 위해 상세 화면이 화면에서 pop될 때, ViewModel의 deinit에서 Coordinator가 finish되도록 설정했습니다. SeachListCoordinator를 delegate로 지정하고, `removeFromChildCoordinators(coordinator:)`를 호출하여 DetailCoordinator를 childCoordinator에서 제거했습니다.

`Debug Memory Graph`를 통한 디버깅으로 Coordinator/ViewModel 등이 메모리에서 정상적으로 해제되는지 확인했습니다.

### 2-3 Trouble Shooting
#### 1. 상세화면에서 목록화면으로 돌아가면 서버 데이터를 재요청하는 문제
상세 화면이 pop 되는 경우, 검색창에서 이벤트가 발생하지 않아도 `updateSearchResults` 메서드가 호출됩니다. 이로 인해 서버 데이터를 재요청하면서 Scroll이 맨 위로 이동하여 UX에 악영향을 주는 문제가 발생했습니다.

이를 방지하고자 ViewModel에서 searchText를 전달받을 때 `distinctUntilChanged` operator를 사용하여 동일한 문자열이 전달되면 필터링되도록 처리했습니다. 

#### 2. ScrollView 관련 Layout 문제
Horizontal Scroll이 되는 문제가 발생하여 ScrollView의 `ContentView Width`가 화면 크기와 동일하도록 설정했습니다. 그리고 `TextView`에 텍스트가 채워지면서 Scroll이 아래로 내려가는 문제가 발생하여 다시 Scroll을 맨 위로 올리는 작업을 추가했습니다.

## 보완할 점
- Quick/Numble을 활용하여 ViewModel 테스트 코드를 추가할 예정입니다.
- iPad 등 Wide Screen에 대응하기 위해 Compositional Layout의 columnCount 값을 재설정할 예정입니다.
- Clean Swift를 스터디하고 적용해볼 예정입니다.
