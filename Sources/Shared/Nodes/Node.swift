//
//  Node.swift
//  Neuron
//
//  Created by William Vabrinskas on 10/7/24.
//

import SwiftUI
@_spi(Visualizer) import Neuron
import NumSwift


public struct NodePayload {
  public var layer: EncodingType
  public var outputSize: TensorSize
  public var inputSize: TensorSize
  public var parameters: Int
  public var details: String
  public var layerType: BaseLayerType
  public var weights: [Tensor]
  public var weightsSize: TensorSize
  
  public init(layer: EncodingType,
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
  
  public init(layer: Layer) {
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

public protocol Node: AnyObject {
  var parentPoint: CGPoint? { get set }
  var point: CGPoint? { get set }
  var connections: [Node] { get set }
  init(payload: NodePayload)
  
  @ViewBuilder
  func build() -> any View
}

open class BaseNode: Node {
  public var parentPoint: CGPoint?
  public var point: CGPoint?
  
  public var connections: [Node] = []
  public let layer: EncodingType
  public let payload: NodePayload
  
  open func build() -> any View {
    EmptyView()
  }

  public required init(payload: NodePayload = .init(layer: .none,
                                             outputSize: .init(array: []),
                                             inputSize: .init(array: []),
                                             parameters: 0,
                                             details: "",
                                             weights: .init(),
                                             weightsSize: .init())) {
    self.payload = payload
    self.layer = payload.layer
  }
  
}

public enum BaseLayerType {
  case regular, activation
}

public extension EncodingType {
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
      default: Color(red: 0.5, green: 0.5, blue: 0.5)
    }
  }
  
}
