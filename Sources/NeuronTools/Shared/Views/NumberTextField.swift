//
//  NumberTextField.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/16/26.
//

import SwiftUI

struct NumberTextField: View {
  @Binding var text: String
  var placeholder: String
  
  var body: some View {
    TextField(placeholder, text: $text)
      .textFieldStyle(.plain)
      .font(.system(size: 14, weight: .medium, design: .monospaced))
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .fill(.ultraThinMaterial)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .stroke(Color.blue.opacity(0.3), lineWidth: 1)
      )
      .frame(width: 80)
      .onChange(of: text) { _, newValue in
        text = newValue.filter { $0.isNumber }
      }
  }
}
