//
//  CharactersViewController.swift
//  ReactiveDemo
//
//  Created by Benoit Sarrazin on 2016-10-16.
//  Copyright © 2016 Berzerker IO. All rights reserved.
//

import RxSwift
import UIKit

class CharactersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var characters: [Character] = []
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let observable = CharactersNetworkService().rx_fetchCharacters()
        _ = observable.subscribe(onNext: { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let characters):
                self.characters = characters
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterTableViewCell", for: indexPath)
        if let cell = cell as? CharacterTableViewCell {
            cell.render(character: characters[indexPath.row])
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height / 10
    }
    
}
