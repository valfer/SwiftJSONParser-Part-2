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
    typealias ParserNewPhoto = (PhotoResult)->()
    
    func handleData(data : NSData, parserNewPhoto : ParserNewPhoto) -> NSError? {

        var error : NSError?
        let json : AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error)

        if let _json = json as? [AnyObject] {
            
            for jsonItem in _json {
                
                if let _jsonItem = jsonItem as? [String: AnyObject] {
         
                    let titolo : AnyObject? = _jsonItem["titolo"]
                    let autore : AnyObject? = _jsonItem["autore"]
                    let latitudine : AnyObject? = _jsonItem["latitudine"]
                    let longitudine : AnyObject? = _jsonItem["longitudine"]
                    let data : AnyObject? = _jsonItem["data"]
                    let descr : AnyObject? = _jsonItem["descr"]

                    var ok = false
                    if let _titolo = titolo as String? {
                        if let _autore = autore as? String {
                            if let _latitudine = latitudine as? Double {
                                if let _longitudine = longitudine as? Double {
                                    if let _data = data as? String {
                                        if let _descr = descr as? String {
                                            
                                            let photo = Photo(titolo: _titolo, autore: _autore, latitudine: _latitudine, longitudine: _longitudine, data: _data, descr: _descr)
                                            parserNewPhoto(PhotoResult.Value(photo))
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
            error = NSError(domain: "Parser", code: 100, userInfo: [NSLocalizedDescriptionKey:"Json non contiene un array di oggetti"])
        }
        
        return error
    }
    
    func start(reader : ParserReader, parserNewPhoto : ParserNewPhoto) -> NSError? {
        
        var error : NSError?
        
        // read the file
        reader() { (result : ReaderResult)->() in
            
            switch result {
            case let .Error(readError):
                error = readError
                
            case let .Value(fileData):
                error = self.handleData(fileData, parserNewPhoto)
                
            }
        }
        
        return error
    }
}