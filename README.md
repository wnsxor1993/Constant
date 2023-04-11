# Constant Work

**LoremPiscu API를 통해 자유 형식의 작업물 구현 (과제)**
<br>

## ⏳ 프로젝트 제약사항

```
    1. 이미지/통신 오픈소스 사용하지 않고 작업
    2. 이미지는 캐싱 처리가 필요하며, 중복 처리하지 않도록 구현
    3. 마지막 리스트일 경우 마지막 페이지임을 알리는 Alert 처리
```
<br>

## 🎯 프로젝트 목표

```
    1. ReactorKit/Coordinator 활용
    2. 작업 단위 구분 및 사용 규칙 구현 (Manager/Service)
    3. 메인 화면 외의 화면 구현
```
<br>

## 🙊 목표 선정 이유
- 데이터의 흐름을 단방향으로 구현해 관리를 편하게 하고, RxSwift와의 시너지를 더 높이고자 ReactorKit을 활용. 이와 함께 Coordinator 패턴도 활용하여 VC가 본인의 UI에만 더 집중할 수 있도록 경량화시키고자 두 패턴을 도입.
- 중복 코드를 방지하고 책임 소재를 명확히 하여 유지/보수가 용이하도록 Domain 영역을 Manager와 Service로 또 그 내부에서도 작업 단위를 세분화하는 규칙을 확립. (Service는 범용적으로 해당 기능만, Manager는 Service들을 활용해 프로젝트의 환경에 맞는 작업을 제공)
- 최초의 이미지들은 LaunchVC에서 fetch하여 MainVC에 진입하자마자 초기 View들을 볼 수 있게 구현, 각 이미지들은 DetailVC에서 좀 더 크게 볼 뿐더러 사진첩에 다운받을 수 있도록 추가적인 화면들을 구성.

<br>

## 📝 화면 개요
|   스크롤링    |   마지막 스크롤   |   상세 화면   |
| :----------: | :--------: | :--------: |
|  <img src="https://i.imgur.com/Idvo4HG.gif" width="250"> | <img src="https://i.imgur.com/xK0WVqk.gif" width="250"> | <img src="https://i.imgur.com/YcgTyOk.gif" width="250"> |
|   스크롤을 통한 이미지 출력    |   마지막 페이지 스크롤    |   상세 화면 및 다운로드   |

## ⚙️ 개발 환경


