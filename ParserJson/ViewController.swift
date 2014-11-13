//
//  ViewController.swift
//  ParserJson
//
//  Created by Valerio Ferrucci on 05/11/14.
//  Copyright (c) 2014 Valerio Ferrucci. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()

        let parserTestReader = readJsonFile("test")
        let parser = Parser()
        parser.start(parserTestReader, { (error : NSError) in println(error) } ) { (photoResult : PhotoResult) -> Bool in
            
            switch photoResult {
            case let .Error(photoError):
                println("Errore: " + photoError.localizedDescription)
                
            case let .Value(photo):
                println(photo.data + ": " + photo.titolo)
                
            }
            
            return false    // continue always
        }
    }

    func readJsonFile(jsonFileName : String)(completion : ReaderResult->()) {
        
        var fileData : NSData?
        var error : NSError?
        let filePath : String? = NSBundle.mainBundle().pathForResource(jsonFileName, ofType: "json")
        
        if let _filePath = filePath {
            
            fileData = NSData(contentsOfFile: _filePath, options:.DataReadingUncached, error: &error)
        
        } else {
            
            error = NSError(domain: "ParserReader", code: 100, userInfo: [NSLocalizedDescriptionKey:"The file was not found"]);
        }
        
        var result : ReaderResult
        if (error != nil) {
            result = ReaderResult.Error(error!)
        } else {
            result = ReaderResult.Value(fileData!)
        }
        completion(result)
    }
}

