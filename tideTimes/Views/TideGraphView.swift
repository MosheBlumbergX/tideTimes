import SwiftUI

struct TideGraphView: View {
    let tideData: [TidePoint]
    let currentHeight: Double?
    let width: CGFloat
    let height: CGFloat
    
    // Calculate proper scaling for the graph
    private var heightRange: (min: Double, max: Double) {
        guard !tideData.isEmpty else { return (min: -2, max: 2) }
        
        let heights = tideData.map { $0.height }
        let minHeight = heights.min() ?? -2
        let maxHeight = heights.max() ?? 2
        
        // Safety check for valid height values
        guard minHeight.isFinite && maxHeight.isFinite && minHeight != maxHeight else {
            return (min: -2, max: 2)
        }
        
        // Add some padding for better visual appearance
        let padding = max(0.5, (maxHeight - minHeight) * 0.1)
        return (min: minHeight - padding, max: maxHeight + padding)
    }
    
    private var path: Path {
        Path { path in
            guard tideData.count > 1 else { return }
            
            var validPoints: [CGPoint] = []
            
            for (index, tidePoint) in tideData.enumerated() {
                // Safety check for valid height values
                guard tidePoint.height.isFinite else { continue }
                
                let x = CGFloat(index) * (width / CGFloat(tideData.count - 1))
                let normalizedHeight = (tidePoint.height - heightRange.min) / (heightRange.max - heightRange.min)
                
                // Safety check for valid normalized height
                guard normalizedHeight.isFinite && normalizedHeight >= 0 && normalizedHeight <= 1 else {
                    continue
                }
                
                let y = height - (normalizedHeight * height)
                validPoints.append(CGPoint(x: x, y: y))
            }
            
            guard validPoints.count > 1 else { return }
            
            path.move(to: validPoints[0])
            for point in validPoints.dropFirst() {
                path.addLine(to: point)
            }
        }
    }
    
    private var currentPosition: CGPoint? {
        guard let currentHeight = currentHeight,
              currentHeight.isFinite,
              let currentIndex = tideData.firstIndex(where: { $0.dateTime >= Date() }) else {
            return nil
        }
        
        let x = CGFloat(currentIndex) * (width / CGFloat(tideData.count - 1))
        let normalizedHeight = (currentHeight - heightRange.min) / (heightRange.max - heightRange.min)
        
        // Safety check for valid normalized height
        guard normalizedHeight.isFinite && normalizedHeight >= 0 && normalizedHeight <= 1 else {
            return nil
        }
        
        let y = height - (normalizedHeight * height)
        return CGPoint(x: x, y: y)
    }
    
    var body: some View {
        ZStack {
            // Background grid with dynamic height labels
            VStack(spacing: 0) {
                ForEach(0..<5) { i in
                    Divider()
                        .background(Color.seaside.driftwoodGray.opacity(0.3))
                    Spacer()
                }
            }
            
            // Tide curve
            path
                .stroke(Color.seaside.oceanBlue, lineWidth: 3)
                .shadow(color: .seaside.oceanBlue.opacity(0.3), radius: 2, x: 0, y: 1)
            
            // Current position indicator
            if let position = currentPosition {
                Circle()
                    .fill(Color.seaside.coralAccent)
                    .frame(width: 12, height: 12)
                    .shadow(color: .seaside.coralAccent.opacity(0.5), radius: 4, x: 0, y: 2)
                    .position(position)
            }
            
            // Dynamic height labels based on actual data
            VStack {
                Text(String(format: "%.1fm", heightRange.max))
                    .font(.caption2)
                    .foregroundColor(.seaside.secondaryText)
                Spacer()
                Text(String(format: "%.1fm", (heightRange.max + heightRange.min) / 2))
                    .font(.caption2)
                    .foregroundColor(.seaside.secondaryText)
                Spacer()
                Text(String(format: "%.1fm", heightRange.min))
                    .font(.caption2)
                    .foregroundColor(.seaside.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 8)
        }
        .frame(width: width, height: height)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
