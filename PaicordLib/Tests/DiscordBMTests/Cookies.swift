//
//  Cookies.swift
//  PaicordLib
//
//  Created by Lakhan Lothiyi on 10/09/2025.
//  Copyright © 2025 Lakhan Lothiyi.
//  

import XCTest
import NIOHTTP1
@testable import DiscordHTTP

final class Cookies: XCTestCase {
	func testCookies() async throws {
		let c = CookieStore()
		let headers: HTTPHeaders = [
			"set-cookie": "__cf_bm=oDArIUJUGLW6bdrvAzN4IF3DRVtw5fMloZdJUaP4CQs-1757525679-1.0.1.1-3G_iduEeg_ja8cRfOZP9ZajMVGYPPP8BP.cgnuTydLfftKcKXAbVTfS6EIX0y2HSJ3UMNWsqfbl_XfyPBGxeT_v8Snp8L0oeBrjYGoet1O4; path=/; expires=Wed, 10-Sep-25 18:04:39 GMT; domain=.realtime.chatgpt.com; HttpOnly; Secure; SameSite=None"
		]
		await c.checkIncomingHeaders(headers)
		let cookies = await c.cookies
		print(cookies)
	}
}
