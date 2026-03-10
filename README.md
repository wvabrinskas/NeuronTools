# NeuronTools

A macOS toolkit for analyzing, visualizing, and experimenting with neural networks built with the [Neuron](https://github.com/wvabrinskas/Neuron) machine learning framework.

## Overview

NeuronTools is a native macOS app that provides a suite of developer tools for inspecting, visualizing, and experimenting with Neuron models. A launcher UI lets you pick from three tools: **Visualizer**, **Model Playground**, and **Quantizer**.

## Tools

### 🔍 Visualizer
Import a Neuron model (`.smodel`) via drag-and-drop and get:

- **Interactive network graph** — layer-by-layer architecture visualization with curved Bézier connections
- **Color-coded layer types** — Dense (red), Conv2d (blue), Activation (green), BatchNorm (purple), Dropout (magenta), Pooling (orange), LSTM/Embedding (violet), ResNet, and more
- **Detailed layer nodes** — each node shows layer type, input/output shapes, and parameter counts
- **Convolutional filter visualization** — Conv2d nodes display filter weight heatmaps and support drag-and-drop image previews to see filter activations
- **Network summary** — total parameters, layer count, input shape, and output size
- **SVG export** — export the full network graph as an SVG file
- **Model description** — raw `debugDescription` output from the compiled network

### 🧪 Model Playground
An interactive environment for experimenting with Neuron models. Supports three model types, selectable via dropdown:

- **Classifier** — Drag-and-drop a `.smodel` file, configure the number of classes and input size, then drop an image to get a class prediction and confidence score.
- **GAN** — Drag-and-drop a generator `.smodel` file and generate images from random noise.
- **RNN** — Drag-and-drop a `.smodel` and a `.stokens` file, then generate text sequences from a starting character with configurable generation count and max word length.

### ⚖️ Quantizer
[WIP][Not usable] Will be used to convert a model between numerical types.

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

```bash
git clone https://github.com/wvabrinskas/NeuronTools.git
cd NeuronTools
open NeuronTools.xcodeproj
```

Build and run the `NeuronTools` target in Xcode.

## Usage

1. Launch the app — a launcher window presents the three available tools
2. Select a tool to open its window:
   - **Visualizer** — Drag a `.smodel` file onto the drop zone to render the network graph. Inspect layer details, view filter activations for Conv2d layers, and export the graph as SVG.
   - **Model Playground** — Select a model type (Classifier, GAN, or RNN), drag in the required model file(s), configure parameters, and run inference interactively.
   - **Quantizer** — Drag a `.smodel` file to inspect its structure and debug description.

## Project Structure

```
NeuronTools/
├── NeuronTools.xcodeproj/
└── NeuronTools/
    ├── App/
    │   └── NeuronToolsApp.swift              # App entry point; declares all tool windows
    ├── Models/
    │   └── ToolDefinition.swift              # Tool registry (Visualizer, Playground, Quantizer)
    ├── Views/
    │   └── LauncherView.swift                # Main launcher grid UI
    ├── Tools/
    │   ├── Visualizer/
    │   │   └── Views/
    │   │       └── VisualizerView.swift      # Drag-and-drop model visualization
    │   ├── ModelPlayground/
    │   │   ├── ModelType.swift               # Classifier / GAN / RNN enum + dropdown mapping
    │   │   ├── ClassifierTypeParameters.swift
    │   │   ├── GANViewParameters.swift
    │   │   ├── RNNViewParameters.swift
    │   │   └── Views/
    │   │       ├── ModelPlaygroundView.swift  # Playground host view
    │   │       ├── ClassifierResultView.swift
    │   │       ├── GANResultView.swift
    │   │       ├── RNNResultView.swift
    │   │       └── GenerateButton.swift
    │   └── Quantizer/
    │       └── Views/
    │           └── QuantizerView.swift        # Model quantization view
    └── Shared/
        ├── ModelDropModule.swift              # DropDelegate; builds graph + handles inference
        ├── ModelDropViewModel.swift           # Observable state for all tool views
        ├── Modules/
        │   ├── Builder.swift                  # Async model import and compilation
        │   ├── ImageDropModule.swift          # Image drag-and-drop handling
        │   └── ImageDropView.swift            # Reusable image drop view component
        ├── Nodes/
        │   ├── Node.swift                     # Node protocol + BaseNode + layer color mapping
        │   ├── GraphView.swift                # Graph rendering, connections, SVG export
        │   ├── InputLayerNode.swift           # Input layer visualization
        │   ├── DetailedLayerNode.swift        # Standard layer node with details
        │   ├── DetailedActivationLayerNode.swift
        │   └── ImageVisualizationLayerNode.swift  # Conv2d filter + image preview node
        └── Utilities/
            ├── NSImage+Extensions.swift
            ├── PNGExporter.swift
            ├── SVGExporter.swift
            └── SeededRandomNumberGenerator.swift
```

## License

MIT License — see the [LICENSE](LICENSE) file for details.
