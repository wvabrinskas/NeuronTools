//
//  ClassifierTypeParameters.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/15/26.
//

import Neuron
import SwiftUI

struct ClassifierTypeParameters {
  var classes: Int
  var inputSize: TensorSize
}

@Observable
class ClassifierViewParameters {
  var numberOfClasses: String
  var inputRows: String
  var inputColumns: String
  var inputDepth: String
  var indexOfMax: Int?
  var confidence: Tensor.Scalar?
  
  init(numberOfClasses: String = "",
       inputRows: String = "",
       inputColumns: String = "",
       inputDepth: String = "",
       indexOfMax: Int? = nil,
       confidence: Tensor.Scalar? = nil) {
    self.numberOfClasses = numberOfClasses
    self.inputRows = inputRows
    self.inputColumns = inputColumns
    self.inputDepth = inputDepth
    self.indexOfMax = indexOfMax
    self.confidence = confidence
  }
}
