//
//  NoteRequests.swift
//  Muktasar
//
//  Created by Alex Z on 10/6/20.
//  Copyright © 2020 Artem Rizhov. All rights reserved.
//

import Foundation
import Moya

public enum NoteRequestParams {
    case addNote(bookId:String, text:String?, comment:String, token:String)
    case editNote(noteId:String, text:String?, comment:String, token:String)
    case deleteNote(noteId:String, token:String)
    case getListNotes(bookId:String, token:String)
}

extension NoteRequestParams: TargetType {
  // 1
  public var baseURL: URL {
    return URL(string: kBaseURL)!
  }

  // 2
  public var path: String {
    switch self {
        case .addNote(let id, _, _, _):                 return "/books/" + String(id) + "/notes"
        case .editNote(let id, _, _, _):                return "/books/notes/" + String(id)
        case .deleteNote(let id, _):                    return "/books/notes/" + String(id)
        case .getListNotes(let id, _):                  return "/books/" + String(id) + "/notes/list"
    }
  }

  // 3
  public var method: Moya.Method {
    switch self {
        case .addNote: return .post
        case .editNote: return .put
        case .deleteNote: return .delete
        case .getListNotes: return .get
    }
  }

  // 4
  public var sampleData: Data {
    return Data()
  }

  // 5
  public var task: Task {
    switch self {
        case .addNote(_, let text, let comment, _):
            var params:[String:String] = ["comment" : comment]
            if let text = text {params["text"] = text}
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default)

        case .editNote(_, let text, let comment, _):
            var params:[String:String] = ["comment" : comment]
            if let text = text {params["text"] = text}
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default)

        case .deleteNote:
            return .requestPlain

        case .getListNotes:
            return .requestPlain
    }
  }

  // 6
  public var headers: [String: String]? {
    switch self {
        case .addNote(_, _, _, let token):
            return ["Content-Type": "application/x-www-form-urlencoded",
                    "Authorization": "Bearer " + token]
        case .editNote(_, _, _, let token):
            return ["Content-Type": "application/x-www-form-urlencoded",
                    "Authorization": "Bearer " + token]
        case .deleteNote(_, let token):
            return ["Content-Type": "application/x-www-form-urlencoded",
                    "Authorization": "Bearer " + token]
        case .getListNotes(_, let token):
            return ["Content-Type": "application/x-www-form-urlencoded",
                    "Authorization": "Bearer " + token]
        }
    }
    
    public var validationType: ValidationType {
      return .successCodes
    }
}

class ListBookNotesRequest:AuthorizationRequest{
    let provider = MoyaProvider<NoteRequestParams>(plugins: [NetworkLoggerPlugin(configuration: .init(formatter: .init(), output: NetworkLoggerPlugin.Configuration.defaultOutput, logOptions: .verbose))])
    
    var cancelation:Cancellable?
    func cancel() {
        cancelation?.cancel()
    }

    func run(bookId:String, completion: @escaping ((_ notes:[NoteModel]?, _ message:String?)->Void)) {
        cancel()
        guard let accessToken = LoginModel.current?.accessToken else {completion(nil, kLogoutMessage); return}
        cancelation = provider.request(.getListNotes(bookId: bookId, token:accessToken)) { [weak self] result in
           guard let self = self else { return }
           self.cancelation = nil
        
            switch result {
            case .success(let response):
              do {
                  let responseModel = try JSONDecoder().decode(ListResponseModel<NoteModel>.self, from: response.data)
                  
                  let jsonData = try response.mapJSON()
                  print(jsonData)
                  
                    if responseModel.success {
                        completion(responseModel.data, responseModel.message)
                    }
                    else{
                        if responseModel.authorization {
                            completion(nil, responseModel.message)
                        }
                        else{
                            AuthorizationRequest.processAuthorizationFaild()
                        }
                    }
              } catch {
                  completion(nil, kDefaultErrorMessage)
              }
            case .failure:
              completion(nil, kDefaultErrorMessage)
            }
        }
    }
}

class CreateBookNoteRequest:AuthorizationRequest{
    let provider = MoyaProvider<NoteRequestParams>(plugins: [NetworkLoggerPlugin(configuration: .init(formatter: .init(), output: NetworkLoggerPlugin.Configuration.defaultOutput, logOptions: .verbose))])
    
