import Foundation

class LBQuery {
    /**
    Name of ModelClass subclass
    */
    var className: String
    private var filters = [String : AnyObject]()
    
    init(className: String) {
        self.className = className
    }
    /**
    Adds equals filter to the query.
    - Parameter key: attribute name.
    - Parameter value: attribute value.
    */
    func whereKeyEquals(key: String, value: String) {
        self.filters["filter[where]"] = [key:value]
    }
    /**
    Callback to run after server response.
    - Parameter results: Fetched results.
    - Parameter error: Error.
    */
    typealias LBQueryResultsBlock = (results: [LBModel]?, error: NSError?) -> ()
    /**
    Sends request to the server and fetches asked models.
    If no filters are attached to the query, returs all instances of the requested class.
    - Parameter completion: Callback function.
    */
    func fetchResultsInBackground(completion: LBQueryResultsBlock? = nil) {
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
            if let pluralName = appDelegate.registeredApiPlurals[self.className] {
                let productList = adapter.repositoryWithModelName(pluralName)
                if filters.isEmpty {
                    productList.allWithSuccess(successBlock, failure: errorBlock)
                } else {
                    adapter.contract.addItem(SLRESTContractItem(pattern: "/\(pluralName)", verb: "GET"), forMethod: "\(pluralName).filter")
                    productList.invokeStaticMethod("filter", parameters: filters, success: filterSuccessBlock, failure: errorBlock)
                }
            }
        }
    }
}