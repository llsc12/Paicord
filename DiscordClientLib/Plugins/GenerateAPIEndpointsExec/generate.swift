import NIOHTTP1

let decoded = API.decode()

let grouped = Dictionary(grouping: decoded.paths) {
    $0.info.tags[0]
}.sorted(by: { $0.key.priority > $1.key.priority })

let cases = grouped.map { tag, infos in
    (tag, infos.map({ $0.info.makeCase() }))
}.map { tag, infos in
    """
    // MARK: \(tag.rawValue)
    /// \(tag.link)

    \(infos.joined(separator: "\n"))
    """
}.joined(separator: "\n\n")

let urlPrefixString = """
    var urlPrefix: String {
        "https://discord.com/api/v\\(DiscordGlobalConfiguration.apiVersion)/"
    }
    """

let noEncodeParamSuffixes = ["code", "Token"]
let doNotUseThisCaseDeclaration = """
    /// This case serves as a way of discouraging exhaustive switch statements
    case __DO_NOT_USE_THIS_CASE
    """
let doNotUseThisCaseCrash = """
    case .__DO_NOT_USE_THIS_CASE:
        fatalError("If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used")
    """

let _url = grouped.flatMap(\.value).map { info in
    let (name, params) = info.info.makeIterativeCase()
    var split = info.path.split(whereSeparator: { ["{", "}"].contains($0) })
    var iterator = params.makeIterator()
    var last: String? = nil
    for (idx, value) in split.enumerated() {
        let camel = value.toCamelCase()
        let param = last ?? iterator.next()
        if param == camel {
            split[idx] = #"\(\#(camel))"#
            last = nil
        } else {
            last = param
        }
    }
    var suffix = split.joined()
    guard suffix.removeFirst() == "/" else {
        fatalError("'\(split.joined())' did not start with a slash '/'")
    }
    let paramsEncoded = params.compactMap { param -> String? in
        if param == "answerId" {
            return nil
        } else if param.hasSuffix("Id") {
            return #"let \#(param) = \#(param).rawValue"#
        } else if noEncodeParamSuffixes.contains(where: { param.hasSuffix($0) }) {
            return nil
        } else {
            return #"let \#(param) = \#(param).urlPathEncoded()"#
        }
    }.joined(separator: "\n")
    let paramsEmpty = params.isEmpty || paramsEncoded.isEmpty
    let pramsWithNewLine = paramsEmpty ? "" : "\n" + paramsEncoded.indent()
    let ret = #"suffix = "\#(suffix)""#
    return name + pramsWithNewLine + "\n" + ret.indent()
}.joined(separator: "\n")

let urlString = """
    public var url: String {
        let suffix: String
        switch self {
    \(_url.indent())
    \(doNotUseThisCaseCrash.indent())
        }
        return self.urlPrefix + suffix
    }
    """

let webhookTokenParam = "webhookToken"

let _urlDescription = grouped.flatMap(\.value).map { info in
    let (name, params) = info.info.makeIterativeCase()
    var split = info.path.split(whereSeparator: { ["{", "}"].contains($0) })
    var iterator = params.makeIterator()
    var last: String? = nil
    for (idx, value) in split.enumerated() {
        let camel = value.toCamelCase()
        let param = last ?? iterator.next()
        if param == camel {
            split[idx] = #"\(\#(camel))"#
            last = nil
        } else {
            last = param
        }
    }
    var suffix = split.joined()
    guard suffix.removeFirst() == "/" else {
        fatalError("'\(split.joined())' did not start with a slash '/'")
    }
    let paramsEncoded = params.compactMap { param -> String? in
        if param == "answerId" {
            return nil
        } else if param.hasSuffix("Id") {
            return #"let \#(param) = \#(param).rawValue"#
        } else if param == webhookTokenParam {
            return #"let \#(param) = \#(param).urlPathEncoded().hash"#
        } else if noEncodeParamSuffixes.contains(where: { param.hasSuffix($0) }) {
            return nil
        } else {
            return #"let \#(param) = \#(param).urlPathEncoded()"#
        }
    }.joined(separator: "\n")
    let paramsEmpty = params.isEmpty || paramsEncoded.isEmpty
    let pramsWithNewLine = paramsEmpty ? "" : "\n" + paramsEncoded.indent()
    let ret = #"suffix = "\#(suffix)""#
    return name + pramsWithNewLine + "\n" + ret.indent()
}.joined(separator: "\n")

let urlDescriptionString = """
    public var urlDescription: String {
        let suffix: String
        switch self {
    \(_urlDescription.indent())
    \(doNotUseThisCaseCrash.indent())
        }
        return self.urlPrefix + suffix
    }
    """

let _methods = grouped.flatMap(\.value).map {
    $0.info.makeRawCaseName() + " return .\($0.method.rawValue)"
}.joined(separator: "\n")

let methodsString = """
    public var httpMethod: HTTPMethod {
        switch self {
    \(_methods.indent())
    \(doNotUseThisCaseCrash.indent())
        }
    }
    """

let _countsAgainstGlobalRateLimit = grouped.flatMap(\.value).map {
    $0.info.makeRawCaseName() + " return \($0.info.tags.contains(where: \.countsAgainstGlobalRateLimit))"
}.joined(separator: "\n")

