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
      MapView(store: .init(initialState: MapCore.State()) {
        MapCore()
      })
    }
  }
}
