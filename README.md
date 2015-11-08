# LoopBack-Swift
Parse.com like LoopBack.io implementation for Swift.

At the moment supports for saving and fetching. 

## Examples

### Creating a model of ModelClass subclass Post
```
let post = Post()
post.name = "Ultrahack 2015"
post.post = "Creating this piece of code was lots of fun."

model.saveInBackground {
  (success, error) -> Void in
  if error == nil {
    print("Hurray!")
  }
}
```
### Fetching Post model
```
let query = LBQuery("Post")
query.whereKeyEquals("name", "Ultrahack 2015")
query.fetchResultsInBackground {
  (results, error) -> Void in
  if error == nil {
    if let posts = results as? [Post] {
      self.post = posts.first
    }
  }
}
```
