//
//  CartoonGanModel.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 25/3/23.
//

import TensorFlowLite
import PooTools

// MARK: - CartoonGanModel
final class CartoonGanModel {

    // MARK: - Properties

    weak var delegate: ModelDelegate?
    private var interpreter: Interpreter?
    private let queue = DispatchQueue(label: Constants.Queue.label)

    // MARK: - Constants

    private struct Constants {
        struct File {
            static let name = "cartoongan_int8"
            static let ext = "tflite"
        }

        struct Units {
            // https://tfhub.dev/sayakpaul/lite-model/cartoongan/int8/1
            struct Common {
                static let height: Int = 512
                static let width: Int = 512
                static let size = CGSize(width: width, height: height)
            }

            struct Input {
                static let mean: Float32 = 127.5
                static let std: Float32 = 127.5
            }

            struct Output {
                static let mean: Float32 = 1
                static let std: Float32 = 127.5
            }

            struct ARGB {
                static let components = 4 // Alpha Red Green Blue
                static let bitsPerComponent = 8 // 1 byte per component
                static let bytesPerRow = Common.width * components
                static let bytesCount = bytesPerRow * Common.height
                static let bitsPerPixel = bitsPerComponent * components
            }
        }

        struct Queue {
            static let label = "com.go.CartoonGan.serial"
        }
    }

    // MARK: - Methods

    func start(name: String, ext: String) {
        queue.async {
            guard let modelPath = Bundle.main.path( forResource: name, ofType: ext ) else {
                PTNSLogConsole("Could not find model file: \(name).\(ext)")
                self.delegate?.model(self, didFinishAllocation: .allocation)
                return
            }

            do {
                self.interpreter = try Interpreter(modelPath: modelPath)
                try self.interpreter?.allocateTensors()
            } catch let error {
                PTNSLogConsole("Interpreter initialization failed with error: \(error.localizedDescription)")
                self.delegate?.model(self, didFinishAllocation: .allocation)
                return
            }

            self.delegate?.model(self, didFinishAllocation: nil)
        }
    }

    func start() {
        start( name: Constants.File.name, ext: Constants.File.ext )
    }

    func process(_ image: UIImage) {
        // check interpreter
        guard let interpreter = interpreter else {
            PTNSLogConsole("Interpreter not available")
            delegate?.model(self, didFailedProcessing: .allocation)
            return
        }

        // check input image
        guard let cgImage = image.cgImage else {
            PTNSLogConsole("Failed to retrieve cgImage")
            delegate?.model(self, didFailedProcessing: .preprocess)
            return
        }

        queue.async {
            // 🛠 preprocess
            PTNSLogConsole("Start pre-processing 🛠")
            guard let inputData = self.preprocess(
                cgImage,
                orientation: image.imageOrientation
            ) else {
                PTNSLogConsole("Preprocessing failed!")
                self.delegate?.model(self, didFailedProcessing: .preprocess)
                return
            }

            // 🚀 pass through the model
            PTNSLogConsole("Invoke interpreter 🚀")
            do {
                try interpreter.copy(inputData, toInputAt: 0)
                try interpreter.invoke()
            } catch let error {
                PTNSLogConsole("Processing failed with error: \(error.localizedDescription)")
                self.delegate?.model(self, didFailedProcessing: .process)
                return
            }

            // 🍉 post process
            PTNSLogConsole("Start post-processing 🍉")
            guard
                let outputTensor = try? interpreter.output(at: 0),
                let output = self.postprocess(data: outputTensor.data, to: image.size)
                else {
                PTNSLogConsole("Could not retrieve output image")
                self.delegate?.model(self, didFailedProcessing: .postprocess)
                return
            }

            PTNSLogConsole("Finished processing image!")
            self.delegate?.model(self, didFinishProcessing: output)
        }
    }

