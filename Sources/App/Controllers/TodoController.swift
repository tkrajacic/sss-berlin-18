import Vapor

/// Controls basic CRUD operations on `Todo`s.
final class TodoController {
    /// Returns a list of all `Todo`s.
    func index(_ req: Request) throws -> Future<[Todo.Outgoing]> {
        return Todo.query(on: req).all().map { todos in
            return try todos.map { todo in
                return try todo.makeOutgoing(with: req)
            }
        }
    }
    
    func update(_ req: Request) throws -> Future<Todo.Outgoing> {
        let todo = try req.parameters.next(Todo.self)
        let incoming = try req.content.decode(Todo.Incoming.self)
        return try flatMap(to: Todo.self, todo, incoming) { (todo, incoming) -> EventLoopFuture<Todo> in
            return todo.patched(with: incoming).update(on: req)
            }.makeOutgoing(with: req)
    }
    
    func view(_ req: Request) throws -> Future<Todo.Outgoing> {
        return try req.parameters
            .next(Todo.self)
            .makeOutgoing(with: req)
    }

    /// Saves a decoded `Todo` to the database.
    func create(_ req: Request) throws -> Future<Todo.Outgoing> {
        return try req.content.decode(Todo.Incoming.self).flatMap { incoming in
            return incoming.makeTodo().save(on: req)
        }.makeOutgoing(with: req)
    }

    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Todo.self).flatMap { todo in
            return todo.delete(on: req)
        }.transform(to: .ok)
    }
    
    func clear(_ req: Request) throws -> Future<HTTPStatus> {
        return Todo.query(on: req).delete().transform(to: .ok)
    }
}
