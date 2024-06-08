//
//  ContentView.swift
//  FindVaccineCenter
//
//  Created by Yumin Chu on 6/2/24.
//

import SwiftUI

struct RootView: View {
  @State private var locationError: Error.LocationError?
  
  var body: some View {
    ZStack {
      RepresentedNaverMap(locationError: $locationError)
        .ignoresSafeArea()
    }
  }
}

#Preview {
  RootView()
}
