import Fluent
import Vapor

func routes(_ app: Application) throws {
    let acronymsController = AcronymController()
    try app.register(collection: acronymsController)
}
