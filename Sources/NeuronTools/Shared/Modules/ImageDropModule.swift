//
//  ImageDropModule.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 7/30/25.
//

import SwiftUI
import Neuron

@available(macOS 14, *)
final class ImageDropModule: DropDelegate {
  let viewModel: ImageDropViewModel = .init()

  func build(_ data: Data?) {
    guard let data else { return }
    let image = NSImage(data: data)
    viewModel.image = image
    clean()
  }

  func performDrop(items: [NSItemProvider]) {
    viewModel.message.removeAll()

    guard let data = items.first else { return }

    let _ = data.loadDataRepresentation(for: .image) { data, error in
      self.viewModel.loading.isLoading = true

      Task { @MainActor in
        self.build(data)
        self.viewModel.loading.isLoading = false
        self.viewModel.dropState = .none
      }
    }
  }

  private func clean() {
    viewModel.loading = .init()
  }

  // MARK: DropDelegate
  func dropEntered(info: DropInfo) {
    // Triggered when an object enters the view.
    viewModel.dropState = .enter
  }

  func dropExited(info: DropInfo) {
    // Triggered when an object exits the view.
    viewModel.dropState = .none
    viewModel.loading = .init()
  }

  func dropUpdated(info: DropInfo) -> DropProposal? {
    // Triggered when an object moves within the view.
    .none
  }

  func validateDrop(info: DropInfo) -> Bool {
    // Determines whether to accept or reject the drop.
    info.hasItemsConforming(to: [.image]) && viewModel.loading.isLoading == false
  }

  func performDrop(info: DropInfo) -> Bool {
    // Handles the drop when the user drops an object onto the view.
    performDrop(items: info.itemProviders(for: [.image]))
    return info.hasItemsConforming(to: [.image])
  }
}
