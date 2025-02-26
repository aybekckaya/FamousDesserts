//
//  FavoriViewController.swift
//  FamousDesserts
//
//  Created by Mine Rala on 5.09.2021.
//

import Foundation
import UIKit

class FavoriteViewController: UIViewController {
   
    var arrFavorited : [Dessert] = []
    var homeViewModel: HomeViewModel!
    
    private lazy var favoriteDessertTableView: UITableView  = {
        let fdtv = UITableView(frame: .zero, style: .plain)
        fdtv.translatesAutoresizingMaskIntoConstraints = false
        return fdtv
    }()
    
    init(model: HomeViewModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        if model == nil {
            self.homeViewModel = HomeViewModel()
        }else{
            self.homeViewModel = model
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Lifecycle
extension FavoriteViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
}

//MARK: - Set Up UI
extension FavoriteViewController {
    private func setUpUI() {
        self.view.backgroundColor = C.Color.whiteColor
        self.title = NSLocalizedString(C.Text.favoriteDessert.rawValue, comment: "")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor =  C.Color.backButtonColor
        
        self.view.addSubview(favoriteDessertTableView)
        favoriteDessertTableView.register(FavoriteDessertCell.self, forCellReuseIdentifier: "FavoriteDessertCell")
        favoriteDessertTableView
            .topAnchor(margin: 0)
            .bottomAnchor(margin: 0)
            .trailingAnchor(margin: 0)
            .leadingAnchor(margin: 0)
        favoriteDessertTableView.tableFooterView = UIView()
        
        
        favoriteDessertTableView.dataSource = self
        favoriteDessertTableView.delegate = self
        
        for item in homeViewModel.arrFilteredDesserts{
            if item.isFavorite == true {
                arrFavorited.append(item)
            }
        }
        
        favoriteDessertTableView.reloadData()
    }
}
    
//MARK: - UITableViewDelegate & UITableViewDataSource
extension FavoriteViewController: UITableViewDelegate,UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFavorited.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "FavoriteDessertCell", for: indexPath) as! FavoriteDessertCell
        let dessert = arrFavorited[indexPath.row]
        // Cell selection color changed.
        let backgroundView = UIView()
        backgroundView.backgroundColor = C.Color.dessertImageBackgroundColor
        cell.selectedBackgroundView = backgroundView
        cell.updateCell(dessert: dessert)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // celli seçtikten sonraki griliği kaldırır.
        tableView.deselectRow(at: indexPath, animated: true)
        let dessert = arrFavorited[indexPath.row]
        let detailVC = DetailDessertViewController(model: dessert)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
}
