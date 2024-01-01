//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/4/18.
//

import Foundation

// MARK: - DemoData

enum DemoData {
    static let checking = Account(name: "Checking", kind: .asset, initialValue: 200)
    static let cash = Account(name: "Cash", kind: .asset, initialValue: 20)
    static let studentCard = Account(name: "Student Card", kind: .asset, initialValue: 50)
    static let savings = Account(name: "Savings", kind: .asset, initialValue: 5000)
    static let investment = Account(name: "Investment", kind: .asset, initialValue: 20000)

    static let creditCard = Account(name: "Credit Card", kind: .liability, initialValue: 0)
    static let loan = Account(name: "Loan", kind: .liability, initialValue: 0)
    static let mortgage = Account(name: "Mortgage", kind: .liability, initialValue: 50000)

    static let food = Account(name: "Food", kind: .expense, initialValue: 0)
    static let transportation = Account(name: "Transportation", kind: .expense, initialValue: 0)
    static let shopping = Account(name: "Shopping", kind: .expense, initialValue: 0)
    static let groceries = Account(name: "Groceries", kind: .expense, initialValue: 0)
    static let houseRent = Account(name: "House Rent", kind: .expense, initialValue: 0)
    static let health = Account(name: "Health", kind: .expense, initialValue: 0)

    static let salary = Account(name: "Salary", kind: .revenue, initialValue: 0)
    static let investmentIncome = Account(name: "Investment Income", kind: .revenue, initialValue: 0)
    static let appSales = Account(name: "App Sales", kind: .revenue, initialValue: 0)

    static let accounts = [
        checking, cash, studentCard, savings, investment,
        creditCard, loan, mortgage,
        food, transportation, shopping, groceries, houseRent, health,
        salary, investmentIncome, appSales,
    ]

    static let records: [Record] = {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: endDate)!

        var allRecords = [Record]()

        // MARK: - Daily

        let dailyBreakfastRecords = generateDailyRecords(
            name: "Breakfast",
            tag: .food,
            debitAccount: food,
            creditAccount: cash,
            amount: 3,
            startDate: startDate,
            endDate: endDate,
            time: (hour: 8, minute: 0)
        )
        allRecords.append(contentsOf: dailyBreakfastRecords)

        let dailyLunchRecords = generateDailyRecords(
            name: "Lunch",
            tag: .food,
            debitAccount: food,
            creditAccount: studentCard,
            amount: 6,
            startDate: startDate,
            endDate: endDate,
            time: (hour: 12, minute: 0)
        )
        allRecords.append(contentsOf: dailyLunchRecords)

        let dailyDinnerRecords = generateDailyRecords(
            name: "Dinner",
            tag: .food,
            debitAccount: food,
            creditAccount: creditCard,
            amount: 9,
            startDate: startDate,
            endDate: endDate,
            time: (hour: 18, minute: 0)
        )
        allRecords.append(contentsOf: dailyDinnerRecords)

        let dailyTransportationRecords = generateDailyRecords(
            name: "Transportation",
            tag: .transportation,
            debitAccount: transportation,
            creditAccount: cash,
            amount: 5,
            startDate: startDate,
            endDate: endDate,
            time: (hour: 8, minute: 0)
        )
        allRecords.append(contentsOf: dailyTransportationRecords)

        let dailyCoffeeRecords = generateDailyRecords(
            name: "Coffee",
            tag: .food,
            debitAccount: food,
            creditAccount: cash,
            amount: 4,
            startDate: startDate,
            endDate: endDate,
            time: (hour: 9, minute: 0)
        )
        allRecords.append(contentsOf: dailyCoffeeRecords)

        // MARK: - Monthly

        // Generate monthly records for rent and salary
        let monthlyRentRecords = generateMonthlyRecords(
            name: "House Rent",
            tag: .housing,
            debitAccount: houseRent,
            creditAccount: checking,
            amount: 1000,
            startDate: startDate,
            endDate: endDate,
            dayOfMonth: 1
        )
        allRecords.append(contentsOf: monthlyRentRecords)

        let monthlySalaryRecords = generateMonthlyRecords(
            name: "Salary",
            tag: .income,
            debitAccount: checking,
            creditAccount: salary,
            amount: 5000,
            startDate: startDate,
            endDate: endDate,
            dayOfMonth: 15
        )
        allRecords.append(contentsOf: monthlySalaryRecords)

        let monthlyGroceriesRecords = generateMonthlyRecords(
            name: "Groceries",
            tag: .utilities,
            debitAccount: groceries,
            creditAccount: checking,
            amount: 300,
            startDate: startDate,
            endDate: endDate,
            dayOfMonth: 10
        )
        allRecords.append(contentsOf: monthlyGroceriesRecords)

