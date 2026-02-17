//
//  GANResultView.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/16/26.
//

import SwiftUI
import Neuron


struct GANResultView: View {
  
  @State var parameters: GANViewParameters
  var onGenerate: () -> Image?
  
  var body: some View {
    VStack(spacing: 25) {
      parameters.generatedImage?
        .interpolation(.none)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 200, height: 200)
      
      Button(action: {
        parameters.generatedImage = onGenerate()
      }) {
        Label("Generate", systemImage: "wand.and.sparkles")
          .font(.system(size: 30, weight: .semibold))
          .padding(4)
      }
      .focusEffectDisabled()
      .buttonStyle(.accessoryBarAction)
      .tint(Color(red: 0.3, green: 0.6, blue: 0.5))
    }
    .padding(16)
  }
}

#Preview {
  GANResultView(parameters: .init(), onGenerate: {
    nil
  })
    .frame(width: 300, height: 500)
}
