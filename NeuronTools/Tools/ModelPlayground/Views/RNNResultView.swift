//
//  RNNResultView.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/16/26.
//

import SwiftUI
import Neuron


struct RNNResultView: View {
  
  var parameters: RNNViewParameters
  var onGenerate: () -> ()
  
  var body: some View {
    VStack(spacing: 25) {
      if let text = parameters.generatedString {
        ScrollView {
          Text(text)
            .font(.system(size: 25, weight: .semibold))
            .padding(4)
        }
        .frame(maxHeight: 300)
      }
      
      GenerateButton(onGenerate: onGenerate)
    }
    .padding(16)
  }
}

#Preview {
  RNNResultView(parameters: .init(generatedString: "Hamley, Gumpley, Wubley, Showley"), onGenerate: {})
    .frame(width: 300, height: 500)
}
