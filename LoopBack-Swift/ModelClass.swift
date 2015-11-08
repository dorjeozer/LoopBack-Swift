//
//  LBModel.swift
//  
//
//  Created by Jesse Sipola on 7.11.2015.
//  Copyright © 2015 . All rights reserved.
//

import Foundation

class ModelClass: LBModel {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate!
    /**
    Identifying subclass class name for LBModelRepository to use correct data. Needs to be defined in subclass.
    */
    func getModelType() -> AnyClass? {
        preconditionFailure("This method must be overridden")
    }
    /** 
    Callback function for saving.
    */
    typealias LBQuerySuccessBlock = (success: Bool, error: NSError!) -> ()
    /** 
    Saves object in background silently or with a LBQuerySuccessBlock.
    - Parameter completion: Completion block to run after server response.
    */
    func saveInBackground(completion: LBQuerySuccessBlock? = nil) {
        let errorBlock = {
            (error: NSError!) -> () in
            completion?(success: false, error: error)
        }
        let successBlock = {
            () -> () in
            completion?(success: true, error: nil)
        }
        
        if let repository = getRepository() {
            // Create a reflection of the used model for getting all the attributes and their values
            let reflection = Mirror(reflecting: self)
            var attributeDictionary = [String : AnyObject]()
            for (_, attribute) in reflection.children.enumerate() {
                if let property_name = attribute.label as String!, let property_value = attribute.value as? String {
                    if property_name != "modelName" || property_name != "modelType" {
                        attributeDictionary[property_name] = property_value
                    }
                }
            }
            // Let repository create the model.
            let model = repository.modelWithDictionary(attributeDictionary) as! ModelClass
            model.saveWithSuccess(successBlock, failure: errorBlock)
        } else {
            print("Error: Model needs to have modelClass, modelName variables set for saving.")
        }
    }
    /**
    Returns repository to use for fetching and saving.
    - Returns: LBModelRepository with corresponding ModelClass attached to it.
    */
    func getRepository() -> LBModelRepository? {
        if let modelClass = getModelType() {
            if let modelName = appDelegate.registeredApiPlurals[self.loopbackClassName()] {
                if let adapter = appDelegate.adapter {
                    let repository = adapter.repositoryWithModelName(modelName)
                    repository.modelClass = modelClass
                    return repository
                } else {
                    print("Error: Adapter needs to be set.")
                }
            } else {
                print("Error: Model needs to have modelName variable set for saving.")
            }
        } else {
            print("Error: Model needs to have modelClass variable set for saving.")
        }
        return nil
    }
    /**
    Class name is needed for queries.
    */
    func loopbackClassName() -> String {
        preconditionFailure("This method must be overridden")
    }
    /**
    Register subclass in Application Delegate. Needs to have getModelType() and loopbackClassName() defined.
    */
    func registerSubclass(pluralName pluralName: String) {
        appDelegate.registeredModels[self.loopbackClassName()] = self
        appDelegate.registeredApiPlurals[self.loopbackClassName()] = pluralName
    }

}