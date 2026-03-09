//
//  GANResultView.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/16/26.
//

import SwiftUI
import Neuron


struct GANResultView: View {
  
  var parameters: GANViewParameters
  var onGenerate: () -> ()
  
  var body: some View {
    VStack(spacing: 25) {
      parameters.generatedImage?
        .interpolation(.none)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 200, height: 200)
      
      GenerateButton(onGenerate: onGenerate)
    }
    .padding(16)
  }
}

#Preview {
  GANResultView(parameters: .init(), onGenerate: {})
    .frame(width: 300, height: 500)
}
