//
//  FindVaccineCenterApp.swift
//  FindVaccineCenter
//
//  Created by Yumin Chu on 6/2/24.
//

import SwiftUI

@main
struct FindVaccineCenterApp: App {
  var body: some Scene {
    WindowGroup {
      AppView(store: .init(initialState: AppCore.State()) {
        AppCore()
      })
    }
  }
}
