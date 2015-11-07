//
//  LBModel.swift
//  
//
//  Created by Jesse Sipola on 7.11.2015.
//  Copyright © 2015 . All rights reserved.
//

import Foundation

class ModelClass: LBModel {

    func getModelType() -> AnyClass? { return nil }
    func getModelName() -> String? { return nil }
    
    func saveInBackground(completion: ((success: Bool, error: NSError!) -> ())? = nil) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate!
        
        let errorBlock = {
            (error: NSError!) -> () in
            completion?(success: false, error: error)
        }
        
        let successBlock = {
            () -> () in
            completion?(success: true, error: nil)
        }
        
        if let modelClass = getModelType(), let modelName = getModelName(), let adapter = appDelegate.adapter {
            let repository = adapter.repositoryWithModelName(modelName)
            repository.modelClass = modelClass
            // Create a reflection of the used model for getting all the variables and values
            let reflection = Mirror(reflecting: self)
            var attributeDictionary = [String : AnyObject]()
            for (index, attribute) in reflection.children.enumerate() {
                if let property_name = attribute.label as String! {
                    if property_name != "modelName" || property_name != "modelType" {
                        if let property_value = attribute.value as? String {
                            attributeDictionary[property_name] = property_value
                        }
                    }
                }
            }
            let model = repository.modelWithDictionary(attributeDictionary) as! ModelClass
            model.saveWithSuccess(successBlock, failure: errorBlock)
        } else {
            print("Error: Model needs to have modelClass, modelName variables set for saving.")
        }
    }
    
    func getRepository() -> LBModelRepository? {
        if let modelClass = getModelType() {
            if let modelName = getModelName() {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate!
                if let adapter = appDelegate.adapter {
                    let repository = adapter.repositoryWithModelName(modelName)
                    repository.modelClass = modelClass
                    return repository
                }
            } else {
                print("Error: Model needs to have modelName variable set for saving.")
            }
        } else {
            print("Error: Model needs to have modelClass variable set for saving.")
        }
        return nil
    }
}