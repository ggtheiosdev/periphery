import Foundation
import Shared
import PeripheryKit

final class JsonFormatter: OutputFormatter {
    public static func make() -> Self {
        return self.init(logger: inject())
    }

    private let logger: Logger

    required public init(logger: Logger) {
        self.logger = logger
    }

    public func perform(_ declarations: [Declaration]) throws {
        var jsonObject: [Any] = []

        declarations.forEach {
            let object: [AnyHashable: Any] = [
                "kind": $0.kind.rawValue,
                "name": $0.name ?? "",
                "modifiers": Array($0.modifiers),
                "attributes": Array($0.attributes),
                "accessibility": $0.accessibility.value.rawValue,
                "ids": Array($0.usrs),
                "hints": $0.analyzerHints.map { String(describing: $0) },
                "location": $0.location.description
            ]
            jsonObject.append(object)
        }

        let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
        let json = String(data: data, encoding: .utf8)
        logger.info(json ?? "", canQuiet: false)
    }
}
