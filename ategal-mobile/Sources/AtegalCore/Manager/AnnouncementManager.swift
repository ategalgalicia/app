//
//  Created by Michele Restuccia on 20/10/26.
//

import Foundation
import SkipFirebaseAuth
@preconcurrency import SkipFirebaseFirestore

#if os(Android)
import SkipFuse
#endif

@MainActor
public final class AnnouncementManager {
    private let auth: Auth
    private let firestore: Firestore

    public init(
        auth: Auth = .auth(),
        firestore: Firestore = .firestore()
    ) {
        self.auth = auth
        self.firestore = firestore
    }

    public func isAdministrator() async throws -> Bool {
        guard let user = auth.currentUser else { return false }
        let snapshot = try await firestore
            .collection("admins")
            .document(user.uid)
            .getDocument(source: .server)
        return snapshot.exists && auth.currentUser?.uid == user.uid
    }

    public func fetchAnnouncements() async throws -> [Announcement] {
        let snapshot = try await firestore
            .collection("announcements")
            .order(by: "publishedAt", descending: true)
            .getDocuments(source: .server)

        return try snapshot.documents.map { document in
            let data = document.data()
            guard let title = data["title"] as? String,
                  let body = data["body"] as? String,
                  let publishedAt = data["publishedAt"] as? Timestamp,
                  let topic = PushTopic(rawValue: data["topic"] as? String ?? "general") else {
                throw DecodingError.dataCorrupted(.init(
                    codingPath: [],
                    debugDescription: "Invalid announcement document"
                ))
            }
            var action: Announcement.Action? = nil
            if let storedAction = data["action"] {
                guard let payload = storedAction as? [String: String],
                      let decodedAction = Announcement.Action(payload: payload) else {
                    throw DecodingError.dataCorrupted(.init(
                        codingPath: [],
                        debugDescription: "Invalid announcement action"
                    ))
                }
                action = decodedAction
            }
            return Announcement(
                id: document.documentID,
                title: title,
                body: body,
                publishedAt: publishedAt.dateValue(),
                topic: topic,
                action: action
            )
        }
    }

    public func publish(_ request: AnnouncementRequest) async throws {
        guard request.isValid else {
            throw PublicationError.invalidRequest
        }
        guard let user = auth.currentUser,
              try await isAdministrator(),
              auth.currentUser?.uid == user.uid else {
            throw PublicationError.notAuthorized
        }
        var data: [String: Any] = [
                "title": request.title,
                "body": request.body,
                "topic": request.topic.rawValue,
                "authorID": user.uid,
                "publishedAt": FieldValue.serverTimestamp()
        ]
        if let action = request.action {
            data["action"] = action.payload
        }
        try await firestore
            .collection("announcements")
            .document(request.id)
            .setData(data)
    }

    public enum PublicationError: Error {
        case invalidRequest
        case notAuthorized
    }
}
