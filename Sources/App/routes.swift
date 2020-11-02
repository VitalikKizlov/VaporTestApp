import Fluent
import Vapor

func routes(_ app: Application) throws {
    let usersController = UserController()
    let authController = AuthController()
    try app.register(collection: authController)
    try app.register(collection: usersController)
}
