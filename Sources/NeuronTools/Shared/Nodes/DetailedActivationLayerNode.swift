//
//  DetailedActivationLayerNode.swift
//  Neuron
//
//  Created by William Vabrinskas on 10/7/24.
//

import Neuron
import SwiftUI

class DetailedActivationLayerNode: BaseNode {

  @ViewBuilder
  override func build() -> any View {
    let layerColor = layer.color
    let layerIcon = layer.icon
    let layerTitle = layer.rawValue.capitalized
    
    PillCardView(style: .dashed(color: layerColor)) {
      HStack(spacing: 10) {
        CardIconBadge(icon: layerIcon, color: layerColor, size: .small)
        
        Text(layerTitle)
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(.primary)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
    }
  }
}

#Preview {
  HStack(spacing: 20) {
    AnyView(DetailedActivationLayerNode(payload: .init(layer: .relu,
                                                       outputSize: .init(),
                                                       inputSize: .init(),
                                                       parameters: 0,
                                                       details: "Activation",
                                                       weights: [],
                                                       weightsSize: .init())).build())
    
    AnyView(DetailedActivationLayerNode(payload: .init(layer: .sigmoid,
                                                       outputSize: .init(),
                                                       inputSize: .init(),
                                                       parameters: 0,
                                                       details: "Activation",
                                                       weights: [],
                                                       weightsSize: .init())).build())
    
    AnyView(DetailedActivationLayerNode(payload: .init(layer: .softmax,
                                                       outputSize: .init(),
                                                       inputSize: .init(),
                                                       parameters: 0,
                                                       details: "Activation",
                                                       weights: [],
                                                       weightsSize: .init())).build())
  }
  .padding(40)
  .background(Color(NSColor.windowBackgroundColor))
}