    var cancelation:Cancellable?
    func cancel() {
        cancelation?.cancel()
    }

    func run(bookId:String, text:String? = nil, comment:String, completion: @escaping ((_ note:NoteModel?, _ message:String?)->Void)) {
        cancel()
        guard let accessToken = LoginModel.current?.accessToken else {completion(nil, kLogoutMessage); return}
        cancelation = provider.request(.addNote(bookId: bookId, text:text, comment:comment, token:accessToken)) { [weak self] result in
           guard let self = self else { return }
           self.cancelation = nil
        
            switch result {
            case .success(let response):
              do {
                  let responseModel = try JSONDecoder().decode(ResponseModel<NoteModel>.self, from: response.data)
                  
                  let jsonData = try response.mapJSON()
                  print(jsonData)
                  
                if responseModel.success {
                    completion(responseModel.data, responseModel.message)
                }
                else{
                    if responseModel.authorization {
                        completion(nil, responseModel.message)
                    }
                    else{
                        AuthorizationRequest.processAuthorizationFaild()
                    }
                }
              } catch {
                  completion(nil, kDefaultErrorMessage)
              }
            case .failure:
              completion(nil, kDefaultErrorMessage)
            }
        }
    }
}

class EditBookNoteRequest:AuthorizationRequest{
    let provider = MoyaProvider<NoteRequestParams>(plugins: [NetworkLoggerPlugin(configuration: .init(formatter: .init(), output: NetworkLoggerPlugin.Configuration.defaultOutput, logOptions: .verbose))])
    
    var cancelation:Cancellable?
    func cancel() {
        cancelation?.cancel()
    }

    func run(noteId:String, text:String? = nil, comment:String, completion: @escaping ((_ isSuccess:Bool, _ message:String?)->Void)) {
        cancel()
        guard let accessToken = LoginModel.current?.accessToken else {completion(false, kLogoutMessage); return}
        cancelation = provider.request(.editNote(noteId: noteId, text:text, comment:comment, token:accessToken)) { [weak self] result in
           guard let self = self else { return }
           self.cancelation = nil
        
            switch result {
            case .success(let response):
              do {
                  let responseModel = try JSONDecoder().decode(ResponseModel<String>.self, from: response.data)
                  
                  let jsonData = try response.mapJSON()
                  print(jsonData)
                  
                  if responseModel.authorization {
                      completion(responseModel.success, responseModel.message)
                  }
                  else{
                      AuthorizationRequest.processAuthorizationFaild()
                  }
              } catch {
                  completion(false, kDefaultErrorMessage)
              }
            case .failure:
              completion(false, kDefaultErrorMessage)
            }
        }
    }
}

class DeleteBookNoteRequest:AuthorizationRequest{
    let provider = MoyaProvider<NoteRequestParams>(plugins: [NetworkLoggerPlugin(configuration: .init(formatter: .init(), output: NetworkLoggerPlugin.Configuration.defaultOutput, logOptions: .verbose))])
    
    var cancelation:Cancellable?
    func cancel() {
        cancelation?.cancel()
    }

    func run(noteId:String, completion: @escaping ((_ isSuccess:Bool, _ message:String?)->Void)) {
        cancel()
        guard let accessToken = LoginModel.current?.accessToken else {completion(false, kLogoutMessage); return}
        cancelation = provider.request(.deleteNote(noteId: noteId, token:accessToken)) { [weak self] result in
           guard let self = self else { return }
           self.cancelation = nil
        
            switch result {
            case .success(let response):
              do {
                  let responseModel = try JSONDecoder().decode(ResponseModel<String>.self, from: response.data)
                  
                  let jsonData = try response.mapJSON()
                  print(jsonData)
                  
                  if responseModel.authorization {
                      completion(responseModel.success, responseModel.message)
                  }
                  else{
                      AuthorizationRequest.processAuthorizationFaild()
                  }
              } catch {
                  completion(false, kDefaultErrorMessage)
              }
            case .failure:
              completion(false, kDefaultErrorMessage)
            }
        }
    }
}
