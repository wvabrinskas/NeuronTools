//
//  GraphView.swift
//  Neuron
//
//  Created by William Vabrinskas on 10/7/24.
//

import SwiftUI
import Neuron
import AppKit

struct NodePositionPreferenceKey: PreferenceKey {
  static var defaultValue: [UUID: CGRect] = [:]
  static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
    value.merge(nextValue()) { $1 }
  }
}

struct ContentSizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    let next = nextValue()
    value = CGSize(width: max(value.width, next.width), height: max(value.height, next.height))
  }
}

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

struct ConnectionLinesView: View {
  let layers: [[Node]]
  let nodePositions: [UUID: CGRect]
  
  var body: some View {
    Path { path in
      for layer in layers {
        for node in layer {
          guard let sourceFrame = nodePositions[node.id] else { continue }
          let sourceCenter = CGPoint(
            x: sourceFrame.midX,
            y: sourceFrame.maxY
          )
          
          for child in node.connections {
            guard let destFrame = nodePositions[child.id] else { continue }
            let destCenter = CGPoint(
              x: destFrame.midX,
              y: destFrame.minY
            )
            
            path.move(to: sourceCenter)
            
            // Curved Bezier line
            let controlPoint1 = CGPoint(x: sourceCenter.x, y: sourceCenter.y + 50)
            let controlPoint2 = CGPoint(x: destCenter.x, y: destCenter.y - 50)
            path.addCurve(to: destCenter, control1: controlPoint1, control2: controlPoint2)
          }
        }
      }
    }
    .stroke(Color.gray, lineWidth: 2)
  }
}

struct GraphView: View {
  let root: Node
  @State private var nodePositions: [UUID: CGRect] = [:]
  @State private var contentSize: CGSize = .zero
  
  init(root: Node) {
    self.root = root
  }
  
  var body: some View {
    VStack(spacing: 0) {
      // Toolbar with export button
      HStack {
        Spacer()
        Button(action: exportSVG) {
          Label("Export SVG", systemImage: "square.and.arrow.up")
        }
        .buttonStyle(.bordered)
        .padding(16)
      }
      
      ScrollView([.horizontal, .vertical]) {
        let layers = collectLayers(node: root)
        
        // Nodes
        VStack(alignment: .center, spacing: 60) {
          ForEach(0..<layers.count, id: \.self) { r in
            HStack(alignment: .top) {
              ForEach(0..<layers[r].count, id: \.self) { c in
                let layer = layers[r][c]
                
                AnyView(layer.build())
                  .padding()
                  .background(
                    GeometryReader { geo in
                      Color.clear.preference(
                        key: NodePositionPreferenceKey.self,
                        value: [layer.id: geo.frame(in: .named("graph"))]
                      )
                    }
                  )
              }
            }
          }
          
          // Network Summary footer
          VStack(alignment: .center, spacing: 8) {
            Text("Network Summary")
              .font(.system(size: 16, weight: .bold))
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .background(Color(red: 0.3, green: 0.5, blue: 0.8))
            
            VStack(alignment: .leading, spacing: 4) {
              let totalParams = calculateTotalParameters(layers: layers.fullFlatten())
              Text("Total Parameters: \(totalParams)")
                .font(.system(size: 12, weight: .medium))
              Text("Layers: \(layers.count - 1)") // Subtract 1 for root node
                .font(.system(size: 12, weight: .medium))
              Text("Input Shape: \(getInputShape(layers: layers.fullFlatten()))")
                .font(.system(size: 12, weight: .medium))
              Text("Output size: \(getOutputClasses(layers: layers.fullFlatten()))")
                .font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(NSColor.controlBackgroundColor))
          }
          .frame(width: 280)
          .overlay(
            Rectangle()
              .stroke(Color.secondary, lineWidth: 1)
          )
          .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
          .padding(.top, 16)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding()
        .background(
          GeometryReader { geo in
            Color.clear.preference(key: ContentSizePreferenceKey.self, value: geo.size)
          }
        )
        .background(
          // Draw connection lines behind nodes
          ConnectionLinesView(layers: layers, nodePositions: nodePositions)
        )
        .coordinateSpace(name: "graph")
        .onPreferenceChange(NodePositionPreferenceKey.self) { positions in
          nodePositions = positions
        }
        .onPreferenceChange(ContentSizePreferenceKey.self) { size in
          contentSize = size
        }
      }
    }
  }
  
  private func exportSVG() {
    let layers = collectLayers(node: root)
    let exporter = SVGExporter(layers: layers, nodePositions: nodePositions, contentSize: contentSize)
    exporter.saveToFile()
  }
  
  func collectLayers(node: Node) -> [[Node]] {
    var visited: Set<UUID> = [node.id]
    return [[node]] + collectLayersHelper(node: node, visited: &visited)
  }
  
  private func collectLayersHelper(node: Node, visited: inout Set<UUID>) -> [[Node]] {
    var layers: [[Node]] = []
    
    // Filter out already visited nodes from connections
    let unvisitedConnections = node.connections.filter { !visited.contains($0.id) }
    
    if !unvisitedConnections.isEmpty {
      layers.append(unvisitedConnections)
      
      // Mark these nodes as visited
      for child in unvisitedConnections {
        visited.insert(child.id)
      }
      
      for child in unvisitedConnections {
        layers.append(contentsOf: collectLayersHelper(node: child, visited: &visited))
      }
    }
    
    return layers
  }
  
  func calculateTotalParameters(layers: [Node]) -> String {
    var total = 0
    for layer in layers {
      if let baseNode = layer as? BaseNode {
        total += baseNode.payload.parameters
      }
    }
    return formatNumber(total)
  }
  
  func getInputShape(layers: [Node]) -> String {
    guard layers.count > 1, let firstLayer = layers[1] as? BaseNode else {
      return "Unknown"
    }
    return formatTensorSize(firstLayer.payload.inputSize)
  }
  
  func getOutputClasses(layers: [Node]) -> String {
    guard let lastLayer = layers.last as? BaseNode else {
      return "Unknown"
    }
    return formatTensorSize(lastLayer.payload.outputSize)
  }
  
  func formatTensorSize(_ size: TensorSize) -> String {
    let array = size.asArray
    if array.count <= 1 {
      return "\(array.first ?? 0)"
    }
    return array.map(String.init).joined(separator: "×")
  }
  
  func formatNumber(_ number: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
  }
}


struct GraphView_Previews: PreviewProvider {
  
