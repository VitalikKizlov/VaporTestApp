import Fluent
import Vapor

func routes(_ app: Application) throws {
    let acronymsController = AcronymController()
    let usersController = UserController()
    let categoriesController = CategoryController()
    try app.register(collection: acronymsController)
    try app.register(collection: usersController)
    try app.register(collection: categoriesController)
}
