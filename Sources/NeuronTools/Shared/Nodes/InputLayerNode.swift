//
//  InputLayerNode.swift
//  Neuron
//
//  Created by William Vabrinskas on 10/7/24.
//

import Neuron
import SwiftUI

@available(macOS 14, *)
class InputLayerNode: BaseNode {
  private let nodeWidth: CGFloat = 300
  private let accentColor = Color(red: 0.3, green: 0.7, blue: 0.5)
  
  @ViewBuilder
  override func build() -> any View {
    let color = accentColor
    let shapeText = formatTensorSize(payload.inputSize)
    let tensorViz = tensorVisualization(for: payload.inputSize)
    let width = nodeWidth
    
    CardView(style: .default(color: color)) {
      VStack(alignment: .leading, spacing: 0) {
        // Header
        CardHeader(
          icon: "arrow.down.circle.fill",
          iconColor: color,
          title: "Input Layer",
          subtitle: "Data Entry Point",
          trailing: AnyView(
            Image(systemName: "play.fill")
              .font(.system(size: 10))
              .foregroundStyle(color)
              .padding(6)
              .background(
                Circle()
                  .fill(color.opacity(0.15))
              )
          )
        )
        
        CardDivider()
        
        // Shape visualization
        HStack(spacing: 16) {
          VStack(alignment: .leading, spacing: 6) {
            Text("Shape")
              .font(.system(size: 9, weight: .medium))
              .foregroundStyle(.secondary)
            
            Text(shapeText)
              .font(.system(size: 16, weight: .bold, design: .monospaced))
              .foregroundStyle(.primary)
          }
          
          Spacer()
          
          // Visual representation of tensor dimensions
          tensorViz
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
      }
      .frame(width: width)
    }
  }
  
  @ViewBuilder
  private func tensorVisualization(for size: TensorSize) -> some View {
    let dims = size.asArray
    let color = accentColor
    
    if dims.count >= 3 && dims[0] > 0 {
      // Show as stacked squares for image-like data
      ZStack {
        ForEach(0..<min(3, dims[2]), id: \.self) { i in
          RoundedRectangle(cornerRadius: 4)
            .stroke(color.opacity(0.4), lineWidth: 1)
            .frame(width: 28, height: 28)
            .offset(x: CGFloat(i) * 4, y: CGFloat(i) * -4)
        }
      }
      .frame(width: 40, height: 40)
    } else if dims.count >= 1 && dims[0] > 0 {
      // Show as simple bar for 1D data
      HStack(spacing: 2) {
        ForEach(0..<min(4, dims[0]), id: \.self) { _ in
          RoundedRectangle(cornerRadius: 2)
            .fill(color.opacity(0.4))
            .frame(width: 6, height: 24)
        }
        if dims[0] > 4 {
          Text("...")
            .font(.system(size: 10))
            .foregroundStyle(.secondary)
        }
      }
    } else {
      EmptyView()
    }
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
}

#Preview {
  VStack(spacing: 20) {
    AnyView(InputLayerNode(payload: .init(layer: .none,
                                          outputSize: .init(),
                                          inputSize: .init(rows: 224, columns: 224, depth: 3),
                                          parameters: 0,
                                          details: "",
                                          weights: [],
                                          weightsSize: .init())).build())
    
    AnyView(InputLayerNode(payload: .init(layer: .none,
                                          outputSize: .init(),
                                          inputSize: .init(rows: 784, columns: 1, depth: 1),
                                          parameters: 0,
                                          details: "",
                                          weights: [],
                                          weightsSize: .init())).build())
  }
  .padding(40)
  .background(Color(NSColor.windowBackgroundColor))
}
