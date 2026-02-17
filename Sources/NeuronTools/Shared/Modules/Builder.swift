//
//  Builder.swift
//  Neuron
//
//  Created by William Vabrinskas on 10/7/24.
//

import Foundation
@_spi(Visualizer) import Neuron

struct BuilderResult {
  var description: String
  var network: Sequential
}

final class Builder {
  init() {}

  func build(_ data: Data) async throws -> BuilderResult {
    return try await withUnsafeThrowingContinuation { continuation in
      Task.detached(priority: .userInitiated) {
        let network: Sequential = .import(data)
        network.compile()
        network.isTraining = false
        continuation.resume(returning: .init(description: network.debugDescription,
                                             network: network))
      }
    }
  }
}
