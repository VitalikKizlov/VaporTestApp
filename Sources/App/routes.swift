import Fluent
import Vapor

func routes(_ app: Application) throws {
    let acronymsController = AcronymController()
    let usersController = UserController()
    try app.register(collection: acronymsController)
    try app.register(collection: usersController)
}