        let monthlyInvestmentRecords = generateMonthlyRecords(
            name: "Investment",
            tag: .investment,
            debitAccount: investment,
            creditAccount: checking,
            amount: 1000,
            startDate: startDate,
            endDate: endDate,
            dayOfMonth: 20
        )
        allRecords.append(contentsOf: monthlyInvestmentRecords)

        let monthlyCashWithdrawalRecords = generateMonthlyRecords(
            name: "Cash Withdrawal",
            tag: .income,
            debitAccount: cash,
            creditAccount: checking,
            amount: 400,
            startDate: startDate,
            endDate: endDate,
            dayOfMonth: 5
        )
        allRecords.append(contentsOf: monthlyCashWithdrawalRecords)

        let monthlyStudentCardRechargeRecords = generateMonthlyRecords(
            name: "Student Card Recharge",
            tag: .education,
            debitAccount: studentCard,
            creditAccount: checking,
            amount: 200,
            startDate: startDate,
            endDate: endDate,
            dayOfMonth: 10
        )
        allRecords.append(contentsOf: monthlyStudentCardRechargeRecords)

        let monthlyShoppingRecords = generateMonthlyRecords(
            name: "Monthly Shopping",
            tag: .shopping,
            debitAccount: shopping,
            creditAccount: creditCard,
            amount: 50,
            startDate: startDate,
            endDate: endDate,
            dayOfMonth: 10
        )
        allRecords.append(contentsOf: monthlyShoppingRecords)

        let monthlyAppSalesRecords = generateMonthlyRecords(
            name: "App Sales Revenue",
            tag: .income,
            debitAccount: checking,
            creditAccount: appSales,
            amount: 500,
            startDate: startDate,
            endDate: endDate,
            dayOfMonth: 25
        )
        allRecords.append(contentsOf: monthlyAppSalesRecords)

        let monthlyCreditCardRepaymentRecords = generateMonthlyRecords(
            name: "Credit Card Repayment",
            tag: .investment,
            debitAccount: creditCard,
            creditAccount: checking,
            amount: 50,
            startDate: startDate,
            endDate: endDate,
            dayOfMonth: 15
        )
        allRecords.append(contentsOf: monthlyCreditCardRepaymentRecords)

        let monthlyMortgageRepaymentRecords = generateMonthlyRecords(
            name: "Mortgage Repayment",
            tag: .investment,
            debitAccount: mortgage,
            creditAccount: checking,
            amount: 2000,
            startDate: startDate,
            endDate: endDate,
            dayOfMonth: 15
        )
        allRecords.append(contentsOf: monthlyMortgageRepaymentRecords)

        // MARK: - one time

        let buyIPhone = Record(
            name: "Buy iPhone",
            amount: 799,
            creditAccount: creditCard,
            debitAccount: shopping,
            date: Date(),
            tag: .shopping
        )
        allRecords.append(buyIPhone)

        let oneTimeInvestmentIncomeRecord = Record(
            name: "Investment Income",
            amount: 30000,
            creditAccount: investmentIncome,
            debitAccount: investment,
            date: Date().addingTimeInterval(-24 * 60 * 60 * 7),
            tag: .income
        )
        allRecords.append(oneTimeInvestmentIncomeRecord)

        let healthInsurancePremium = Record(
            name: "Health Insurance Premium",
            amount: 200,
            creditAccount: checking,
            debitAccount: health,
            date: Date().addingTimeInterval(-24 * 60 * 60 * 24),
            tag: .health
        )
        allRecords.append(healthInsurancePremium)

        return allRecords
    }()
}

private func generateDailyRecords(
    name: String,
    tag: Tag,
    debitAccount: Account,
    creditAccount: Account,
    amount: Double,
    startDate: Date,
    endDate: Date,
    time: (hour: Int, minute: Int)
) -> [Record] {
    var records = [Record]()
    var currentDate = startDate
    while currentDate <= endDate {
        let date = Calendar.current.date(bySettingHour: time.hour, minute: time.minute, second: 0, of: currentDate)!
        let record = Record(
            name: name,
            amount: amount,
            creditAccount: creditAccount,
            debitAccount: debitAccount,
            date: date,
            tag: tag
        )
        records.append(record)
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
    }
    return records
}

private func generateMonthlyRecords(
    name: String,
    tag: Tag,
    debitAccount: Account,
    creditAccount: Account,
    amount: Double,
    startDate: Date,
    endDate: Date,
    dayOfMonth: Int
) -> [Record] {
    var records = [Record]()
    var currentDate = startDate
    while currentDate <= endDate {
        let dateComponents = DateComponents(
            year: Calendar.current.component(.year, from: currentDate),
            month: Calendar.current.component(.month, from: currentDate),
            day: dayOfMonth
        )
        let date = Calendar.current.date(from: dateComponents)!
        let record = Record(
            name: name,
            amount: amount,
            creditAccount: creditAccount,
            debitAccount: debitAccount,
            date: date,
            tag: tag
        )
        records.append(record)
        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!
    }
    return records
}
