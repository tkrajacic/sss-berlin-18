import Vapor

final class SecretMiddleware: Middleware {
    private let secret: String
    
    init(secret: String) {
        self.secret = secret
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        guard let auth = request.http.headers.firstValue(name: .authorization) else {
            throw Abort.init(.unauthorized, reason: "Please include Authorization header.")
        }
        guard auth == "Bearer \(secret)" else {
            throw Abort.init(.unauthorized, reason: "Incorrect secret.")

        }
        return try next.respond(to: request)
    }
}

// So it can be used in the DI container
extension SecretMiddleware: Service {}