    private func preprocess( _ image: CGImage, width: Int = Constants.Units.Common.width, height: Int = Constants.Units.Common.height, orientation: UIImage.Orientation ) -> Data? {
        // init buffer
        guard let base = malloc(Constants.Units.ARGB.bytesCount) else { return nil }
        defer { free(base) }

        // create context with buffer 🥽
        guard let context = CGContext( data: base, width: width, height: height, bitsPerComponent: Constants.Units.ARGB.bitsPerComponent, bytesPerRow: Constants.Units.ARGB.bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else { return nil }

        // fix orientation ⬆️
        context.concatenate(
            createUpTransformation( orientation, size: Constants.Units.Common.size )
        )

        // draw image in context ✍️
        context.draw(image, in: CGRect(origin: .zero, size: Constants.Units.Common.size))

        // parse byte data! 👓
        guard let bytes = Array<UInt8>(unsafeData: Data( bytes: base, count: Constants.Units.ARGB.bytesCount )) else { return nil }

        // normalize, remove alpha and convert to float in a single step!
        var normalized = [Float32]()
        for i in 1 ..< Constants.Units.ARGB.bytesCount {
            if i % 4 == 0 { continue } // ignore first alpha channel
            normalized.append(normalize(bytes[i]))
        }

        // 🍻 convert to data! 🍺
        return Data(copyingBufferOf: normalized)
    }

    private func postprocess( data: Data, width: Int = Constants.Units.Common.width, height: Int = Constants.Units.Common.height, to originalSize: CGSize ) -> UIImage? {
        // read output as float array
        let output = data.toArray(type: Float32.self)

        // allocate target buffer
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: Constants.Units.ARGB.bytesCount)
        let buffer = UnsafeMutableBufferPointer<UInt8>(start: pointer, count: Constants.Units.ARGB.bytesCount)
        defer { pointer.deallocate() }

        // parse floats into uint8s
        var floatIndex = 0
        for index in 0 ..< Constants.Units.ARGB.bytesCount {
            if index % 4 == 0 {
                // set empty alpha channel
                buffer[index] = 0
            } else {
                // denormalize color channels
                buffer[index] = denormalize(output[floatIndex])
                floatIndex += 1
            }
        }

        // construct image with data
        guard let dataProvider = CGDataProvider(data: Data(buffer: buffer) as CFData), let cgImage = CGImage( width: width, height: height, bitsPerComponent: Constants.Units.ARGB.bitsPerComponent, bitsPerPixel: Constants.Units.ARGB.bitsPerPixel, bytesPerRow: Constants.Units.ARGB.bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue), provider: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent ) else {
            return nil
        }

        // keep original size
        guard let resizedImage = resize( cgImage, to: originalSize ) else { return nil }

        // extract resulting image from context
        return UIImage(cgImage: resizedImage)
    }

    // MARK: - Normalization

    private func denormalize(_ pixel: Float32) -> UInt8 {
        let bigInt = Int32((pixel + Constants.Units.Output.mean) * Constants.Units.Input.std) // normalize
        return UInt8(min(max(bigInt, 0), 255)) // clip
    }

    private func normalize(_ pixel: UInt8) -> Float32 {
        (Float32(pixel) - Constants.Units.Input.mean) / Constants.Units.Input.std // normalize
    }

    // MARK: - Image utils

    private func createUpTransformation( _ orientation: UIImage.Orientation, size: CGSize ) -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        if case .up = orientation { return transform }

        switch orientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
            break
        default:
            break
        }

        switch orientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }

        return transform
    }

    private func resize(_ image: CGImage, to size: CGSize) -> CGImage? {
        guard let colorSpace = image.colorSpace else { return nil }
        guard let context = CGContext( data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: image.bitsPerComponent, bytesPerRow: Int(size.width) * image.bitsPerComponent * 4, space: colorSpace, bitmapInfo: image.alphaInfo.rawValue ) else { return nil }
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(origin: .zero, size: size))
        return context.makeImage()
    }
}
