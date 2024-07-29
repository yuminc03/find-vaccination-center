import TCACoordinators
import ComposableArchitecture

extension IdentifiedArray where Element: RouteProtocol {
  mutating func findAndMutate<ElementSubstate>(
    _ casePath: AnyCasePath<Element.Screen, ElementSubstate>,
    _ onlyMostRecent: Bool = true,
    transform: (inout ElementSubstate) -> Void
  ) {
    for (route, index) in zip(self, indices).reversed() {
      // navigation안에 있는 state들을 하나씩 살펴보면서 우리가 찾는 casePath라는 것을 찾았을 경우
      guard var subState = casePath.extract(from: route.screen) else { continue }
      // transform 안에서 substate를 변경
      transform(&subState)
      // 여기서 subState를 갈아끼움
      self[index].screen = casePath.embed(subState)
      // 가장 최근 화면(같은 화면을 여러번 썼을 수도 있으니까)만 바꾸려면 return
      if onlyMostRecent { return }
    }
  }
}
