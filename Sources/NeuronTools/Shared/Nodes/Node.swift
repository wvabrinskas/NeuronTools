//
//  Node.swift
//  Neuron
//
//  Created by William Vabrinskas on 10/7/24.
//

import SwiftUI
@_spi(Visualizer) import Neuron
import NumSwift

struct NodePayload {
  var layer: EncodingType
  var outputSize: TensorSize
  var inputSize: TensorSize
  var parameters: Int
  var details: String
  var layerType: BaseLayerType
  var weights: [Tensor]
  var weightsSize: TensorSize

  init(layer: EncodingType,
       outputSize: TensorSize,
       inputSize: TensorSize,
       parameters: Int,
       details: String,
       weights: [Tensor],
       weightsSize: TensorSize,
       layerType: BaseLayerType = .regular) {
    self.layer = layer
    self.outputSize = outputSize
    self.inputSize = inputSize
    self.parameters = parameters
    self.details = details
    self.layerType = layerType
    self.weights = weights
    self.weightsSize = weightsSize
  }

  init(layer: Layer) {
    self.layer = layer.encodingType
    self.outputSize = layer.outputSize
    self.inputSize = layer.inputSize
    self.parameters = layer.weights.shape.reduce(1, *)
    self.details = layer.details
    self.weights = (try? layer.exportWeights()) ?? []

    if let convLayer = layer as? ConvolutionalLayer {
      weightsSize = .init(rows: convLayer.filterSize.rows,
                          columns: convLayer.filterSize.columns,
                          depth: convLayer.filterCount)
    } else {
      weightsSize = .init()
    }

    layerType = if layer is ActivationLayer {
      .activation
    } else {
      .regular
    }
  }
}

protocol Node: AnyObject {
  var id: UUID { get }
  var details: String { get }
  var parentPoint: CGPoint? { get set }
  var point: CGPoint? { get set }
  var connections: [Node] { get set }

  @ViewBuilder
  func build() -> any View
}

class BaseNode: Node {
  var parentPoint: CGPoint?
  var point: CGPoint?
  let id = UUID()
  let details: String

  var connections: [Node] = []
  let layer: EncodingType
  let payload: NodePayload

  func build() -> any View {
    EmptyView()
  }

  init(payload: NodePayload = .init(layer: .none,
                                             outputSize: .init(array: []),
                                             inputSize: .init(array: []),
                                             parameters: 0,
                                             details: "",
                                             weights: .init(),
                                             weightsSize: .init())) {
    self.details = payload.layer.rawValue
    self.payload = payload
    self.layer = payload.layer
  }

}

enum BaseLayerType {
  case regular, activation
}

extension EncodingType {
  var color: Color {
    switch self {
    case .leakyRelu, .relu, .sigmoid, .tanh, .swish, .selu, .softmax: Color(red: 0.2, green: 0.6, blue: 0.2)
    case .batchNormalize, .layerNormalize: Color(red: 0.6, green: 0.5, blue: 0.8)
    case .conv2d, .transConv2d: Color(red: 0, green: 0.5, blue: 0.8)
    case .dense: Color(red: 0.8, green: 0.4, blue: 0.4)
    case .dropout: Color(red: 0.7, green: 0.1, blue: 0.7)
    case .flatten: Color(red: 0.7, green: 0.4, blue: 0.8)
    case .maxPool, .avgPool: Color(red: 0.9, green: 0.6, blue: 0.2)
    case .reshape: Color(red: 0.8, green: 0.6, blue: 0.8)
    case .lstm, .embedding: Color(red: 0.6, green: 0.4, blue: 0.8)
    case .globalAvgPool: Color(red: 0.9, green: 0.3, blue: 0.3)
    case .resNet: Color(red: 0.3, green: 0.7, blue: 0.3)
    default: Color(red: 0.5, green: 0.5, blue: 0.5)
    }
  }
  
  var icon: String {
    switch self {
    case .leakyRelu, .relu: "bolt.fill"
    case .sigmoid: "s.circle.fill"
    case .tanh: "t.circle.fill"
    case .swish, .selu: "waveform.path"
    case .softmax: "chart.bar.fill"
    case .batchNormalize, .layerNormalize: "slider.horizontal.3"
    case .conv2d: "square.grid.3x3.fill"
    case .transConv2d: "square.grid.3x3.topleft.filled"
    case .dense: "circle.grid.cross.fill"
    case .dropout: "xmark.circle.fill"
    case .flatten: "arrow.right.to.line"
    case .maxPool, .avgPool: "square.grid.2x2.fill"
    case .reshape: "arrow.up.left.and.arrow.down.right"
    case .lstm: "arrow.triangle.2.circlepath"
    case .embedding: "textformat.abc"
    case .globalAvgPool: "globe"
    case .resNet: "arrow.triangle.branch"
    default: "cube.fill"
    }
  }
  
  var categoryName: String {
    switch self {
    case .leakyRelu, .relu, .sigmoid, .tanh, .swish, .selu, .softmax: "Activation"
    case .batchNormalize, .layerNormalize: "Normalization"
    case .conv2d, .transConv2d: "Convolution"
    case .dense: "Dense"
    case .dropout: "Regularization"
    case .flatten, .reshape: "Transform"
    case .maxPool, .avgPool, .globalAvgPool: "Pooling"
    case .lstm: "Recurrent"
    case .embedding: "Embedding"
    case .resNet: "Residual"
    default: "Layer"
    }
  }
}

extension Color {
  static func random(seed: UInt64) -> Color {
    Color(
      red: .randomIn(0...1, seed: seed).num,
      green: .randomIn(0...1, seed: seed + UInt64(2e2)).num,
      blue: .randomIn(0...1, seed: seed + UInt64(2e4)).num
    )
  }
}

