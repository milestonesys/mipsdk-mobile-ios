//
//  CamerasListViewController.swift
//  MobileSDKLiveSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import Foundation

import UIKit
import MIPSDKMobile


class CamerasListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var cameras: [ResponseItem] = []
    
    // MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    // MARK: Get all cameras
    private func loadCameras() {
        XPMobileSDK.getAllViewsAndCameras(withSuccessHandler: { [weak self] (response) in
            guard let result = CamerasParser(json: response).results else { return }
            
            switch result {
                case let .success(cameras):
                    if !cameras.isEmpty {
                        self?.cameras.append(contentsOf: cameras)
                    }
                    
                case .failure(_):
                    print("Error parsing cameras")
            }
            
            self?.tableView.reloadData()
            }, failureHandler: nil)
    }
    
    //MARK: Helper methods
    private func setup() {
        title = Constants.camerasListScreenTitle
        tableView.tableFooterView = UIView(frame: .zero)
        
        loadCameras()
    }
}

//MARK: UITableViewDelegate methods
extension CamerasListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sb = UIStoryboard(name: Constants.storyboardName, bundle: nil)
        guard let cameraLiveViewController = sb.instantiateViewController(withIdentifier: String(describing: CameraLiveViewController.self)) as? CameraLiveViewController else {
            return
        }
        
        let camera = cameras[indexPath.row]
        cameraLiveViewController.cameraID = camera.identifier as XPSDKViewID?
        cameraLiveViewController.cameraName = camera.name
        
        navigationController?.pushViewController(cameraLiveViewController, animated: true)
    }
}

//MARK: UITableViewDataSource methods
extension CamerasListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cameras.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: Constants.tableViewCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: Constants.tableViewCellIdentifier)
        }
        cell?.textLabel?.text = cameras[indexPath.row].name
        
        return cell ?? UITableViewCell()
    }
}
