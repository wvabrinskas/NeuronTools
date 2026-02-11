//
//  Builder.swift
//  Neuron
//
//  Created by William Vabrinskas on 10/7/24.
//

import Foundation
@_spi(Visualizer) import Neuron

public struct BuilderResult {
  public var description: String
  public var network: Sequential
}

public final class Builder {
  public init() {}
  
  public func build(_ data: Data) async throws -> BuilderResult {
    return try await withUnsafeThrowingContinuation { continuation in
      Task.detached(priority: .userInitiated) {
        let network: Sequential = .import(data)
        network.compile()
        continuation.resume(returning: .init(description: network.debugDescription,
                                             network: network))
      }
    }
  }
}