  // private let root: any Node =
  
  static var previews: some View {
    GraphView(root: buildNode())
      .frame(width: 800, height: 800)
  }
  
  static func buildNode() -> Node {
    let root = InputLayerNode(payload: .init(layer: .dense,
                                             outputSize: .init(),
                                             inputSize: .init(),
                                             parameters: 100,
                                             details: "Test",
                                             weights: [],
                                             weightsSize: .init()))
    
    let dense = DetailedLayerNode(payload: .init(layer: .dense,
                                                 outputSize: .init(),
                                                 inputSize: .init(),
                                                 parameters: 100,
                                                 details: "Test",
                                                 weights: [],
                                                 weightsSize: .init()))
    
    let activationNode1 = DetailedActivationLayerNode(payload: .init(layer: .relu,
                                                                     outputSize: .init(),
                                                                     inputSize: .init(),
                                                                     parameters: 0,
                                                                     details: "Activation",
                                                                     weights: [],
                                                                     weightsSize: .init()))
    
    let conv2d = DetailedLayerNode(payload: .init(layer: .conv2d,
                                                  outputSize: .init(),
                                                  inputSize: .init(),
                                                  parameters: 0,
                                                  details: "Activation",
                                                  weights: [],
                                                  weightsSize: .init()))
    
    let batch = DetailedLayerNode(payload: .init(layer: .batchNormalize,
                                                 outputSize: .init(),
                                                 inputSize: .init(),
                                                 parameters: 0,
                                                 details: "Activation",
                                                 weights: [],
                                                 weightsSize: .init()))
    
    let activationNode2 = DetailedActivationLayerNode(payload: .init(layer: .relu,
                                                                     outputSize: .init(),
                                                                     inputSize: .init(),
                                                                     parameters: 0,
                                                                     details: "Activation",
                                                                     weights: [],
                                                                     weightsSize: .init()))
    
    root.connections = [dense]
    
    dense.connections = [activationNode1, conv2d]
    
    activationNode1.connections = [batch]
    conv2d.connections = [batch]
    
    batch.connections = [activationNode2]
    
    
    return root
  }
}
