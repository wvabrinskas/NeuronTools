//
//  SVGExporter.swift
//  NeuronTools
//
//  Created by William Vabrinskas on 2/12/26.
//

import AppKit
import Foundation
import Neuron

struct SVGExporter {
  let layers: [[Node]]
  let nodePositions: [UUID: CGRect]
  let contentSize: CGSize
  
  func generateSVG() -> String {
    let width = max(contentSize.width, 100)
    let height = max(contentSize.height, 100)
    
    var svg = """
    <?xml version="1.0" encoding="UTF-8"?>
    <svg xmlns="http://www.w3.org/2000/svg" width="\(Int(width))" height="\(Int(height))" viewBox="0 0 \(Int(width)) \(Int(height))">
      <style>
        .node-rect { stroke: #333; stroke-width: 1; }
        .node-text { font-family: -apple-system, BlinkMacSystemFont, sans-serif; fill: white; text-anchor: middle; }
        .node-title { font-size: 14px; font-weight: bold; }
        .node-detail { font-size: 10px; }
        .connection { fill: none; stroke: #888; stroke-width: 2; }
      </style>
      <rect width="100%" height="100%" fill="#1e1e1e"/>
    
    """
    
    // Draw connections
    svg += "  <!-- Connections -->\n"
    for layer in layers {
      for node in layer {
        guard let sourceFrame = nodePositions[node.id] else { continue }
        let sourceCenter = CGPoint(x: sourceFrame.midX, y: sourceFrame.maxY)
        
        for child in node.connections {
          guard let destFrame = nodePositions[child.id] else { continue }
          let destCenter = CGPoint(x: destFrame.midX, y: destFrame.minY)
          
          let cp1 = CGPoint(x: sourceCenter.x, y: sourceCenter.y + 50)
          let cp2 = CGPoint(x: destCenter.x, y: destCenter.y - 50)
          
          svg += "  <path class=\"connection\" d=\"M \(Int(sourceCenter.x)) \(Int(sourceCenter.y)) C \(Int(cp1.x)) \(Int(cp1.y)), \(Int(cp2.x)) \(Int(cp2.y)), \(Int(destCenter.x)) \(Int(destCenter.y))\"/>\n"
        }
      }
    }
    
    // Draw nodes
    svg += "\n  <!-- Nodes -->\n"
    for layer in layers {
      for node in layer {
        guard let frame = nodePositions[node.id] else { continue }
        guard let baseNode = node as? BaseNode else { continue }
        
        let color = colorForLayer(baseNode.payload.layer)
        let title = baseNode.payload.layer.rawValue.uppercased()
        let detail = baseNode.payload.details
        let params = baseNode.payload.parameters
        
        svg += """
          <g transform="translate(\(Int(frame.minX)), \(Int(frame.minY)))">
            <rect class="node-rect" width="\(Int(frame.width))" height="\(Int(frame.height))" rx="8" fill="\(color)"/>
            <text class="node-text node-title" x="\(Int(frame.width/2))" y="20">\(title)</text>
            <text class="node-text node-detail" x="\(Int(frame.width/2))" y="38">\(detail)</text>
            <text class="node-text node-detail" x="\(Int(frame.width/2))" y="52">Parameters: \(params)</text>
          </g>
        
        """
      }
    }
    
    svg += "</svg>"
    return svg
  }
  
  private func colorForLayer(_ layer: EncodingType) -> String {
    switch layer {
    case .leakyRelu, .relu, .sigmoid, .tanh, .swish, .selu, .softmax:
      return "#339933" // green
    case .batchNormalize, .layerNormalize:
      return "#9980cc" // purple
    case .conv2d, .transConv2d:
      return "#0080cc" // blue
    case .dense:
      return "#cc6666" // red
    case .dropout:
      return "#b31ab3" // magenta
    case .flatten:
      return "#b366cc" // light purple
    case .maxPool, .avgPool:
      return "#e69933" // orange
    case .reshape:
      return "#cc99cc" // pink
    case .lstm, .embedding:
      return "#9966cc" // violet
    case .globalAvgPool:
      return "#e64d4d" // red-orange
    case .resNet:
      return "#4db34d" // bright green
    default:
      return "#808080" // gray
    }
  }
  
  func saveToFile() {
    let savePanel = NSSavePanel()
    savePanel.allowedContentTypes = [.svg]
    savePanel.nameFieldStringValue = "neural_network_graph.svg"
    savePanel.title = "Export Graph as SVG"
    
    savePanel.begin { response in
      if response == .OK, let url = savePanel.url {
        do {
          try generateSVG().write(to: url, atomically: true, encoding: .utf8)
        } catch {
          print("Failed to save SVG: \(error)")
        }
      }
    }
  }
}
