# NeuronTools

A comprehensive toolkit for analyzing and visualizing neural networks built with the Neuron machine learning framework. This project provides powerful tools to help developers understand, debug, and optimize their machine learning models through intuitive visual representations.

## Overview

NeuronTools is a macOS application that transforms complex neural network architectures into clear, interactive visualizations. Built with SwiftUI and integrated with the Neuron framework, it offers a seamless way to inspect model structures, analyze layer configurations, and understand network flows.

## Features

### 🎨 Visual Network Architecture
- **Interactive Network Graphs**: Visualize complete neural network architectures with layer-by-layer breakdown
- **Layer Type Recognition**: Color-coded representation of different layer types (Dense, Convolution, Activation, etc.)
- **Network Flow Visualization**: Clear arrows showing data flow through the network

### 📊 Comprehensive Model Analysis
- **Parameter Count**: Automatic calculation of total trainable parameters
- **Layer Details**: Detailed information about each layer including input/output shapes
- **Network Statistics**: Summary of network depth, input dimensions, and output classes
- **Model Metadata**: Display of model configuration and properties

### 🔧 Easy Model Import
- **Drag & Drop Interface**: Simple drag-and-drop functionality for importing model files
- **JSON Model Support**: Direct import of Neuron framework model files
- **Real-time Processing**: Asynchronous model loading with progress indicators

### 🎯 Developer-Friendly Features
- **Modern macOS UI**: Native SwiftUI interface with dark mode support
- **Responsive Design**: Scrollable views for large networks
- **Error Handling**: Comprehensive error messages and validation

## Dependencies

This project leverages several powerful Swift packages to provide comprehensive machine learning analysis:

### Core Dependencies

- **[Neuron](https://github.com/wvabrinskas/Neuron)** (visualizer branch)
  - The core machine learning framework for building and training neural networks
  - Provides model architecture definitions and layer implementations
  - Includes specialized visualization APIs for model introspection

- **[NumSwift](https://github.com/wvabrinskas/NumSwift)** (main branch)
  - High-performance numerical computing library for Swift
  - Provides tensor operations and mathematical functions
  - Essential for model data processing and analysis

- **[Logger](https://github.com/wvabrinskas/Logger)** (v1.0.6+)
  - Lightweight logging framework for debugging and monitoring
  - Provides structured logging for model loading and processing
  - Includes configurable log levels and output formatting

- **[Swift Numerics](https://github.com/apple/swift-numerics)** (v1.0.0+)
  - Apple's official numerical computing library
  - Provides fundamental mathematical operations and complex number support
  - Ensures numerical stability and performance optimization

## Installation

### Requirements
- macOS 14.0 or later
- Swift 5.10 or later
- Xcode 15.0 or later

### Building from Source

1. **Clone the repository:**
```bash
git clone https://github.com/your-username/NeuronTools.git
cd NeuronTools
```

2. **Build the project:**
```bash
swift build
```

3. **Run the visualizer:**
```bash
swift run Visualizer
```

### Package Manager Integration

Add NeuronTools to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/NeuronTools.git", from: "1.0.0")
]
```

## Usage

### Basic Usage

1. **Launch the Application**
   - Run the NeuronVisualizer executable
   - A window will open with a drag-and-drop interface

2. **Import Your Model**
   - Drag a JSON file containing your Neuron model into the application
   - The model will be processed and validated automatically

3. **Explore the Visualization**
   - View the complete network architecture
   - Examine individual layer properties
   - Analyze network statistics and parameters

### Supported Model Formats

NeuronTools currently supports models saved in JSON format from the Neuron framework. Models should contain:

- Complete layer definitions
- Weight and bias information
- Input/output shape specifications
- Model configuration parameters

### Example Model Structure

```json
{
  "layers": [
    {
      "type": "dense",
      "inputSize": [784],
      "outputSize": [128],
      "weights": [...],
      "bias": [...]
    },
    {
      "type": "activation",
      "function": "relu"
    }
  ]
}
```

## Architecture

### Core Components

- **NeuronVisualizer**: Main executable target providing the visualization interface
- **GraphView**: Core visualization component for rendering network graphs
- **Node System**: Flexible node-based architecture for representing different layer types
- **Builder**: Model processing and validation engine
- **MainView**: Primary user interface with drag-and-drop functionality

### Visualization Features

- **Layer Nodes**: Different visual representations for various layer types
- **Connection Arrows**: Visual indicators showing data flow
- **Parameter Display**: Real-time parameter count and statistics
- **Interactive Elements**: Expandable layer details and properties

## Development

### Project Structure

```
NeuronTools/
├── Package.swift                 # Package configuration
├── Sources/
│   ├── NeuronTools/             # Core library (placeholder)
│   └── NeuronVisualizer/        # Visualization application
│       ├── main.swift           # Application entry point
│       ├── App/
│       │   ├── AppDelegate.swift
│       │   ├── Views/
│       │   │   ├── MainView.swift
│       │   │   ├── GraphView.swift
│       │   │   └── Nodes/       # Layer visualization components
│       │   └── Modules/
│       │       ├── Builder.swift
│       │       └── MainViewDropModule.swift
│       └── Resources/           # Assets and resources
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Implement your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with Apple's SwiftUI framework
- Powered by the Neuron machine learning framework
- Numerical computing provided by NumSwift and Swift Numerics
- Logging capabilities provided by the Logger framework

---

For more information about the Neuron framework and its capabilities, visit the [Neuron GitHub repository](https://github.com/wvabrinskas/Neuron).