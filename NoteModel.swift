import Foundation

struct NoteModel {
    public var id : Int!
    public var bookId : Int!
    public var text : String?
    public var comment : String?
    public var updatedAt : String!

    init(id:Int, bookId:Int, text:String?, comment:String?, updatedAt:String) {
        self.id = id
        self.bookId = bookId
        self.text = text
        self.comment = comment
        self.updatedAt = updatedAt
    }
}

extension NoteModel : Codable {
    enum NoteModelCodingKeys : String, CodingKey {
        case id
        case bookId = "book_id"
        case text
        case comment
        case updatedAt = "updated_at"
    }
    
    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: NoteModelCodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        bookId = try container.decode(Int.self, forKey: .bookId)
        text = try? container.decode(String.self, forKey: .text)
        comment = try? container.decode(String.self, forKey: .comment)
        updatedAt = try? container.decode(String.self, forKey: .updatedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NoteModelCodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(bookId, forKey: .bookId)
        try container.encode(text, forKey: .text)
        try container.encode(comment, forKey: .comment)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}

extension NoteModel: Equatable{
    static func == (lhs: NoteModel, rhs: NoteModel) -> Bool {
        return lhs.id == rhs.id
    }
}

extension NoteModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
