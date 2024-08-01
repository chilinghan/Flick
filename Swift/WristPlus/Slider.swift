import UIKit

class Slider: UISlider {
    var thumbImage: UIImage?

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let thumbImage = thumbImage {
            let thumbSize = CGSize(width: 45, height: 45) // Set desired thumb size
            let resizedImage = UIGraphicsImageRenderer(size: thumbSize).image { _ in
                thumbImage.draw(in: CGRect(origin: .zero, size: thumbSize))
            }
            self.setThumbImage(resizedImage, for: .normal)
        }
    }
}
