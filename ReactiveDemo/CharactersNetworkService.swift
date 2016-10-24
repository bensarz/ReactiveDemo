import Alamofire
import Crypto
import Foundation
import enum Result.Result

struct CharactersNetworkService {
    
    let resourcePath: String = "/v1/public/characters"
    
    enum FetchCharactersError: Error {
        case unknown
    }
    
    enum ParseCharacterError: Error {
        case unknown
    }
    
    func fetchCharacters(completion: ((Result<[ReactiveDemo.Character], ParseCharacterError>) -> Void)?) {
        guard let url = URL(string: "\(MarvelNetworking.baseURL.rawValue)\(self.resourcePath)") else {
            completion?(.failure(.unknown))
            return
        }
        let ts = Date().timeIntervalSince1970
        let params = [
            "ts": "\(ts)",
            "apikey": MarvelNetworking.publicKey.rawValue,
            "hash": "\(ts)\(MarvelNetworking.privateKey.rawValue)\(MarvelNetworking.publicKey.rawValue)".md5 ?? ""
        ]
        request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: ["Accept": "application/json"])
            .responseJSON { (response) in
                switch response.result {
                case .failure:
                    completion?(.failure(.unknown))
                case .success:
                    do {
                        guard let data = response.data else {
                            completion?(.failure(.unknown))
                            return
                        }
                        guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] else {
                            completion?(.failure(.unknown))
                            return
                        }
                        let d = json["data"] as? [String: AnyObject]
                        let results = d?["results"] as? [[String: AnyObject]]
                        let characters = results?.map { (dictionary) -> Character in
                            let id = dictionary["id"] as? Int ?? -1
                            let description = dictionary["description"] as? String ?? ""
                            let name = dictionary["name"] as? String ?? ""
                            let thumbnail = dictionary["thumbnail"] as? String ?? ""
                            return ReactiveDemo.Character(id: id, description: description, name: name, thumbnail: thumbnail)
                        }
                        completion?(.success(characters ?? []))
                    } catch {
                        completion?(.failure(.unknown))
                    }
                }
        }
    }
    
}
