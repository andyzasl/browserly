import Cocoa

let iconsetDir = URL(fileURLWithPath: "AppIcon.iconset")
try? FileManager.default.createDirectory(at: iconsetDir, withIntermediateDirectories: true)

func createIcon(size: Int, scale: Int) {
    let pointSize = CGFloat(size)
    let pixelSize = size * scale
    
    let image = NSImage(size: NSSize(width: pointSize, height: pointSize))
    
    image.lockFocus()
    
    // Background: Apple style rounded rect
    let padding = pointSize * 0.1
    let rect = NSRect(x: padding, y: padding, width: pointSize - padding*2, height: pointSize - padding*2)
    let radius = (pointSize - padding*2) * 0.22 // standard macOS icon rounding
    let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
    
    // Blue gradient (similar to Safari/link theme)
    let color1 = NSColor(calibratedRed: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
    let color2 = NSColor(calibratedRed: 0.0, green: 0.35, blue: 0.85, alpha: 1.0)
    let gradient = NSGradient(starting: color1, ending: color2)
    gradient?.draw(in: path, angle: -90)
    
    // Link Symbol
    if let symbol = NSImage(systemSymbolName: "link", accessibilityDescription: nil) {
        let config = NSImage.SymbolConfiguration(pointSize: pointSize * 0.45, weight: .bold)
            .applying(.init(hierarchicalColor: .white))
        
        if let configured = symbol.withSymbolConfiguration(config) {
            let symbolSize = configured.size
            let origin = NSPoint(x: (pointSize - symbolSize.width) / 2, y: (pointSize - symbolSize.height) / 2)
            configured.draw(at: origin, from: NSRect(origin: .zero, size: symbolSize), operation: .sourceOver, fraction: 1.0)
        }
    }
    
    image.unlockFocus()
    
    // Draw directly to a bitmap of the target pixel size to handle @2x properly
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, 
                               pixelsWide: pixelSize, 
                               pixelsHigh: pixelSize, 
                               bitsPerSample: 8, 
                               samplesPerPixel: 4, 
                               hasAlpha: true, 
                               isPlanar: false, 
                               colorSpaceName: .calibratedRGB, 
                               bytesPerRow: 0, 
                               bitsPerPixel: 0)!
    
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    
    // Clear background
    NSColor.clear.set()
    NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize).fill()
    
    // Scale context
    let transform = NSAffineTransform()
    transform.scale(by: CGFloat(scale))
    transform.concat()
    
    // Draw the image
    image.draw(at: .zero, from: NSRect(origin: .zero, size: image.size), operation: .sourceOver, fraction: 1.0)
    
    NSGraphicsContext.restoreGraphicsState()
    
    if let data = rep.representation(using: .png, properties: [:]) {
        let scaleString = scale == 2 ? "@2x" : ""
        let filename = "icon_\(size)x\(size)\(scaleString).png"
        try! data.write(to: iconsetDir.appendingPathComponent(filename))
    }
}

let sizes = [16, 32, 64, 128, 256, 512]
for size in sizes {
    createIcon(size: size, scale: 1)
    createIcon(size: size, scale: 2)
}

print("Iconset created.")
