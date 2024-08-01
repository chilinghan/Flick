import SwiftUI

struct StepwiseSlider: View {
    @Binding var value: Double
    let circleSizeRange: ClosedRange<CGFloat>
    let sliderRange: ClosedRange<Double>
    
    @State private var isEditing: Bool = false

    var stepSize: Double {
        return 1.0
    }
    
    var numberOfSteps: Int {
        Int((sliderRange.upperBound - sliderRange.lowerBound) / stepSize) + 1
    }
    
    var body: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width
            let stepWidth = trackWidth / CGFloat(numberOfSteps - 1)
            
            VStack {
                ZStack(alignment: .leading) {
                    // Track
                    Rectangle()
                        .fill(.lightBl)
                        .frame(height: 3)
                    
                    // Circles
                    HStack(spacing: stepWidth - 13) {
                        ForEach(0..<numberOfSteps, id: \.self) { index in
                            Circle()
                                .fill(.lightBl)
                                .frame(width: circleSize(for: index), height: circleSize(for: index))
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                isEditing = true
                                let newValue = max(0, min(1, gesture.location.x / trackWidth))
                                value = sliderRange.lowerBound + round(newValue * Double(numberOfSteps - 1)) * stepSize
                            }
                            .onEnded { _ in
                                isEditing = false
                            }
                    )
                }
                
                // Min and Max Value Labels
                HStack {
                    Text("0")
                    Spacer()
                    Text("10")
                }
                .padding(.horizontal)
                
                // Display Current Value
                Text("\(value, specifier: "%.2f")")
                    .foregroundColor(isEditing ? .white : Color("LightBl"))
            }

        }
        .frame(height: circleSizeRange.upperBound)

    }
    
    private func circleSize(for index: Int) -> CGFloat {
        let stepValue = sliderRange.lowerBound + Double(index) * stepSize
        let diff = abs(value - stepValue)
        return max(circleSizeRange.lowerBound, circleSizeRange.upperBound * (1 - diff / stepSize))
    }
}
