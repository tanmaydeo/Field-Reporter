//
//  CameraViewModel.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 30/06/25.
//

import UIKit
import AVFoundation

protocol CameraViewModelDelegate: AnyObject {
    func updateRecordingTime(_ time: String)
    func recordingDidFinish(video: VideoModel)
    func recordingDidFail(with error: Error)
    func cameraPermissionDenied()
    func cameraPermissionGranted()
    func recordingStarted()
    func recordingStopped()
}

class CameraViewModel: NSObject {
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureMovieFileOutput()
    private var activeVideoInput: AVCaptureDeviceInput?
    private let sessionQueue = DispatchQueue(label: "com.fieldReporter.cameraSession")
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var currentRecordingFileName: String?
    
    weak var delegate: CameraViewModelDelegate?
    
    private var recordingTimer: Timer?
    private var elapsedSeconds = 0
    
    var isRecording: Bool {
        return videoOutput.isRecording
    }
    
    // MARK: - Session Setup
    func configureSession() {
        sessionQueue.async {
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .high
            
            defer { self.captureSession.commitConfiguration() }
            
            guard let camera = AVCaptureDevice.default(for: .video),
                  let videoInput = try? AVCaptureDeviceInput(device: camera),
                  self.captureSession.canAddInput(videoInput) else {
                return
            }
            
            self.captureSession.addInput(videoInput)
            self.activeVideoInput = videoInput
            
            if let mic = AVCaptureDevice.default(for: .audio),
               let micInput = try? AVCaptureDeviceInput(device: mic),
               self.captureSession.canAddInput(micInput) {
                self.captureSession.addInput(micInput)
            }
            
            if self.captureSession.canAddOutput(self.videoOutput) {
                self.captureSession.addOutput(self.videoOutput)
            }
        }
    }
    
    func startSession() {
        sessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func getPreviewLayer(for view: UIView) -> AVCaptureVideoPreviewLayer {
        if previewLayer == nil {
            let layer = AVCaptureVideoPreviewLayer(session: captureSession)
            layer.videoGravity = .resizeAspectFill
            layer.frame = view.bounds
            previewLayer = layer
        }
        return previewLayer!
    }
    
    // MARK: - Permission
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            delegate?.cameraPermissionGranted()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    granted ? self.delegate?.cameraPermissionGranted() : self.delegate?.cameraPermissionDenied()
                }
            }
        case .denied, .restricted:
            delegate?.cameraPermissionDenied()
        default:
            delegate?.cameraPermissionDenied()
        }
    }
    
    // MARK: - Recording
    func startRecording() {
        guard !videoOutput.isRecording else { return }
        
        let outputURL = generateUniqueURL()
        currentRecordingFileName = outputURL.lastPathComponent
        videoOutput.startRecording(to: outputURL, recordingDelegate: self)
    }
    
    func stopRecording() {
        guard videoOutput.isRecording else { return }
        videoOutput.stopRecording()
    }
    
    private func generateUniqueURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = UUID().uuidString + ".mov"
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    func retrieveVideoURL(fileName: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    private func generateThumbnail(for url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        guard let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Timer
    private func startRecordingTimer() {
        recordingTimer?.invalidate()
        elapsedSeconds = 0
        delegate?.updateRecordingTime("00:00")
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedSeconds += 1
            self.delegate?.updateRecordingTime(String(format: "%02d:%02d", self.elapsedSeconds / 60, self.elapsedSeconds % 60))
            if self.elapsedSeconds >= 30 {
                self.stopRecording()
            }
        }
    }
    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension CameraViewModel: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didStartRecordingTo fileURL: URL,
                    from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.startRecordingTimer()
            self.delegate?.recordingStarted()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        DispatchQueue.main.async {
            self.stopRecordingTimer()
            if let error = error {
                self.delegate?.recordingDidFail(with: error)
                return
            }
            
            guard let fileName = self.currentRecordingFileName else {
                self.delegate?.recordingDidFail(with: NSError(domain: "No FileName", code: -1))
                return
            }
            
            let thumbnail = self.generateThumbnail(for: outputFileURL)?.jpegData(compressionQuality: 0.8) ?? Data()
            let video = VideoModel(
                id: UUID(),
                title: "My Video",
                description: "Default description",
                fileName: fileName,
                date: Date(),
                time: Int32(self.elapsedSeconds),
                thumbnail: thumbnail
            )
            self.delegate?.recordingDidFinish(video: video)
        }
    }
}
