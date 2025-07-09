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
  func build(_ data: Data) async throws -> BuilderResult {
    return try await withUnsafeThrowingContinuation { continuation in
      Task.detached(priority: .userInitiated) {
        let network: Sequential = try JSONDecoder().decode(Sequential.self, from: data)
        network.compile()
        continuation.resume(returning: .init(description: network.debugDescription,
                                             network: network))
      }
    }
  }
}
