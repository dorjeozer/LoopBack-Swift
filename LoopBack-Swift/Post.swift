//
//  Model.swift
//  
//
//  Created by Jesse Sipola on 6.11.2015.
//  Copyright © 2015 . All rights reserved.
//
class Post: ModelClass {
    
    var id: Int?
    var name: String! = ""
    var post: String! = ""
    
    override init() {
        super.init()
    }

    override init!(repository: SLRepository!, parameters: [NSObject : AnyObject]!) {
        super.init(repository: repository, parameters: parameters)
    }
    
    override func loopbackClassName() -> String {
        return "Post"
    }
    
    override func getModelType() -> AnyClass? { return Post.self }
}