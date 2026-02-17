//
//  LabeledNumberField.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/16/26.
//

import SwiftUI

struct LabeledNumberField: View {
  var label: String
  @Binding var text: String
  var placeholder: String
  
  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(label)
        .font(.system(size: 11, weight: .medium))
        .foregroundStyle(.tertiary)
      NumberTextField(text: $text, placeholder: placeholder)
    }
  }
}
