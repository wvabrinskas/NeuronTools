//
//  GenerateButton.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 3/9/26.
//

import SwiftUI


public struct GenerateButton: View {
  var onGenerate: () -> ()
  @State private var isGenerating: Bool = false
  @State private var title: String = "Generate"
  
  public var body: some View {
    Button(action: {
      isGenerating = true
      Task(priority: .userInitiated) { @MainActor in
        onGenerate()
        isGenerating = false
      }
    }) {
      Label(isGenerating ? "Generating..." : title, systemImage: "wand.and.sparkles")
        .font(.system(size: 30, weight: .semibold))
        .padding(4)
    }
    .focusEffectDisabled()
    .buttonStyle(.accessoryBarAction)
    .tint(Color(red: 0.3, green: 0.6, blue: 0.5))
    .disabled(isGenerating)
  }
}
