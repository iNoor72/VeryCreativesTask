//
//  NetworkRouter.swift
//  VeryCreatives-Task
//
//  Created by Noor Walid on 14/04/2022.
//

import Foundation
import Alamofire

//NetowrkRequest
enum NetworkRouter: URLRequestConvertible {
    case topRated(page: Int)
    case popular(page: Int)

    var path: String {
        switch self {
        case .topRated:
            return "/movie/top_rated"
        case .popular:
            return "/movie/popular"
        }
    }
    
    
    var method: HTTPMethod {
            switch self {
            case .topRated:
                return .get
            case .popular:
                return .get
            }
        }
        
    //We don't need headers but if needed, uncomment the code and write the headers
    
//    var headers: [String:String] {
//        switch self {
//        case .topRated:
//            return ["":""]
//        case .popular:
//            return ["":""]
//        case .movie(_):
//            return ["":""]
//        }
//    }

    
        var parameters: [String: Any] {
            switch self {
            case .topRated(let page):
                return ["api_key":"\(Constants.APIKey)", "page":page]
            case .popular(let page):
                return ["api_key":"\(Constants.APIKey)", "page":page]
            }
        }
        
    
    
    
    func asURLRequest() throws -> URLRequest {
        guard var safeURL = URL(string: Constants.baseURL) else { return URLRequest(url: Constants.dummyURL) }
        safeURL.appendPathComponent(path)
        var request = URLRequest(url: safeURL)
        request.method = method
        switch self {
        default:
            request = try URLEncoding.default.encode(request, with: parameters)
        }
        
        return request
    }
}
