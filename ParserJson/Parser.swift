//
//  Parser.swift
//  ParserJson
//
//  Created by Valerio Ferrucci on 11/11/14.
//  Copyright (c) 2014 Valerio Ferrucci. All rights reserved.
//

import Foundation

enum ReaderResult {
    case Value(NSData)
    case Error(NSError)
}

enum PhotoResult {
    case Value(Photo)
    case Error(NSError)
}

class Parser {

    // the reader is a func that receive a completion as parameter (called on finish)
    typealias ParserReader = (ReaderResult->())->()
    typealias ParserNewPhoto = (PhotoResult)->Bool
    
    func StringFromJSON(ao : AnyObject?) -> String? {
        return ao as? String
    }
    func DoubleFromJSON(ao : AnyObject?) -> Double? {
        return ao as? Double
    }
    
    func handleData(data : NSData, parserNewPhoto : ParserNewPhoto) -> NSError? {

        var error : NSError?
        let json : AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error)

        if let _json = json as? [AnyObject] {
            
            for jsonItem in _json {
                
                if let _jsonItem = jsonItem as? [String: AnyObject] {
         
                    var ok = false
                    var toStop = false
                    if let _titolo = StringFromJSON(_jsonItem["titolo"]) {
                        if let _autore = StringFromJSON(_jsonItem["autore"]) {
                            if let _latitudine = DoubleFromJSON(_jsonItem["latitudine"]) {
                                if let _longitudine = DoubleFromJSON(_jsonItem["longitudine"]) {
                                    if let _data = StringFromJSON(_jsonItem["data"]) {
                                        if let _descr = StringFromJSON(_jsonItem["descr"]) {
                                            
                                            let photo = Photo(titolo: _titolo, autore: _autore, latitudine: _latitudine, longitudine: _longitudine, data: _data, descr: _descr)
                                            toStop = parserNewPhoto(PhotoResult.Value(photo))
                                            if toStop {
                                                break
                                            }
                                            ok = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if (!ok) {
                        // don't override error
                        let photoError = NSError(domain: "Parser", code: 101, userInfo: [NSLocalizedDescriptionKey:"Errore su un elemento dell'array"])
                        parserNewPhoto(PhotoResult.Error(photoError))
                    }
                }
            }
        } else {
            error = NSError(domain: "Parser", code: 100, userInfo: [NSLocalizedDescriptionKey:"Json is not an array of objects"])
        }
        
        return error
    }
    
    func start(reader : ParserReader, errorCallBack : (NSError) -> (), parserNewPhoto : ParserNewPhoto) {
        
        var error : NSError?
        
        // read the file
        reader() { (result : ReaderResult)->() in
            
            switch result {
            case let .Error(readError):
                error = readError
                
            case let .Value(fileData):
                error = self.handleData(fileData, parserNewPhoto)
            }
            
            if let _error = error {
                errorCallBack(error!)
            }
        }
    }
}