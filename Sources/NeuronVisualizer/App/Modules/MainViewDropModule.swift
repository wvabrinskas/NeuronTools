//
//  MainViewDropDelegate.swift
//  Neuron
//
//  Created by William Vabrinskas on 10/7/24.
//

import SwiftUI
import Neuron

@available(macOS 14, *)
final class MainViewDropModule: DropDelegate {
  let viewModel: MainViewModel
  private let builder: Builder
  
  init(viewModel: MainViewModel,
       builder: Builder) {
    self.viewModel = viewModel
    self.builder = builder
  }
  
  func buildGraphView(network: Sequential) -> GraphView {
    let layers = network.layers
    let root: Node = BaseNode()
    var workingNode = root
    
    // Add input layer
    if let firstLayer = layers.first {
      let inputPayload = NodePayload(layer: firstLayer)
      let inputNode = InputLayerNode(payload: inputPayload)
      workingNode.connections.append(inputNode)
      workingNode = inputNode
    }
    
    // Add all other layers
    layers.forEach { type in
      let payload = NodePayload(layer: type)
      let nextNode = if type is ActivationLayer {
        DetailedActivationLayerNode(payload: payload)
      } else if type is ConvolutionalLayer {
        ImageVisualizationLayerNode(payload: payload)
      } else {
        DetailedLayerNode(payload: payload)
      }
      
      workingNode.connections.append(nextNode)
      workingNode = nextNode
    }
    
    return .init(root: root)
  }
  
  func build(_ data: Data?) async throws {
    guard let data else { return }
    
    let buildResult = try await builder.build(data)
    
    viewModel.message = buildResult.description
    viewModel.graphView = buildGraphView(network: buildResult.network)

    clean()
  }
  
  func performDrop(items: [NSItemProvider]) {
    viewModel.message.removeAll()
    viewModel.graphView = nil
    
    guard let data = items.first else { return }
    
    let _ = data.loadDataRepresentation(for: .data) { data, error in
      self.viewModel.loading.isLoading = true
      Task { @MainActor in
        do {
          try await self.build(data)
        } catch {
          print(error.localizedDescription)
        }
      }
    }
  }
  
  private func clean() {
    viewModel.importData = nil
    viewModel.loading = .init()
  }
  
  // MARK: DropDelegate
  
  func onBuildComplete() {
    
  }
  
  func dropEntered(info: DropInfo) {
    // Triggered when an object enters the view.
    viewModel.dropState = .enter
  }
  
  func dropExited(info: DropInfo) {
    // Triggered when an object exits the view.
    viewModel.dropState = .none
  }
  
  func dropUpdated(info: DropInfo) -> DropProposal? {
    // Triggered when an object moves within the view.
    .none
  }
  
  func validateDrop(info: DropInfo) -> Bool {
    // Determines whether to accept or reject the drop.
    info.hasItemsConforming(to: [.data]) && viewModel.loading.isLoading == false
  }
  
  func performDrop(info: DropInfo) -> Bool {
    guard viewModel.loading.isLoading == false else { return false }
    // Handles the drop when the user drops an object onto the view.
    performDrop(items: info.itemProviders(for: [.data]))
    return info.hasItemsConforming(to: [.data])
  }
}
