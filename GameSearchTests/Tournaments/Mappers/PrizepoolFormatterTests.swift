//
//  PrizepoolFormatterTests.swift
//  GameSearchTests
//

import XCTest
@testable import GameSearch

final class PrizepoolFormatterTests: XCTestCase {

    func test_parse_validString_extractsAmountAndCurrency() throws {
        let result = try XCTUnwrap(PrizepoolFormatter.parse("1250000 United States Dollar"))
        XCTAssertEqual(result.amount, Decimal(1_250_000))
        XCTAssertEqual(result.currency, "United States Dollar")
    }

    func test_parse_nilOrEmpty_returnsNil() {
        XCTAssertNil(PrizepoolFormatter.parse(nil))
        XCTAssertNil(PrizepoolFormatter.parse(""))
    }

    func test_parse_amountWithCommas_succeeds() throws {
        let result = try XCTUnwrap(PrizepoolFormatter.parse("1,250,000 USD"))
        XCTAssertEqual(result.amount, Decimal(1_250_000))
    }

    func test_formatted_aboveMillion_usesShortForm() {
        let prizepool = Prizepool(amount: Decimal(1_250_000), currency: "USD")
        XCTAssertEqual(PrizepoolFormatter.formatted(prizepool), "$1.25M")
    }

    func test_formatted_belowMillion_usesGroupedForm() {
        let prizepool = Prizepool(amount: Decimal(250_000), currency: "USD")
        let formatted = PrizepoolFormatter.formatted(prizepool)
        XCTAssertTrue(formatted.hasPrefix("$"))
        XCTAssertTrue(formatted.contains("250"))
    }
}
