//
//  Utilities.swift
//  
//
//  Created by Jesse Sipola on 6.11.2015.
//  Copyright © 2015 . All rights reserved.
//

import Foundation

class DatabaseQuery {
    
    var className: String
    var filters = [String : AnyObject]()
    
    init(className: String) {
        self.className = className
    }
    
    func whereKeyEquals(key: String, value: String) {
        self.filters["filter[where]"] = [key:value]
    }
    
    func fetchResultsInBackground(completion: ((results: [LBModel]?, error: NSError?) -> ())? = nil) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate!
        
        let errorBlock = {
            (error: NSError!) -> () in
            completion?(results: nil, error: error)
        }
        
        let successBlock = {
            (results: [AnyObject]!) -> () in
            if let results = results as? [LBModel] {
                let dictionaries = results.map { $0.toDictionary() }
                if let repository = appDelegate.registeredModels[self.className]?.getRepository() {
                    let posts: [LBModel]? = dictionaries.map { repository.modelWithDictionary($0) }
                    completion?(results: posts, error: nil)
                } else {
                    completion?(results: results, error: nil)
                }
            } else {
                completion?(results: results as? [LBModel], error: nil)
            }
        }
        
        let filterSuccessBlock = {
            (results: AnyObject!) -> () in
            if let repository = appDelegate.registeredModels[self.className]?.getRepository() {
                let resultsArray = results as! NSArray
                var resultsModelArray: [LBModel] = []
                for result in resultsArray {
                    resultsModelArray.append(repository.modelWithDictionary(result as! [NSObject:AnyObject]))
                }
                completion?(results: resultsModelArray, error: nil)
            } else {
                completion?(results: results as? [LBModel], error: nil)
            }
        }
        
        if let adapter = appDelegate.adapter {
            let productList = adapter.repositoryWithModelName(self.className)
            if filters.isEmpty {
                productList.allWithSuccess(successBlock, failure: errorBlock)
            } else {
                adapter.contract.addItem(SLRESTContractItem(pattern: "/posts", verb: "GET"), forMethod: "posts.filter")
                productList.invokeStaticMethod("filter", parameters: filters, success: filterSuccessBlock, failure: errorBlock)
            }
        }
    }
}