# NeuronTools

A macOS toolkit for analyzing and visualizing neural networks built with the [Neuron](https://github.com/wvabrinskas/Neuron) machine learning framework.

## Overview

NeuronTools is a native macOS app that provides a suite of developer tools for inspecting, visualizing, and experimenting with Neuron models. It features a launcher UI that lets you pick from available tools, with the **Visualizer** as the primary tool and a **Model Playground** in development.

## Tools

### 🔍 Visualizer
Import a Neuron model (JSON) via drag-and-drop and get:

- **Interactive network graph** — layer-by-layer architecture visualization with curved Bézier connections
- **Color-coded layer types** — Dense (red), Conv2d (blue), Activation (green), BatchNorm (purple), Dropout (magenta), Pooling (orange), LSTM/Embedding (violet), ResNet, and more
- **Detailed layer nodes** — each node shows layer type, input/output shapes, and parameter counts
- **Convolutional filter visualization** — Conv2d nodes display filter weight heatmaps and support drag-and-drop image previews to see filter activations
- **Network summary** — total parameters, layer count, input shape, and output size
- **SVG export** — export the full network graph as an SVG file
- **Model description** — raw `debugDescription` output from the compiled network

### 🧪 Model Playground
*Coming soon* — an interactive environment for experimenting with models.

## Dependencies

- **[Neuron](https://github.com/wvabrinskas/Neuron)** (develop) — Core ML framework providing model architecture, layers, and visualization APIs
- **[NumSwift](https://github.com/wvabrinskas/NumSwift)** (main) — Numerical computing and tensor operations
- **[Logger](https://github.com/wvabrinskas/Logger)** (1.0.6+) — Structured logging
- **[Swift Numerics](https://github.com/apple/swift-numerics)** (1.0.0+) — Numerical stability and math operations

## Requirements

- macOS 14.0+
- Swift 5.10+
- Xcode 16.0+

## Building

The project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) with `project.yml` to generate the Xcode project.

```bash
git clone https://github.com/wvabrinskas/NeuronTools.git
cd NeuronTools
xcodegen generate   # regenerate .xcodeproj if needed
open NeuronTools.xcodeproj
```

Build and run the `NeuronTools` target in Xcode.

## Usage

1. Launch the app — a launcher window presents the available tools
2. Select **Visualizer** to open the visualization window
3. Drag a Neuron model JSON file onto the drop zone
4. Explore the rendered network graph, inspect layer details, and view the model description
5. For Conv2d layers, expand filter visualizations and drop images to preview filter activations
6. Click **Export SVG** to save the graph

## Project Structure

```
NeuronTools/
├── project.yml                          # XcodeGen project definition
├── Sources/NeuronTools/
│   ├── App/
│   │   └── NeuronToolsApp.swift         # App entry point with launcher + tool windows
│   ├── Models/
│   │   └── ToolDefinition.swift         # Tool registry (Visualizer, Model Playground)
│   ├── Views/
│   │   └── LauncherView.swift           # Main launcher UI
│   ├── Tools/
│   │   ├── Visualizer/
│   │   │   └── Views/
│   │   │       └── VisualizerView.swift # Drag-and-drop model visualization
│   │   └── ModelPlayground/
│   │       └── Views/
│   │           └── ModelPlaygroundView.swift
│   └── Shared/
│       ├── GraphViewModel.swift         # Observable state for the graph view
│       ├── GraphViewDropModule.swift     # Drop delegate that builds the graph from a model
│       ├── Nodes/
│       │   ├── Node.swift               # Node protocol + BaseNode + layer color mapping
│       │   ├── GraphView.swift          # Graph rendering, connections, SVG export
│       │   ├── InputLayerNode.swift     # Input layer visualization
│       │   ├── DetailedLayerNode.swift  # Standard layer node with details
│       │   ├── DetailedActivationLayerNode.swift
│       │   └── ImageVisualizationLayerNode.swift  # Conv2d filter + image preview node
│       ├── Modules/
│       │   ├── Builder.swift            # Async model import and compilation
│       │   ├── ImageDropModule.swift    # Image drag-and-drop handling
│       │   └── ImageDropView.swift      # Reusable image drop view component
│       └── Utilities/
│           ├── NSImage+Extensions.swift
│           └── SeededRandomNumberGenerator.swift
```

## License

MIT License — see the [LICENSE](LICENSE) file for details.
