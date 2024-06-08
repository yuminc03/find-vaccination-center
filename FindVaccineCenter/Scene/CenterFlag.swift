//
//  CenterFlag.swift
//  FindVaccineCenter
//
//  Created by Yumin Chu on 6/9/24.
//

import SwiftUI

/// 지도 가운데 배치할 깃발모양 Flag
struct CenterFlag: View {
  var body: some View {
    ZStack {
      dotView
      lineView
        .offset(y: -10)
      flagView
        .offset(y: -30)
    }
  }
}

#Preview {
  CenterFlag()
}

extension CenterFlag {
  private var dotView: some View {
    Circle()
      .fill(.black)
      .frame(width: 5, height: 5)
  }
  
  private var lineView: some View {
    Rectangle()
      .fill(.black)
      .frame(width: 2, height: 25)
  }
  
  private var flagView: some View {
    Text("여기서 출발!")
      .font(.caption)
      .foregroundColor(.white)
      .padding(.horizontal, 10)
      .padding(.vertical, 5)
      .background(Color.black)
      .clipShape(RoundedRectangle(cornerRadius: 5))
  }
}
