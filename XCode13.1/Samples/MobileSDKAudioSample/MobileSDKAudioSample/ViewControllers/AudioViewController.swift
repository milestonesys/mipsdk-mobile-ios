//
//  AudioViewController.swift
//  MobileSDKAudioSample
//
//  Copyright © 2018 Milestone Systems A/S. All rights reserved.
//

import UIKit
import MIPSDKMobile

class AudioViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var audioButton: UIButton!
    
    var cameraName: String?
    var microphones: [MicrophoneData] = []
    
    
    // MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if audioButton.isSelected {
            stopAudio()
        }
    }
    
    // MARK: IBAction methods
    @IBAction func audioButtonPressed(_ sender: Any) {
        audioButton.isSelected = !audioButton.isSelected
        
        if audioButton.isSelected {
            playAudio()
        } else {
            stopAudio()
        }
    }

    //MARK: Helper methods
    private func setup() {
        title = cameraName
        tableView.tableFooterView = UIView(frame: .zero)
        
        audioButton.setImage(UIImage(named: Constants.audioOffImage), for: .normal)
        audioButton.setImage(UIImage(named: Constants.audioOnImage), for: .selected)
        
        AudioManager.sharedInstance.delegate = self
    }
    
    @objc private func playAudio() {
        let selectedMicrophone = microphones[tableView.indexPathForSelectedRow?.row ?? 0]
        
        if let micId = selectedMicrophone.identifier, selectedMicrophone.supportsLiveAudio {
            AudioManager.sharedInstance.playAudio(withItemId: micId,
                                                  playbackControllerId: nil,
                                                  investigationId: nil,
                                                  signalType: Constants.audioSignalType)
        } else {
            alert(withTitle: Constants.ErrorHandler.audioErorTitle,
                  message: Constants.ErrorHandler.noUserRightsErrorMessage)
        }
    }
    
    @objc private func stopAudio() {
        AudioManager.sharedInstance.stopAudio()
    }
    
    private func alert(withTitle title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: Constants.ErrorHandler.alertOK,
                                          style: .default,
                                          handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
}

//MARK: AudioManagerDelegate methods
extension AudioViewController: AudioManagerDelegate {
    func didGetErrorWhilePlayingAudio(error: NSError) {
        let message = error.code == Constants.ErrorHandler.audioError ? Constants.ErrorHandler.networkErrorMessage : Constants.ErrorHandler.noAudioConnectionErrorMessage
        alert(withTitle: Constants.ErrorHandler.audioErorTitle, message: message)
    }
}

//MARK: UITableViewDataSource methods
extension AudioViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return microphones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let simpleTableIdentifier = Constants.audioVCTableViewCellIdentifier
        var cell = tableView.dequeueReusableCell(withIdentifier: simpleTableIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: simpleTableIdentifier)
        }
        
        cell?.textLabel?.text = microphones[indexPath.row].name
        
        return cell ?? UITableViewCell()
    }
}
