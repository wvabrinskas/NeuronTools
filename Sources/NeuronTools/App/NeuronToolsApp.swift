//
//  NeuronToolsApp.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/12/26.
//

import SwiftUI
@_spi(Visualizer) import Neuron

@main
struct NeuronToolsApp: App {
  var body: some Scene {
    WindowGroup {
      LauncherView()
    }
    .defaultSize(width: 400, height: 300)

    Window("Visualizer", id: "visualizer") {
      VisualizerView()
    }
    .defaultSize(width: 800, height: 600)

    Window("Model Playground", id: "model-playground") {
      ModelPlaygroundView()
    }
    .defaultSize(width: 480, height: 270)
  }
}
