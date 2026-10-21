//
//  Created by Michele Restuccia on 20/10/26.
//

import Foundation
import Observation
import RStudioKit
import SkipFirebaseAuth
@preconcurrency import SkipFirebaseFirestore

#if os(Android)
import SkipFuse
#endif

@MainActor
@Observable
public final class AnnouncementManager {
    private let auth: Auth
    private let firestore: Firestore

    @ObservationIgnored
    @UserDefaultsBacked(key: "inbox-read-announcements")
    private var storedReadIDs: [String: Set<String>] = [:]

    @ObservationIgnored
    @UserDefaultsBacked(key: "push-selected-city-topics")
    private var storedPushTopics: Set<PushTopic> = []

    public var selectedPushTopics: Set<PushTopic> {
        storedPushTopics
    }

    public func setPushTopics(_ topics: Set<PushTopic>) async {
        guard storedPushTopics != topics else { return }
        storedPushTopics = topics
        reset()
        if auth.currentUser != nil {
            _ = try? await fetchAnnouncements()
        }
    }

    public private(set) var announcements: [Announcement] = []
    private var readIDs: Set<String> = []
    private var userID: String?

    @ObservationIgnored
    private var fetchTask: Task<[Announcement], Error>?

    public var unreadCount: Int {
        announcements.filter { !readIDs.contains($0.id) }.count
    }

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
        guard let uid = auth.currentUser?.uid else {
            reset()
            throw PublicationError.notAuthorized
        }
        if userID != uid {
            reset()
            userID = uid
            readIDs = storedReadIDs[uid] ?? []
        }

        let topics = storedPushTopics.union([.general])
        let task = fetchTask ?? Task {
            let cutoff = Date().addingTimeInterval(-30 * 24 * 60 * 60)
            let snapshot = try await firestore.collection("announcements")
                .whereField("topic", in: topics.map(\.rawValue).sorted())
                .whereField("publishedAt", isGreaterThanOrEqualTo: Timestamp(date: cutoff))
                .order(by: "publishedAt", descending: true)
                .limit(to: 20)
                .getDocuments(source: .server)
            return try Self.decode(snapshot)
        }
        fetchTask = task

        do {
            let announcements = try await task.value
            guard userID == uid, auth.currentUser?.uid == uid,
                  storedPushTopics.union([.general]) == topics else {
                throw CancellationError()
            }
            self.announcements = announcements
            return announcements
        } catch {
            if userID == uid && storedPushTopics.union([.general]) == topics {
                fetchTask = nil
            }
            throw error
        }
    }

    public func reset() {
        fetchTask?.cancel()
        fetchTask = nil
        userID = nil
        announcements = []
        readIDs = []
    }

    public func isUnread(_ id: String) -> Bool {
        !readIDs.contains(id)
    }

    public func markRead(_ id: String) {
        guard let userID, auth.currentUser?.uid == userID,
              announcements.contains(where: { $0.id == id }),
              readIDs.insert(id).inserted else { return }
        storedReadIDs[userID] = readIDs
    }

    nonisolated private static func decode(_ snapshot: QuerySnapshot) throws -> [Announcement] {
        try snapshot.documents.map { document in
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
        fetchTask = nil
        _ = try? await fetchAnnouncements()
    }

    public enum PublicationError: Error {
        case invalidRequest
        case notAuthorized
    }
}
