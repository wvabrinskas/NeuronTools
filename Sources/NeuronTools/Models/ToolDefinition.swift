//
//  ToolDefinition.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/12/26.
//

import Foundation

struct ToolDefinition: Identifiable {
  let id: String
  let name: String
  let icon: String
  let description: String

  static let allTools: [ToolDefinition] = [
    .init(id: "visualizer",
          name: "Visualizer",
          icon: "brain",
          description: "Visualize neural network architectures"),
    .init(id: "model-playground",
          name: "Model Playground",
          icon: "puzzlepiece",
          description: "Experiment with models interactively")
  ]
}
