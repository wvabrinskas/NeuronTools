//
//  DetailedLayerNode.swift
//  Neuron
//
//  Created by William Vabrinskas on 10/7/24.
//

import Neuron
import SwiftUI

class DetailedLayerNode: BaseNode {
  private let nodeWidth: CGFloat = 300

  @ViewBuilder
  override func build() -> any View {
    let layerColor = layer.color
    let layerIcon = layer.icon
    let layerTitle = layer.rawValue.capitalized
    let layerCategory = layer.categoryName
    let paramCount = getParameterCount()
    let inputSize = formatTensorSize(payload.inputSize)
    let outputSize = formatTensorSize(payload.outputSize)
    let details = payload.details
    let width = nodeWidth
    
    CardView(style: .default(color: layerColor)) {
      VStack(alignment: .leading, spacing: 0) {
        // Header with icon, title, and category badge
        CardHeader(
          icon: layerIcon,
          iconColor: layerColor,
          title: layerTitle,
          subtitle: layerCategory,
          trailing: paramCount.map { AnyView(CardBadge(text: $0, color: layerColor)) }
        )
        
        CardDivider()
        
        // Tensor flow visualization
        CardFlowItem(
          inputLabel: "Input",
          inputValue: inputSize,
          outputLabel: "Output",
          outputValue: outputSize,
          arrowColor: layerColor
        )
        
        // Details section (if available)
        if !details.isEmpty {
          CardDivider()
          
          Text(details)
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
            .lineLimit(2)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
      }
      .frame(width: width)
    }
  }

  private func getParameterCount() -> String? {
    let count = payload.parameters
    if count == 0 { return nil }
    return formatNumber(count)
  }

  private func formatTensorSize(_ size: TensorSize) -> String {
    let array = size.asArray
    if array.isEmpty || (array.count == 1 && array[0] == 0) {
      return "—"
    }
    if array.count == 1 {
      return "\(array[0])"
    }
    return array.map(String.init).joined(separator: "×")
  }
  
  private func formatNumber(_ number: Int) -> String {
    if number >= 1_000_000 {
      return String(format: "%.1fM", Double(number) / 1_000_000)
    } else if number >= 1_000 {
      return String(format: "%.1fK", Double(number) / 1_000)
    }
    return "\(number)"
  }
}


#Preview {
  VStack(spacing: 20) {
    AnyView(DetailedLayerNode(payload: .init(layer: .conv2d,
                                             outputSize: .init(rows: 32, columns: 32, depth: 64),
                                             inputSize: .init(rows: 64, columns: 64, depth: 3),
                                             parameters: 1728,
                                             details: "3×3 kernel, stride 2, padding same",
                                             weights: [],
                                             weightsSize: .init())).build())
    
    AnyView(DetailedLayerNode(payload: .init(layer: .dense,
                                             outputSize: .init(rows: 128, columns: 1, depth: 1),
                                             inputSize: .init(rows: 512, columns: 1, depth: 1),
                                             parameters: 65536,
                                             details: "",
                                             weights: [],
                                             weightsSize: .init())).build())
    
    AnyView(DetailedLayerNode(payload: .init(layer: .batchNormalize,
                                             outputSize: .init(rows: 32, columns: 32, depth: 64),
                                             inputSize: .init(rows: 32, columns: 32, depth: 64),
                                             parameters: 256,
                                             details: "momentum: 0.99, epsilon: 0.001",
                                             weights: [],
                                             weightsSize: .init())).build())
  }
  .padding(40)
  .background(Color(NSColor.windowBackgroundColor))
}