[![Swift](https://img.shields.io/badge/swift-v5.7.2-orange?logo=swift)](https://developer.apple.com/kr/swift/)
[![Xcode](https://img.shields.io/badge/xcode-v14.2-blue?logo=xcode)](https://developer.apple.com/kr/xcode/)
[![RxSwift](https://img.shields.io/badge/RxSwift-6.5.0-red)]()
[![SnapKit](https://img.shields.io/badge/SnapKit-5.6.0-red)]()
[![Then](https://img.shields.io/badge/Then-3.0.0-red)]()
<img src="https://img.shields.io/badge/UIkit-000000?style=flat&logo=UIkit" alt="uikit" maxWidth="100%">


<br>

## 🌟 고민과 해결

#### 1. Image 데이터 fetch

- API를 통해 20개의 데이터를 받은 후, 각각의 데이터에서 다시 API를 호출해 이미지 데이터를 받아와야 했는데 처음에 구현한 방식은 순차적으로 이미지 데이터를 받아오다보니 눈에 보일만큼 최종 데이터를 뿌려주는 속도가 느렸습니다.
이에 Concurrency하게 해당 작업을 진행하려 했으나, 기존 API 관련 로직들은 Observable을 리턴해주는 형태였기에 구현하기가 부적절하여 fetch가 완료되는 대로 Relay에 뿌려주는 방식으로 수정하였습니다.

```swift
func fetchImage(with dataSource: PiscumDataSource) {
        DispatchQueue.global(qos: .background).async {
            var newDataSource: PiscumDataSource = dataSource
            
            if let image: UIImage = ImageCacheService.loadImageFromCache(with: "PiscumID_\(dataSource.id)") {
                
                newDataSource.imageData = image.jpegData(compressionQuality: 1)
                
                self.imageDataSourceRelay.accept(newDataSource)
            }
            
            let width: CGFloat = .init(newDataSource.width)
            let height: CGFloat = .init(newDataSource.height)
            
            guard let image: UIImage = ImageCacheService.samplingImage(at: newDataSource.imageURL, to: .init(width: width, height: height), with: 0.1) else { return }
            
            ImageCacheService.saveImageToCache(with: "PiscumID_\(newDataSource.id)", image: image)
            newDataSource.imageData = image.jpegData(compressionQuality: 1)
            self.imageDataSourceRelay.accept(newDataSource)
        }
    }
```

- 이렇게 Manager에서 작업이 완료되어 Relay에 뿌려진 모델을 Reactor에서 캐치하여 VC에게까지 전달을 해주어야 하나 Action 호출이 불가한 상황이라 transform을 활용하여 적절하게 모델을 받아올 수 있도록 수정하였습니다.

#### 2. LaunchVC -> MainVC

- LaunchVC에서 최초 20개의 모델을 먼저 받은 뒤, MainVC에게 인계하여 메인화면 진입하자마자 초기 이미지들을 온전하게 볼 수 있도록 구현하고자 했습니다. 처음에는 이미지 데이터를 받지 않은 초기 모델들을 Reactor로 받아오면 VC가 구독하고 있는 State의 구문에서 반복문으로 이미지 fetch 작업을 요청했습니다.
Reactor는 해당 작업을 통해 이미지를 받고 이를 State에 있는 기존 모델 배열에서 id 값을 찾아 이미지 데이터를 덮어씌우고, 다시 해당 배열을 VC에게 전달하는 방식으로 구현하였습니다. 이후 VC는 모든 모델들이 이미지 데이터가 있는 걸 확인하면 Coordinator에게 Main으로의 이동을 요청하도록 했습니다.
해당 방식을 통해 원하는 화면 이동과 구현을 해냈지만, Main으로 진입한 이후에도 이미지를 중복으로 fetch 해오고 캐시하는 과정이 여러번 진행되는 문제가 생겼습니다.

- 이는 이미지 데이터를 아무도 가지고 있지 않은 초기 모델들을 받는 구독 구문과 이미지 데이터를 덮어씌운 모델들을 받는 구독 구문이 동일하다보니 반복문이 계속 호출되어 생기는 문제였습니다.
이에 초기 모델들 fetch 액션을 VC가 호출한 뒤, 초기 모델들을 VC에게 넘기지 않고 Reactor에서 반복문을 통해 이미지 fetch까지 진행하도록 수정하였습니다. 또한 Relay를 통해 이미지를 받아오면 그때서 해당 모델을 배열에 추가하여 VC에 전달하고, VC는 구독한 State의 값이 변경될 때 모든 모델들이 이미지를 가지고 있는지 판별하여 화면 이동을 요청하도록 수정하였습니다.

```swift
func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    return Observable.merge(mutation, listManager.imageDataSourceRelay.map(Mutation.refreshImage))
}
    
func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .fetchDefaultList:
        self.fetchAllImageData()
            
        return .empty()
    }
}

func fetchAllImageData() {
    self.listManager.fetchPageList()
        .observe(on: ConcurrentMainScheduler.instance)
        .subscribe(with: self) { (owner, list) in
            list.forEach {
                owner.listManager.fetchPageImageData(from: $0)
            }
        }
        .disposed(by: disposeBag)
}
```


#### 3. DownSampling 활용

- API에서 받아오는 이미지의 크기가 예상보다 크다보니 메모리에 다소 부담이 되겠다는 생각이 들어 DownSampling이라는 것을 활용해보고자 했습니다. 이미지 크기를 원하는 사이즈로 리사이즈하여 fetch 해오고 이를 캐싱처리까지 하도록 구현하였고 해당 로직까지는 별다른 문제나 고민은 없었습니다.
다만 이후에 해당 이미지를 원하는 모델의 프로퍼티에 전달할 때, 데이터 타입이 다른 부분이 문제였고 그렇다고 데이터 타입 파일에 UIKit을 임포트하는 건 좋지 않다는 생각이 들었습니다.
결국 리사이징한 이미지는 Data 타입으로 변환하여 모델에 전달하였고, 실제 UIImageView에서 해당 Data 타입을 인자로 받아서 이미지를 구현하도록 작성하였습니다.

- 새로운 기능을 쓰기 위해서는 더 깊은 이해와 활용하고자 하는 프로젝트의 환경이나 로직 등도 고려할 줄 아는 통찰력이 더 필요하다는 걸 느끼게 해준 작업이었습니다. 메모리의 부담을 줄여주는 DownSampling 기능은 매우 유용하기에 이를 어느 상황에서 어떻게 사용할 지에 대한 고민을 더 해보고자 합니다.

