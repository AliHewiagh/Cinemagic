//
//  MovieService.swift
//  Cinemagic
//
//  Created by Ali Hewiagh on 13/10/2020.
//

import Foundation
import SwiftyJSON

class MovieService: MovieServiceProtocol {
    
    
    func fetchMoviesList(pageNumber: String,completion: @escaping (ApiResult)->Void) {
        
        // Create MoviesList endpoint
        let movieListEndpoint = Endpoint.movieList(pageNumber: pageNumber)
        
        
        var urlRequest = URLRequest(url: movieListEndpoint.url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        urlRequest.allHTTPHeaderFields = header
        urlRequest.httpMethod = "GET"
        
        
        // Make the call with the API to Get The movies list
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                
                print(error)
                completion(ApiResult.failure(.connectionError))
                
            } else if let data = data ,let responseCode = response as? HTTPURLResponse {
                
                do {
                    let responseJson = try JSON(data: data)
                    
                    switch responseCode.statusCode {
                    case 200:
                        completion(ApiResult.success(responseJson))
                    case 400...499:
                        completion(ApiResult.failure(.authorizationError(responseJson)))
                    case 500...599:
                        completion(ApiResult.failure(.serverError))
                    default:
                        completion(ApiResult.failure(.unknownError))
                        break
                    }
                    
                } catch let parseJSONError {
                    completion(ApiResult.failure(.unknownError))
                    print("error on parsing request to JSON : \(parseJSONError)")
                }
            }
        }.resume()
    }
    
    
    func fetchMovie(movieId: String, completion: @escaping (ApiResult)->Void) {
        
        // Create MoviesList endpoint
        let movieEndpoint = Endpoint.movie(id: movieId)
        
        var urlRequest = URLRequest(url: movieEndpoint.url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        urlRequest.allHTTPHeaderFields = header
        urlRequest.httpMethod = "GET"
        
        // Make the call with the API to get the movie details
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                
                print(error)
                completion(ApiResult.failure(.connectionError))
                
            } else if let data = data ,let responseCode = response as? HTTPURLResponse {
                
                do {
                    let responseJson = try JSON(data: data)
                    
                    switch responseCode.statusCode {
                    case 200:
                        completion(ApiResult.success(responseJson))
                    case 400...499:
                        completion(ApiResult.failure(.authorizationError(responseJson)))
                    case 500...599:
                        completion(ApiResult.failure(.serverError))
                    default:
                        completion(ApiResult.failure(.unknownError))
                        break
                    }
                } catch let parseJSONError {
                    completion(ApiResult.failure(.unknownError))
                    print("error on parsing request to JSON : \(parseJSONError)")
                }
            }
        }.resume()
    }
}

