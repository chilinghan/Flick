import SwiftUI

struct CustomSlider: UIViewRepresentable {
    @Binding var value: Double
    var minValue: Double
    var maxValue: Double
    var step: Double
    var thumbColor: Color
    var trackColor: Color
    var trackBackgroundColor: Color

    func makeUIView(context: Context) -> Slider {
        let slider = Slider()
        slider.minimumValue = Float(minValue)
        slider.maximumValue = Float(maxValue)
        slider.value = Float(value)
        slider.isContinuous = false // Disable continuous updates to handle stepping manually
        slider.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        slider.minimumTrackTintColor = UIColor(trackColor) // Convert Color to UIColor
        slider.maximumTrackTintColor = UIColor(trackBackgroundColor) // Convert Color to UIColor
        slider.thumbImage = UIImage(systemName: "circle.fill") // Use a system image for the thumb
        return slider
    }

    func updateUIView(_ uiView: Slider, context: Context) {
        uiView.value = Float(value)
        uiView.minimumTrackTintColor = UIColor(trackColor)
        uiView.maximumTrackTintColor = UIColor(trackBackgroundColor)
        uiView.thumbImage = UIImage(systemName: "circle.fill") // Update thumb image if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(value: $value, step: step)
    }

    class Coordinator: NSObject {
        var value: Binding<Double>
        var step: Double

        init(value: Binding<Double>, step: Double) {
            self.value = value
            self.step = step
        }

        @objc func valueChanged(_ sender: UISlider) {
            let roundedValue = round(sender.value / Float(step)) * Float(step)
            value.wrappedValue = Double(roundedValue)
        }
    }
}

extension UIColor {
    convenience init(_ color: Color) {
        let components = color.cgColor?.components ?? [0, 0, 0, 1]
        self.init(red: components[0], green: components[1], blue: components[2], alpha: components[3])
    }
}
