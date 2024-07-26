import SwiftUI

@main
struct FindVaccineCenterApp: App {
  var body: some Scene {
    WindowGroup {
      MainCoordinatorView(store: .init(initialState: .initialState) {
        MainCoordinator()
      })
    }
  }
}
