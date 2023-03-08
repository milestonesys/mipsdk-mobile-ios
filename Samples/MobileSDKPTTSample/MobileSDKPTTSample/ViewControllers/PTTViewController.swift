//
//  PTTViewController.swift
//  MobileSDKPTTSample
//
//  Copyright © 2018 Milestone Systems A/S. All rights reserved.
//

import UIKit
import MIPSDKMobile

class PTTViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var audioPushButton: AudioPushButton!
    
    var viewModel: PTTViewModel?
    
    // MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.selectRow(at: IndexPath(row: 0, section: 0),
                            animated: false,
                            scrollPosition: .none)
    }
}

//MARK: Helper methods
extension PTTViewController {
    private func setup() {
        XPAudioPushManager.sharedInstance.delegate = self
        
        title = viewModel?.cameraName
        tableView.tableFooterView = UIView(frame: .zero)
        
        audioPushButton.addTarget(self, action: #selector(pushAudio), for: .touchDown)
        audioPushButton.addTarget(self, action: #selector(stopAudio), for: .touchUpInside)
        audioPushButton.addTarget(self, action: #selector(stopAudio), for: .touchDragExit)
    }
    
    private func presentAlert(withTitle title:String, message:String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: Constants.аlertOK,
                                          style: .default,
                                          handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true) {() -> Void in }
    }
    
    @objc private func pushAudio() {
        guard let speakers = viewModel?.speakers else { return }
        
        let selectedSpeaker = speakers[tableView.indexPathForSelectedRow?.row ?? 0]
        if let speakerID = selectedSpeaker.identifier, selectedSpeaker.supportsAudioPushSpeak {
            XPAudioPushManager.sharedInstance.startAudioPush(forItemId: speakerID)
        } else {
            presentAlert(withTitle: Constants.errorTitle,
                         message: Constants.Messages.pushToTalkErrorMessage)
        }
    }
    
    @objc private func stopAudio() {
        guard let speakers = viewModel?.speakers else { return }
        
        let selectedSpeakerIndex = tableView.indexPathForSelectedRow?.row ?? 0
        let selectedSpeaker = speakers[selectedSpeakerIndex]
        if selectedSpeaker.supportsAudioPushSpeak {
            XPAudioPushManager.sharedInstance.stopAudioPush()
        }
    }
}

//MARK: UITableViewDataSource methods
extension PTTViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.speakers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.pttListCellIdentifier)
        else { return UITableViewCell() }
        
        let speaker = viewModel?.speakers?[indexPath.row]
        cell.textLabel?.text = speaker?.name
        
        return cell
    }
}

//MARK: XPAudioPushManagerDelegate methods
extension PTTViewController: XPAudioPushManagerDelegate {
    func microphoneUsageNotAllowed() {
        presentAlert(withTitle: Constants.Messages.permissionDeniedTitle,
                     message: Constants.Messages.permissionDeniedSubtitle)
    }
    
    func didGetErrorWhilePushingAudio(error: NSError) {
        presentAlert(withTitle: Constants.errorTitle,
                     message: "\(error.userInfo)")
    }
}
