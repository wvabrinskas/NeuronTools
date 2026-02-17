//
//  PNGExporter.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/13/26.
//

import AppKit
import SwiftUI

struct PNGExporter {
  
  @MainActor
  static func exportView<V: View>(_ view: V, scale: CGFloat = 2.0) {
    let savePanel = NSSavePanel()
    savePanel.allowedContentTypes = [.png]
    savePanel.nameFieldStringValue = "neural_network_graph.png"
    savePanel.title = "Export Graph as PNG"
    
    savePanel.begin { response in
      if response == .OK, let url = savePanel.url {
        Task { @MainActor in
          if let image = renderViewToImage(view, scale: scale) {
            savePNG(image: image, to: url)
          }
        }
      }
    }
  }
  
  @MainActor
  private static func renderViewToImage<V: View>(_ view: V, scale: CGFloat) -> NSImage? {
    let renderer = ImageRenderer(content: view)
    renderer.scale = scale
    // Use proposed size to let the view determine its natural size
    renderer.proposedSize = .unspecified
    
    return renderer.nsImage
  }
  
  private static func savePNG(image: NSImage, to url: URL) {
    guard let tiffData = image.tiffRepresentation,
          let bitmapRep = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
      print("Failed to convert image to PNG")
      return
    }
    
    do {
      try pngData.write(to: url)
    } catch {
      print("Failed to save PNG: \(error)")
    }
  }
}