let countsAgainstGlobalRateLimitString = """
    public var countsAgainstGlobalRateLimit: Bool {
        switch self {
    \(_countsAgainstGlobalRateLimit.indent())
    \(doNotUseThisCaseCrash.indent())
        }
    }
    """

let _requiresAuthorizationHeader = grouped.flatMap(\.value).map { info -> String in
    let (name, params) = info.info.makeRawCaseNameWithParams()
    let requires = !params.contains(webhookTokenParam)
    return name + " return \(requires)"
}.joined(separator: "\n")

let requiresAuthorizationHeaderString = """
    public var requiresAuthorizationHeader: Bool {
        switch self {
    \(_requiresAuthorizationHeader.indent())
    \(doNotUseThisCaseCrash.indent())
        }
    }
    """

let _parameters = grouped.flatMap(\.value).map { info -> String in
    let (name, _params) = info.info.makeIterativeCase()
    let params = _params.map { param in
        if param == "answerId" {
            return #""\(answerId)""#
        } else if param.hasSuffix("Id") {
            return "\(param).rawValue"
        } else {
            return param
        }
    }
    let ret = "return [\(params.joined(separator: ", "))]"
    return name + "\n" + ret.indent()
}.joined(separator: "\n")

let parametersString = """
    public var parameters: [String] {
        switch self {
    \(_parameters.indent())
    \(doNotUseThisCaseCrash.indent())
        }
    }
    """

let _description = grouped.flatMap(\.value).map { info -> String in
    let (name, _params) = info.info.makeIterativeCase()
    let params = _params.map { param in
        if param == "answerId" {
            return param
        } else if param.hasSuffix("Id") {
            return "\(param).rawValue"
        } else {
            return param
        }
    }
    let rawName = info.info.summary.toCamelCase()
    let paramsDescription = params.map {
        #"\#($0): \(\#($0))"#
    }.joined(separator: ", ")
    if params.isEmpty {
        return name + "\n" + #"return "\#(rawName)""#.indent()
    } else {
        let ret = #"return "\#(rawName)(\#(paramsDescription))""#
        return name + "\n" + ret.indent()
    }
}.joined(separator: "\n")

let descriptionString = """
    public var description: String {
        switch self {
    \(_description.indent())
    \(doNotUseThisCaseCrash.indent())
        }
    }
    """

let _id = grouped.flatMap(\.value).enumerated().map { idx, info in
    info.info.makeRawCaseName() + " return \(idx + 1)"
}.joined(separator: "\n")

let idString = """
    public var id: Int {
        switch self {
    \(_id.indent())
    \(doNotUseThisCaseCrash.indent())
        }
    }
    """

let cacheableCases = grouped.compactMap { tag, infos -> (API.Path.Info.Tag, [String])? in
    let filtered = infos.filter { $0.method == .GET }
    if filtered.isEmpty {
        return nil
    } else {
        return (tag, filtered.map(\.info).map { "case \($0.summary.toCamelCase())" })
    }
}.map { tag, infos in
    """
    // MARK: \(tag.rawValue)
    /// \(tag.link)

    \(infos.joined(separator: "\n"))
    """
}.joined(separator: "\n\n")

let _cacheableDescription = grouped.flatMap(\.value).filter {
    $0.method == .GET
}.map {
    $0.info.makeRawCaseName() + #" return "\#($0.info.summary.toCamelCase())""#
}.joined(separator: "\n")

let cacheableDescriptionString = """
    public var description: String {
        switch self {
    \(_cacheableDescription.indent())
    \(doNotUseThisCaseCrash.indent())
        }
    }
    """

let _cacheableInit = grouped.flatMap(\.value).filter {
    $0.method == .GET
}.map {
    $0.info.makeRawCaseName() + " self = .\($0.info.summary.toCamelCase())"
}.joined(separator: "\n")

let cacheableInitString = """
    init? (endpoint: APIEndpoint) {
        switch endpoint {
    \(_cacheableInit.indent())
    \(doNotUseThisCaseCrash.indent())
        default: return nil
        }
    }
    """

let result = """
    // DO NOT EDIT. Auto-generated using the GenerateAPIEndpoints command plugin.

    /// If you want to add an endpoint that somehow doesn't exist, you'll need to
    /// properly edit `/Plugins/GenerateAPIEndpointsExec/Resources/openapi.yml`, then trigger
    /// the `GenerateAPIEndpoints` plugin (right click on `DiscordBM` in the file navigator)

    import DiscordModels
    import NIOHTTP1

    public enum APIEndpoint: Endpoint {

    \(cases.indent())

    \(doNotUseThisCaseDeclaration.indent())

    \(urlPrefixString.indent())

    \(urlString.indent())

    \(urlDescriptionString.indent())

    \(methodsString.indent())

    \(countsAgainstGlobalRateLimitString.indent())

    \(requiresAuthorizationHeaderString.indent())

    \(parametersString.indent())

    \(idString.indent())

    \(descriptionString.indent())
    }

    public enum CacheableAPIEndpointIdentity: Int, Sendable, Hashable, CustomStringConvertible {

    \(cacheableCases.indent())

    \(doNotUseThisCaseDeclaration.indent())

    \(cacheableDescriptionString.indent())

    \(cacheableInitString.indent())
    }
    """
