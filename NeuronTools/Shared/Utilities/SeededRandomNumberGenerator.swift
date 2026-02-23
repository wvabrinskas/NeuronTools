//
//  SeededRandomNumberGenerator.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/12/26.
//

import Foundation

public extension Double {
  
  static func randomIn(_ range: ClosedRange<Double>, seed: UInt64 = .random(in: 0...UInt64.max)) -> (num: Double, seed: UInt64) {
    var generator = SeededRandomNumberGenerator(seed: seed)
    
    return (Double.random(in: range, using: &generator), seed)
  }
}

public extension Float {
  
  static func randomIn(_ range: ClosedRange<Float>, seed: UInt64 = .random(in: 0...UInt64.max)) -> (num: Float, seed: UInt64) {
    var generator = SeededRandomNumberGenerator(seed: seed)
    
    return (Float.random(in: range, using: &generator), seed)
  }
}

// A custom random number generator that uses a seed
public struct SeededRandomNumberGenerator: RandomNumberGenerator {
  private var state: UInt64
  
  init(seed: UInt64) {
    self.state = seed
  }
  
  public mutating func next() -> UInt64 {
    // XorShift algorithm for pseudorandom number generation
    state ^= state << 13
    state ^= state >> 7
    state ^= state << 17
    return state
  }
}
