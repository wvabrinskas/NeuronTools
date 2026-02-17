//
//  ClassifierResultView.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/16/26.
//

import SwiftUI
import Neuron


struct ClassifierResultView: View {
  
  let imageDropViewModel: ImageDropViewModel
  let imageDropModule: ImageDropModule
  @State var classifierViewParameters: ClassifierViewParameters
  var feedImage: (NSImage?) -> Void
  
  var body: some View {
    VStack {
      ImageDropView(viewModel: imageDropViewModel,
                  module: imageDropModule)
      .onChange(of: imageDropViewModel.image) { _, newValue in
        feedImage(newValue)
      }
      
      Spacer()
      
      if let indexOfMax = classifierViewParameters.indexOfMax,
         let confidence = classifierViewParameters.confidence {
        
        if let image = imageDropViewModel.image {
          Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
        }
        
        HStack(spacing: 26) {
          VStack {
            Text("\(indexOfMax)")
              .font(.system(size: 55, weight: .bold))
              .foregroundStyle(.primary)
            Text("Label")
              .font(.system(size: 21, weight: .semibold))
              .foregroundStyle(.secondary)
          }
          
          VStack {
            Text("\(Int(confidence * 100))%")
              .font(.system(size: 55, weight: .bold))
              .foregroundStyle(colorForConfidence(confidence))
              .saturation(0.7)
            Text("Confidence")
              .font(.system(size: 21, weight: .semibold))
              .foregroundStyle(.secondary)
          }
        }
        
      }
      Spacer()
    }
  }
  
  func colorForConfidence(_ confidence: Float) -> Color {
    switch confidence {
    case 0.0..<0.5:
      return .red
    case 0.5..<0.75:
      return .yellow
    default:
      return .green
    }
  }
}

#Preview {
  ClassifierResultView(imageDropViewModel: .init(),
                       imageDropModule: .init(),
                       classifierViewParameters: .init(numberOfClasses: "128",
                                                       inputRows: "64",
                                                       inputColumns: "64",
                                                       inputDepth: "3",
                                                       indexOfMax: 38,
                                                       confidence: 1)) { _ in
    
  }
                                                       .frame(width: 400, height: 500)
}
