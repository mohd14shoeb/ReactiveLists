//
//  PlanGrid
//  https://www.plangrid.com
//  https://medium.com/plangrid-technology
//
//  Documentation
//  https://plangrid.github.io/ReactiveLists
//
//  GitHub
//  https://github.com/plangrid/ReactiveLists
//
//  License
//  Copyright © 2018-present PlanGrid, Inc.
//  Released under an MIT license: https://opensource.org/licenses/MIT
//

import ReactiveLists
import UIKit

@objc
class TableViewController: UITableViewController {

    var tableViewDataSource: FluxTableViewDataSource?
    var groups: [UserGroup] = [] {
        didSet {
            self.tableViewDataSource?.tableViewModel.value = TableViewController.viewModel(
                forState: groups,
                onDeleteClosure: { deletedUser in
                    // Iterate through the user groups and find the deleted user.
                    for (index, group) in self.groups.enumerated() {
                        self.groups[index].users = group.users.filter { $0.uuid != deletedUser.uuid }
                    }
                }
            )
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableViewDataSource = FluxTableViewDataSource(tableView: self.tableView, automaticDiffEnabled: true)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")

        self.groups = [
            UserGroup(
                name: "Premium",
                users: [User(name: "Premium1"), User(name: "Premium2")]
            ),
            UserGroup(
                name: "Regular",
                users: [User(name: "Regular1"), User(name: "Regular2")]
            ),
        ]
    }

    @IBAction func swapSections(_ sender: Any) {
        let group0 = self.groups[0]
        self.groups[0] = self.groups[1]
        self.groups[1] = group0
    }

    @IBAction func addUser(_ sender: Any) {
        self.groups[0].users.append(User(name: "New User!"))
    }
}

// MARK: View Model Provider

extension TableViewController {

    /// Pure function mapping new state to a new `FluxTableViewModel`.  This is invoked each time the state updates
    /// in order for ReactiveLists to update the UI.
    static func viewModel(forState groups: [UserGroup], onDeleteClosure: @escaping (User) -> Void) -> FluxTableViewModel {
        let sections: [FluxTableViewModel.SectionModel] = groups.map { group in
            let cellViewModels = group.users.map { UserCell(user: $0, onDeleteClosure: onDeleteClosure) }
            return FluxTableViewModel.SectionModel(
                headerTitle: group.name,
                headerHeight: 20,
                cellViewModels: cellViewModels,
                diffingKey: group.name
            )
        }
        return FluxTableViewModel(sectionModels: sections)
    }
}