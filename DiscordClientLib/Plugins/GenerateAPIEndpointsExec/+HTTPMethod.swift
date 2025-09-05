import NIOHTTP1

extension HTTPMethod {
    var priority: Int {
        switch self {
        case .GET: return 1
        case .PUT: return 2
        case .ACL: return 3
        case .HEAD: return 4
        case .POST: return 5
        case .COPY: return 6
        case .LOCK: return 7
        case .MOVE: return 8
        case .BIND: return 9
        case .LINK: return 10
        case .PATCH: return 11
        case .TRACE: return 12
        case .MKCOL: return 13
        case .MERGE: return 14
        case .PURGE: return 15
        case .NOTIFY: return 16
        case .SEARCH: return 17
        case .UNLOCK: return 18
        case .REBIND: return 19
        case .UNBIND: return 20
        case .REPORT: return 21
        case .DELETE: return 22
        case .UNLINK: return 23
        case .CONNECT: return 24
        case .MSEARCH: return 25
        case .OPTIONS: return 26
        case .PROPFIND: return 27
        case .CHECKOUT: return 28
        case .PROPPATCH: return 29
        case .SUBSCRIBE: return 30
        case .MKCALENDAR: return 31
        case .MKACTIVITY: return 32
        case .UNSUBSCRIBE: return 33
        case .SOURCE: return 34
        case .RAW: return 35
        }
    }
}
