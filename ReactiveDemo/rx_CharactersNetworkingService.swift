import Alamofire
import Crypto
import Foundation
import RxSwift
import enum Result.Result

struct rx_CharactersNetworkService {
    
    let resourcePath: String = "/v1/public/characters"
    
    enum FetchCharactersError: Error {
        case unknown
    }
    
    enum ParseCharacterError: Error {
        case unknown
    }
    
    func rx_fetchCharacters() -> Observable<Result<[ReactiveDemo.Character], ParseCharacterError>> {
        return Observable<[String: AnyObject]>.create { (observer) -> Disposable in
            guard let url = URL(string: "\(MarvelNetworking.baseURL.rawValue)\(self.resourcePath)") else {
                observer.onError(FetchCharactersError.unknown)
                return Disposables.create()
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
                        observer.onError(FetchCharactersError.unknown)
                    case .success:
                        do {
                            guard let data = response.data else {
                                observer.onError(FetchCharactersError.unknown)
                                return
                            }
                            guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] else {
                                observer.onError(FetchCharactersError.unknown)
                                return
                            }
                            observer.onNext(json)
                            observer.onCompleted()
                        } catch let error {
                            observer.onError(error)
                        }
                    }
            }
            return Disposables.create()
            }
            .map { (json) -> Result<[ReactiveDemo.Character], ParseCharacterError> in
                guard let statusCode = json["code"] as? Int else { return .failure(.unknown) }
                switch statusCode {
                case 200:
                    let data = json["data"] as? [String: AnyObject]
                    let results = data?["results"] as? [[String: AnyObject]]
                    let characters = results?.map { (dictionary) -> Character in
                        let id = dictionary["id"] as? Int ?? -1
                        let description = dictionary["description"] as? String ?? ""
                        let name = dictionary["name"] as? String ?? ""
                        let thumbnail = dictionary["thumbnail"] as? String ?? ""
                        return ReactiveDemo.Character(id: id, description: description, name: name, thumbnail: thumbnail)
                    }
                    return .success(characters ?? [])
                default:
                    return .failure(.unknown)
                }
            }
            .do(onNext: { (result) in
                switch result {
                case .failure(let error):
                    print(error)
                    throw ParseCharacterError.unknown
                case .success(_):
                    print("success")
                    // save to database
                }
            })
    }
    
}
