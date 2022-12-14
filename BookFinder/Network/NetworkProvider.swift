//
//  NetworkProvider.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import Foundation
import RxSwift

struct NetworkProvider {
    // MARK: - Properties
    private let session: URLSessionProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    // MARK: - Methods
    func fetchData<T: Decodable>(api: Gettable, decodingType: T.Type) -> Observable<T> {
        return Observable.create { emitter in
            guard let task = dataTask(api: api, emitter: emitter) else {
                return Disposables.create()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    private func dataTask<T: Decodable>(api: APIProtocol, emitter: AnyObserver<T>) -> URLSessionDataTask? {
        guard let urlRequest = URLRequest(api: api) else {
            emitter.onError(NetworkError.urlIsNil)
            return nil
        }
        
        let task = session.dataTask(with: urlRequest) { data, response, _ in
            let successStatusCode = 200..<300
            guard let httpResponse = response as? HTTPURLResponse,
                  successStatusCode.contains(httpResponse.statusCode) else {
                emitter.onError(NetworkError.statusCodeError)
                return
            }
            
            guard
                let data = data,
                let decodedData = JSONParser<T>().decode(from: data)
            else {
                emitter.onError(JSONParserError.decodingFail)
                return
            }
            
            emitter.onNext(decodedData)
            emitter.onCompleted()
        }
        
        return task
    }
}

enum NetworkError: Error, LocalizedError {
    case statusCodeError
    case unknownError
    case urlIsNil
    
    var errorDescription: String? {
        switch self {
        case .statusCodeError:
            return "???????????? StatusCode??? ????????????."
        case .unknownError:
            return "?????? ?????? ????????? ??????????????????."
        case .urlIsNil:
            return "???????????? URL??? ????????????."
        }
    }
}
