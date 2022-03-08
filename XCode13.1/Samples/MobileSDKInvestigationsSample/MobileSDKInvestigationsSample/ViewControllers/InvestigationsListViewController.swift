//
//  InvestigationsListViewController.swift
//  MobileSDKInvestigationsSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import UIKit
import MIPSDKMobile

typealias Item = [String: Any]

class InvestigationsListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var investigations = [ResponseItem]()
    
// MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadInvestigations()
    }
}

//MARK: Helper methods
extension InvestigationsListViewController {
    private func setup() {
        title = Constants.listViewControllerTitle
        navigationItem.backBarButtonItem?.title = Constants.listViewControllerBackButtonTitle
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func loadInvestigations() {
        let name = Constants.Parameters.getInvestigation
        let parameters = [Constants.Parameters.itemId: Constants.allInvestigationsID]
        
        XPMobileSDK.sendCommand(name: name,
                                parameters: parameters) { [weak self] (response) in
            if let items = response?.responseItems as? [Item] {
                let parser = ResponseItemParser()
                for item in items {
                    let result = parser.parseItem(item)
                    switch result {
                        case let .success(investigation):
                            self?.investigations.append(investigation)
                        case .failure(_):
                            print("Error parsing investigation")
                    }
                }
                
                self?.tableView.reloadData()
            }
        } failureHandler: {_ in }
    }
}

//MARK: UITableViewDataSource methods
extension InvestigationsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return investigations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.tableviewCellIdentifier) else { return UITableViewCell() }
        
        let investigation = investigations[indexPath.row]
        cell.textLabel?.text = investigation.name
        
        return cell
    }
}

//MARK: UITableViewDelegate methods
extension InvestigationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: Constants.storyboardName, bundle: nil)
        let detailsVCIdentifier = String(describing: InvestigationDetailsViewController.self)

        if let detailsViewController = storyboard.instantiateViewController(withIdentifier: detailsVCIdentifier) as? InvestigationDetailsViewController {
            detailsViewController.investigationDetails = investigations[indexPath.row]
            navigationController?.pushViewController(detailsViewController, animated: true)
        }
    }
}
