//
//  CamerasListViewController.swift
//  MobileSDKPTTSample
//
//  Copyright © 2018 Milestone Systems A/S. All rights reserved.
//

import UIKit
import MIPSDKMobile

typealias Item = [String: Any]

class CamerasListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var cameras = [ResponseItem]()
    
// MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadCameras()
    }
}

//MARK: Helper methods
extension CamerasListViewController {
    private func setup() {
        title = Constants.cameraListViewControllerTitle
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func loadCameras() {
        XPMobileSDK.getAllViewsAndCameras(withSuccessHandler: { [weak self] (response) in
            guard let result = CamerasParser(json: response).results else { return }
            
            switch result {
                case let .success(cameras):
                    for camera in cameras {
                        if let speakers = camera.items, !speakers.isEmpty {
                        self?.cameras.append(camera)
                    }
                }
                    
                case .failure(_):
                    print("Error parsing cameras")
            }
            
            self?.tableView.reloadData()
            
        }, failureHandler: { (error) in
            print("Error fetching all views and cameras")
        })
    }
}

//MARK: UITableViewDataSource methods
extension CamerasListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return cameras.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cameraListCellIdentifier)
        else { return UITableViewCell() }

        let camera = cameras[indexPath.row]
        cell.textLabel?.text = camera.name
        
        return cell
    }
}

//MARK: UITableViewDelegate methods
extension CamerasListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: Constants.storyboardName, bundle: nil)
        let pttVCIdentifier = String(describing: PTTViewController.self)
        if let pttViewController = storyboard.instantiateViewController(withIdentifier: pttVCIdentifier) as? PTTViewController {
            let camera = cameras[indexPath.row]
            pttViewController.viewModel = PTTViewModel(withModel: camera)
            
            navigationController?.pushViewController(pttViewController, animated: true)
        }
    }
}
