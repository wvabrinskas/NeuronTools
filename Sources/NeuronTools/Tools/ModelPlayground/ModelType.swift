//
//  ModelType.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/15/26.
//

import SwiftUI

enum ModelType: String {
  case classifier
  case rnn
  case gan
  
  var title: String {
    switch self {
    case .classifier:
      "Classifier"
    case .rnn:
      "RNN"
    case .gan:
      "GAN"
    }
  }
  
  var icon: String {
    switch self {
    case .classifier:
      "square.stack.3d.down.right"
    case .rnn:
      "arrow.trianglehead.2.clockwise.rotate.90"
    case .gan:
      "photo.on.rectangle.angled"
    }
  }
  
  var accentColor: Color {
    switch self {
    case .classifier:
        .blue
    case .rnn:
        .indigo
    case .gan:
        .green
    }
  }
  
  var asDropdownItem: DropdownOption {
    .init(text: title,
          color: accentColor,
          id: rawValue)
  }
}
