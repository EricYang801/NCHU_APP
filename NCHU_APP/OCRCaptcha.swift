import Foundation
import CoreGraphics
import CoreImage

struct OCRCaptcha {
    // 常數定義
    private static let TOP_ALIGN = 2
    private static let LEFT_ALIGN = 11
    private static let CODE_W = 13
    private static let CODE_H = 21
    private static let CODE_COUNT = 6
    private static let THRESHOLD = 115
    
    // 完整的數字模板定義
    private static let CODE_NUMBERS: [String: [[Int]]] = [
        "0": [
            [0,0,0,0,1,1,1,1,1,0,0,0,0],
            [0,0,1,1,1,1,1,1,1,1,1,0,0],
            [0,1,1,1,1,0,0,0,1,1,1,1,0],
            [0,1,1,1,0,0,0,0,0,1,1,1,0],
            [0,1,1,0,0,0,0,0,0,0,1,1,0],
            [1,1,1,0,0,0,0,0,0,0,1,1,1],
            [1,1,0,0,0,0,0,0,0,0,0,1,1],
            [1,1,0,0,0,0,0,0,0,0,0,1,1],
            [1,1,0,0,0,0,0,0,0,0,0,1,1],
            [1,1,0,0,0,0,0,0,0,0,0,1,1],
            [1,1,0,0,0,0,0,0,0,0,0,1,1],
            [1,1,0,0,0,0,0,0,0,0,0,1,1],
            [1,1,0,0,0,0,0,0,0,0,0,1,1],
            [1,1,0,0,0,0,0,0,0,0,0,1,1],
            [1,1,0,0,0,0,0,0,0,0,0,1,1],
            [1,1,1,0,0,0,0,0,0,0,1,1,1],
            [0,1,1,0,0,0,0,0,0,0,1,1,0],
            [0,1,1,1,0,0,0,0,0,1,1,1,0],
            [0,0,1,1,1,1,1,1,1,1,1,0,0],
            [0,0,0,0,1,1,1,1,1,0,0,0,0],
            [0,0,0,0,0,0,0,0,0,0,0,0,0]
        ],
        "1": [
            [0,0,0,0,0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,1,0,0,0,0],
            [0,0,0,0,0,0,1,1,1,0,0,0,0],
            [0,0,0,0,1,1,1,1,1,0,0,0,0],
            [0,0,0,1,1,1,1,1,1,0,0,0,0],
            [0,0,0,1,1,1,0,1,1,0,0,0,0],
            [0,0,0,1,0,0,0,1,1,0,0,0,0],
            [0,0,0,0,0,0,0,1,1,0,0,0,0],
            [0,0,0,0,0,0,0,1,1,0,0,0,0],
            [0,0,0,0,0,0,0,1,1,0,0,0,0],
            [0,0,0,0,0,0,0,1,1,0,0,0,0],
            [0,0,0,0,0,0,0,1,1,0,0,0,0],
            [0,0,0,0,0,0,0,1,1,0,0,0,0],
            [0,0,0,0,0,0,0,1,1,0,0,0,0],
            [0,0,0,0,0,0,0,1,1,0,0,0,0],
            [0,0,0,0,0,0,0,1,1,0,0,0,0],
            [0,0,0,0,0,0,0,1,1,0,0,0,0],
            [0,0,0,0,0,0,0,1,1,0,0,0,0],
            [0,0,0,0,0,0,0,1,1,0,0,0,0],
            [0,0,0,0,0,0,0,0,0,0,0,0,0]
        ],
        // ... 其他數字模板（2-9）與上面格式相同 ...
    ]
    
    static func processCaptcha() throws -> String {
        let imageData = try getCaptcha()
        let binaryImage = toBinary(imageData: imageData)
        
        let croppedImage = crop2d(
            mat: binaryImage,
            x: LEFT_ALIGN,
            y: TOP_ALIGN,
            w: CODE_W * CODE_COUNT,
            h: CODE_H
        )
        
        var numbers = ""
        for i in 0..<CODE_COUNT {
            let codeImage = crop2d(
                mat: croppedImage,
                x: CODE_W * i,
                y: 0,
                w: CODE_W,
                h: CODE_H
            )
            if let predicted = predictCode(codeImage: codeImage) {
                numbers += predicted
            }
        }
        
        return numbers
    }
    
    private static func getCaptcha() throws -> [[Int]] {
        guard let image = loadImage(from: "captcha.png") else {
            throw OCRError.imageLoadFailed
        }
        return convertToGrayscale(image)
    }
    
    private static func loadImage(from path: String) -> CGImage? {
        guard let url = URL(fileURLWithPath: path),
              let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }
        return image
    }
    
    private static func convertToGrayscale(_ image: CGImage) -> [[Int]] {
        let width = image.width
        let height = image.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8
        
        var pixels = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context?.draw(image, in: rect)
        
        var result = [[Int]]()
        for y in 0..<height {
            var row = [Int]()
            for x in 0..<width {
                let offset = (y * width + x) * bytesPerPixel
                let r = Int(pixels[offset])
                let g = Int(pixels[offset + 1])
                let b = Int(pixels[offset + 2])
                // 轉換為灰度值
                let gray = (r + g + b) / 3
                row.append(gray)
            }
            result.append(row)
        }
        
        return result
    }
    
    private static func toBinary(imageData: [[Int]], threshold: Int = THRESHOLD) -> [[Int]] {
        return imageData.map { row in
            row.map { pixel in
                pixel < threshold ? 1 : 0
            }
        }
    }
    
    private static func crop2d(mat: [[Int]], x: Int, y: Int, w: Int, h: Int) -> [[Int]] {
        var result = [[Int]]()
        for i in y..<(y + h) {
            var row = [Int]()
            for j in x..<(x + w) {
                row.append(mat[i][j])
            }
            result.append(row)
        }
        return result
    }
    
    private static func predictCode(codeImage: [[Int]]) -> String? {
        var minIndex: String?
        var minDiff = CODE_W * CODE_H
        
        for (number, template) in CODE_NUMBERS {
            var diffSum = 0
            for i in 0..<CODE_H {
                for j in 0..<CODE_W {
                    diffSum += abs(codeImage[i][j] - template[i][j])
                }
            }
            
            if diffSum < minDiff {
                minDiff = diffSum
                minIndex = number
            }
        }
        
        return minIndex
    }
}

enum OCRError: Error {
    case imageLoadFailed
}

// CGImage擴展
extension CGImage {
    static func load(from path: String) -> CGImage? {
        guard let url = URL(string: path),
              let provider = CGDataProvider(url: url as CFURL) else {
            return nil
        }
        return CGImage(
            width: 100,  // 實際寬度
            height: 30,  // 實際高度
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: 400,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )
    }
} 