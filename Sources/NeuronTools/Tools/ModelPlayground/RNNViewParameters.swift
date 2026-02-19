//
//  RNNViewParameters.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/16/26.
//

import SwiftUI
import Neuron

@Observable
class RNNViewParameters {
  var generatedString: String? = nil
  var numberToGenerate: String = ""
  var startingWith: String = ""
  var maxLength: String = ""
  var randomizeSelection: Bool
  
  init(generatedString: String? = nil,
       numberToGenerate: String = "",
       startingWith: String = "",
       maxLength: String = "",
       randomizeSelection: Bool = false) {
    self.generatedString = generatedString
    self.numberToGenerate = numberToGenerate
    self.startingWith = startingWith
    self.randomizeSelection = randomizeSelection
  }
}

extension String {
  var nilIfEmpty: String? {
    return isEmpty ? nil : self
  }
}
