//
//  CameraViewController.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 27/06/25.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    // MARK: - ViewModel
    private let viewModel = CameraViewModel()
    
    // MARK: - UI Elements
    private let recordButton = UIButton()
    private let dismissButton = UIButton(type: .custom)
    private let videoTimerLabel = PaddedLabel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        viewModel.delegate = self
        viewModel.checkCameraPermission()
        viewModel.configureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
        resetRecordingUI()
        viewModel.startSession()
        addPreviewLayer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.stopSession()
    }
    
    // MARK: - UI Setup
    private func setupView() {
        view.backgroundColor = .black
        addSubviews()
        styleSubviews()
        layoutSubviews()
    }
    
    private func addSubviews() {
        view.addSubview(recordButton)
        view.addSubview(dismissButton)
        view.addSubview(videoTimerLabel)
    }
    
    private func styleSubviews() {
        // Record Button
        recordButton.backgroundColor = .white
        recordButton.layer.cornerRadius = 35
        recordButton.layer.masksToBounds = true
        recordButton.addTarget(self, action: #selector(startRecording), for: .touchDown)
        recordButton.addTarget(self, action: #selector(stopRecording), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        recordButton.isEnabled = false
        recordButton.alpha = 0.5
        
        // Dismiss Button
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = .white
        dismissButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        // Timer Label
        videoTimerLabel.text = "00:00"
        videoTimerLabel.textColor = .white
        videoTimerLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        videoTimerLabel.backgroundColor = .systemRed
        videoTimerLabel.layer.cornerRadius = 8
        videoTimerLabel.clipsToBounds = true
        videoTimerLabel.isHidden = true
    }
    
    private func layoutSubviews() {
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        videoTimerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            recordButton.widthAnchor.constraint(equalToConstant: 70),
            recordButton.heightAnchor.constraint(equalToConstant: 70),
            
            dismissButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 16),
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dismissButton.widthAnchor.constraint(equalToConstant: 40),
            dismissButton.heightAnchor.constraint(equalToConstant: 40),
            
            videoTimerLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 16),
            videoTimerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func addPreviewLayer() {
        let previewLayer = viewModel.getPreviewLayer(for: view)
        view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    // MARK: - Actions
    @objc private func startRecording() {
        viewModel.startRecording()
    }
    
    @objc private func stopRecording() {
        viewModel.stopRecording()
    }
    
    @objc private func dismissView() {
        navigationController?.popViewController(animated: true)
    }
    
    private func resetRecordingUI() {
        videoTimerLabel.isHidden = true
        videoTimerLabel.text = "00:00"
        recordButton.transform = .identity
        recordButton.backgroundColor = .white
    }
    
    private func hideNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func enableRecordingUI(_ isEnabled: Bool) {
        recordButton.isEnabled = isEnabled
        recordButton.alpha = isEnabled ? 1.0 : 0.5
    }
    
    private func showCameraAccessAlert() {
        let alert = UIAlertController(
            title: AppConstants.cameraPermissionNotGrantedTitle.rawValue,
            message: AppConstants.cameraPermissionNotGrantedDescription.rawValue,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings)
            }
        })
        
        present(alert, animated: true)
    }
    
    private func animateRecordButton(isRecording: Bool) {
        let scale: CGFloat = isRecording ? 1.5 : 1.0
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            self.recordButton.backgroundColor = isRecording ? .red : .white
            self.recordButton.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
    }
}

// MARK: - CameraViewModelDelegate
extension CameraViewController: CameraViewModelDelegate {
    
    func updateRecordingTime(_ time: String) {
        videoTimerLabel.text = time
    }
    
    func recordingStarted() {
        videoTimerLabel.isHidden = false
        animateRecordButton(isRecording: true)
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.prepare()
        feedback.impactOccurred()
    }
    
    func recordingStopped() {
        videoTimerLabel.isHidden = true
        videoTimerLabel.text = "00:00"
        animateRecordButton(isRecording: false)
        enableRecordingUI(true)
    }
    
    func recordingDidFinish(url: URL, duration: Int) {
        let previewVC = VideoPreviewViewController(videoURL: url, videoTime: duration)
        navigationController?.pushViewController(previewVC, animated: false)
    }
    
    func recordingDidFail(with error: Error) {
        print("Recording failed: \(error.localizedDescription)")
        enableRecordingUI(false)
    }
    
    func cameraPermissionDenied() {
        enableRecordingUI(false)
        showCameraAccessAlert()
    }
}
