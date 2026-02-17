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

// MARK: - Exportable Graph View

struct ExportableGraphView: View {
  let layers: [[Node]]
  let nodePositions: [UUID: CGRect]
  let contentSize: CGSize
  
  // Offset to make room for the Network Summary card
  private let summaryCardWidth: CGFloat = 340
  
  // Create offset positions for export
  private var offsetPositions: [UUID: CGRect] {
    var offset: [UUID: CGRect] = [:]
    for (id, frame) in nodePositions {
      offset[id] = CGRect(
        x: frame.origin.x + summaryCardWidth,
        y: frame.origin.y,
        width: frame.width,
        height: frame.height
      )
    }
    return offset
  }
  
  var body: some View {
    ZStack(alignment: .topLeading) {
      // Background
      Color(NSColor.windowBackgroundColor)
      
      // Connection lines (drawn first, behind nodes) - using offset positions
      ConnectionLinesView(layers: layers, nodePositions: offsetPositions)
      
      // Nodes - positioned absolutely based on offset positions
      ForEach(layers.flatMap { $0 }, id: \.id) { node in
        if let frame = offsetPositions[node.id] {
          AnyView(node.build())
            .position(x: frame.midX, y: frame.midY)
        }
      }
      
      // Network Summary at top-left
      NetworkSummaryView(layers: layers.fullFlatten())
        .padding(16)
    }
    .frame(width: contentSize.width + summaryCardWidth + 50, height: max(contentSize.height + 50, 600))
  }
}

struct NetworkSummaryView: View {
  let layers: [Node]
  private let summaryColor = Color(red: 0.3, green: 0.5, blue: 0.8)
  
  var body: some View {
    CardView(style: .default(color: summaryColor)) {
      VStack(alignment: .leading, spacing: 0) {
        // Header
        CardHeader(
          icon: "chart.bar.doc.horizontal.fill",
          iconColor: summaryColor,
          title: "Network Summary",
          subtitle: "\(layers.count - 1) Layers"
        )
        
        CardDivider()
        
        // Stats grid
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
          CardStatItem(label: "Parameters", value: calculateTotalParameters(), icon: "number")
          CardStatItem(label: "Input", value: getInputShape(), icon: "arrow.down.circle")
          CardStatItem(label: "Output", value: getOutputClasses(), icon: "arrow.up.circle")
          CardStatItem(label: "Depth", value: "\(layers.count - 1)", icon: "square.stack.3d.up")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
      }
      .frame(width: 300)
    }
  }
  
  private func calculateTotalParameters() -> String {
    var total = 0
    for layer in layers {
      if let baseNode = layer as? BaseNode {
        total += baseNode.payload.parameters
      }
    }
    return formatNumber(total)
  }
  
  private func getInputShape() -> String {
    guard layers.count > 1, let firstLayer = layers[1] as? BaseNode else {
      return "—"
    }
    return formatTensorSize(firstLayer.payload.inputSize)
  }
  
  private func getOutputClasses() -> String {
    guard let lastLayer = layers.last as? BaseNode else {
      return "—"
    }
    return formatTensorSize(lastLayer.payload.outputSize)
  }
  
  private func formatTensorSize(_ size: TensorSize) -> String {
    let array = size.asArray
    if array.isEmpty || (array.count == 1 && array[0] == 0) {
      return "—"
    }
    if array.count == 1 {
      return "\(array[0])"
    }
    return array.map(String.init).joined(separator: "×")
  }
  
  private func formatNumber(_ number: Int) -> String {
    if number >= 1_000_000 {
      return String(format: "%.1fM", Double(number) / 1_000_000)
    } else if number >= 1_000 {
      return String(format: "%.1fK", Double(number) / 1_000)
    }
    return "\(number)"
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
    let layers = collectLayers(node: root)

    VStack(spacing: 0) {
      // Toolbar with export button
      HStack {
        Spacer()
        Button(action: exportPNG) {
          Label("Export PNG", systemImage: "photo")
        }
        .buttonStyle(.bordered)
        .padding(16)
      }
      
      HStack(alignment: .top) {
      // Network Summary - positioned at top leading
        NetworkSummaryView(layers: layers.fullFlatten())
        .padding(.leading, 100)
      
        ScrollView([.vertical]) {
          
          // Nodes
          VStack(alignment: .center, spacing: 60) {
            ForEach(0..<layers.count, id: \.self) { r in
              HStack(alignment: .top) {
                ForEach(0..<layers[r].count, id: \.self) { c in
                  let layer = layers[r][c]
                  
                  AnyView(layer.build())
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
          }
          .frame(minWidth: 0, maxWidth: .infinity, alignment: .top)
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
        .padding(.bottom, 16)

      }
    }
  }
  
  private func exportPNG() {
    let layers = collectLayers(node: root)
    let graphContent = ExportableGraphView(
      layers: layers,
      nodePositions: nodePositions,
      contentSize: contentSize
    )
    PNGExporter.exportView(graphContent)
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
