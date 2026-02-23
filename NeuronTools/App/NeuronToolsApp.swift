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
        .frame(width: 700, height: 500)
    }
    .windowResizability(.contentSize)

    Window("Visualizer", id: "visualizer") {
      VisualizerView()
    }
    .defaultSize(width: 800, height: 600)

    Window("Playground", id: "model-playground") {
      ModelPlaygroundView()
    }
    .defaultSize(width: 700, height: 570)
    
    Window("Quantizer", id: "quantizer") {
      QuantizerView()
    }
    .defaultSize(width: 800, height: 270)
  }
}
