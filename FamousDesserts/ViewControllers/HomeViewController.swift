//
//  HomeViewController.swift
//  FamousDesserts
//
//  Created by Mine Rala on 29.08.2021.
//

import Foundation
import UIKit
import DeclarativeLayout

class HomeViewController: UIViewController , UISearchBarDelegate{
   
    private var homeViewModel = HomeViewModel()
    private let searchController = UISearchController( searchResultsController: nil)
    
    private lazy var dessertTableView: UITableView  = {
        let dtv = UITableView(frame: .zero, style: .plain)
        dtv.separatorStyle = .none
        dtv.translatesAutoresizingMaskIntoConstraints = false
        return dtv
    }()
    
    private lazy var emptyLabel: UILabel = {
        let el = UILabel(frame: .zero)
        el.translatesAutoresizingMaskIntoConstraints = false
        el.text = NSLocalizedString(C.Text.emptyList.rawValue, comment: "")
        el.textAlignment = .center
        el.textColor = C.Color.blackColor
        el.backgroundColor = C.Color.clearColor
        el.numberOfLines = 0
        el.font = UIFont(name: C.commonFont, size: 24)
        return el
    }()
}

//MARK: - Lifecycle
extension HomeViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
}

//MARK: - Set Up UI And Configure NavigationBar
extension HomeViewController {
    private func setUpUI() {
        configureNavigationBar()
        self.navigationController?.navigationBar.isTranslucent = false
        self.view.addSubview(dessertTableView)
        dessertTableView.register(DessertCell.self, forCellReuseIdentifier: "DessertCell")
        
        dessertTableView
            .topAnchor(margin: 0)
            .bottomAnchor(margin: 0)
            .leadingAnchor(margin: 0)
            .trailingAnchor(margin: 0)
        
        self.view.addSubview(emptyLabel)
        
        emptyLabel
            .centerXAnchor(margin: 0)
            .centerYAnchor(margin: 0)
        
        dessertTableView.dataSource = self
        dessertTableView.delegate = self
        
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString(C.Text.searchDessert.rawValue, comment: "")
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        homeViewModel.initializeArrays()
        reloadDessertTableView()
        
    }
    
    private func configureNavigationBar() {
        self.navigationItem.title = NSLocalizedString(C.Text.desserts.rawValue, comment: "")
        let titleColor = C.Color.blackColor
        let attributes = [NSAttributedString.Key.foregroundColor: titleColor , NSAttributedString.Key.font : UIFont(name: C.commonFont, size: 24)]
        self.navigationController?.navigationBar.titleTextAttributes = attributes as [NSAttributedString.Key : Any]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(addButtonTapped))
        self.navigationItem.rightBarButtonItem?.tintColor = C.Color.rightButtonColor
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: C.ImageIcon.starFill.rawValue), style: .plain, target: self, action: #selector(favoriteButtonTapped))
        self.navigationItem.leftBarButtonItem?.tintColor = C.Color.orangeColor
        
        
        //En üstteki separator çizgisini saklamak için.
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.backgroundColor = C.Color.whiteColor
        self.navigationController?.navigationBar.shadowImage = UIImage()
        //  Navigation bar back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor =  C.Color.backButtonColor
    }
}

//MARK: - TableViewDelegate & TableViewDataSource & ReloadTableView
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    private func reloadDessertTableView() {
        if homeViewModel.arrFilteredDesserts.count == 0 {
            emptyLabel.isHidden = false
            dessertTableView.isHidden = true
        }else{
            dessertTableView.isHidden = false
            emptyLabel.isHidden = true
        }
        dessertTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeViewModel.arrFilteredDesserts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "DessertCell", for: indexPath) as! DessertCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        let dessert = homeViewModel.arrFilteredDesserts[indexPath.row]
        cell.updateCell(dessert: dessert)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let dessert = homeViewModel.arrFilteredDesserts[indexPath.row]
        let detailVC = DetailDessertViewController(model: dessert)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title:NSLocalizedString( C.Text.delete.rawValue, comment: "")) { [weak self] (action, view, completionHandler) in
            guard let self = self else{
                completionHandler(false)
                return
            }
            
            self.handleDelete(indexPath: indexPath)
            completionHandler(true)
        }
        
        delete.backgroundColor = C.Color.redColor
        
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        return configuration
    }
    
    private func handleDelete(indexPath: IndexPath) {
        Alerts.showAlertDelete(controller: self,NSLocalizedString(C.Text.showAlertDeleteMessage.rawValue, comment: ""), deletion: { [self] in
            homeViewModel.removeItemFromArrayDessert(index: indexPath.row)
            self.updateSearchResults(for: self.searchController)
        })
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let update = UIContextualAction(style: .normal, title: NSLocalizedString(C.Text.update.rawValue, comment: "")) { [weak self] (action, view, completionHandler) in
            guard let self = self else {
                completionHandler(false)
                return
            }
            
            self.updateButtonTapped(indexPath: indexPath)
            completionHandler(true)
        }
        
        update.backgroundColor = C.Color.orangeColor
        let configuration = UISwipeActionsConfiguration(actions: [update])
        return configuration
    }
}
    
//MARK: - Update SearchResult
extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = self.searchController.searchBar.text else {
            return
        }
        homeViewModel.updateFilteredArray(with: searchText)
        self.reloadDessertTableView()
    }
}
    
//MARK: - Actions
extension HomeViewController: AddNewDessertDelegate {
    @objc func addButtonTapped(){
        let addDessertVC = AddDessertViewController()
        addDessertVC.delegate = self
        self.navigationController?.pushViewController(addDessertVC, animated: true)
    }

    private func updateButtonTapped(indexPath: IndexPath) {
        let selectedDessert = homeViewModel.arrFilteredDesserts[indexPath.row]
        let updateDessertVC = AddDessertViewController(model: selectedDessert)
        updateDessertVC.addDessertViewModel.dessertState = .update
        updateDessertVC.delegate = self
        self.navigationController?.pushViewController(updateDessertVC, animated: true)
    }
    
    @objc func favoriteButtonTapped() {
        let favoriteVC = FavoriteViewController(model: homeViewModel)
        self.navigationController?.pushViewController(favoriteVC, animated: true)
    }
    
    func passDessert(dessert: Dessert) {
        homeViewModel.checkDessert(dessert: dessert)
        updateSearchResults(for: self.searchController)
        dessertTableView.reloadData()
    }
}
