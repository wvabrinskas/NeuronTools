//
//  ImageDropModule.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 7/30/25.
//

import SwiftUI
import Neuron

@available(macOS 14, *)
public final class ImageDropModule: DropDelegate {
  public let viewModel: ImageDropViewModel
  
  public init(viewModel: ImageDropViewModel) {
    self.viewModel = viewModel
  }
  
  public func build(_ data: Data?) {
    guard let data else { return }
    let image = NSImage(data: data)
    viewModel.image = image
    clean()
  }
  
  public func performDrop(items: [NSItemProvider]) {
    viewModel.message.removeAll()
    
    guard let data = items.first else { return }
    
    let _ = data.loadDataRepresentation(for: .image) { data, error in
      self.viewModel.loading.isLoading = true
      
      Task { @MainActor in
        self.build(data)
        self.viewModel.loading.isLoading = false
      }
    }
  }
  
  private func clean() {
    viewModel.loading = .init()
  }
  
  // MARK: DropDelegate
  public func dropEntered(info: DropInfo) {
    // Triggered when an object enters the view.#imageLiteral(resourceName: "1_10_bulbasaur.png")
    viewModel.dropState = .enter
  }
  
  public func dropExited(info: DropInfo) {
    // Triggered when an object exits the view.
    viewModel.dropState = .none
    viewModel.loading = .init()
  }
  
  public func dropUpdated(info: DropInfo) -> DropProposal? {
    // Triggered when an object moves within the view.
    .none
  }
  
  public func validateDrop(info: DropInfo) -> Bool {
    // Determines whether to accept or reject the drop.
    info.hasItemsConforming(to: [.image]) && viewModel.loading.isLoading == false
  }
  
  public func performDrop(info: DropInfo) -> Bool {
    // Handles the drop when the user drops an object onto the view.
    performDrop(items: info.itemProviders(for: [.image]))
    return info.hasItemsConforming(to: [.image])
  }
}
