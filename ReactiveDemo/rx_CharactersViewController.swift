import RxCocoa
import RxSwift
import UIKit
import enum Result.Result

class rx_CharactersViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var characters: Variable<[Character]> = Variable([])
    let disposeBag = DisposeBag()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rx_setup()
        
        let onNext: (Result<[Character], rx_CharactersNetworkService.ParseCharacterError>) -> Void = { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let characters):
                self.characters.value = characters
            }
        }
        let observable = rx_CharactersNetworkService().rx_fetchCharacters()
        _ = observable.subscribe(onNext: onNext)
        
        
    }
    
    // MARK: - Reactive Setup
    
    private func rx_setup() {
        characters.asObservable().bindTo(tableView
            .rx
            .items(cellIdentifier: "CharacterTableViewCell",
                   cellType: CharacterTableViewCell.self)) { (row, character, cell) in
                    cell.render(character: character)
            }
            .addDisposableTo(disposeBag)
        
        tableView
            .rx
            .modelSelected(Character.self)
            .subscribe(onNext: { (character) in
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
            })
            .addDisposableTo(disposeBag)
    }
    
}
