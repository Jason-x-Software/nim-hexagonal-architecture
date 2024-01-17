import norm/[pool, sqlite]
import std/[strutils]
import uuids
import ./[event_store_transaction]
import ../../models/[transaction]
import ../../ports/[event_store]

type
    EventStoreSqliteAdapter = ref object of EventStorePort
        dbPool: Pool[DbConn]

proc newEventStoreSqliteAdapter*(dbPool: Pool[DbConn]): EventStoreSqliteAdapter =
    EventStoreSqliteAdapter(dbPool: dbPool)

proc createTables*(self: EventStoreSqliteAdapter): void =
    withDb self.dbPool:
        db.createTables(newEventStoreTransaction())

method addTransaction*(self: EventStoreSqliteAdapter, transaction: Transaction): void =
    var eventStoreTransaction = parseTransaction(transaction)

    withDb self.dbPool:
        db.insert(eventStoreTransaction)

method getTransactionsByWalletId*(self: EventStoreSqliteAdapter, walletId: UUID): seq[Transaction] =
    var transactions: seq[Transaction]
    var eventStoreTransactions = @[newEventStoreTransaction()]

    withDb self.dbPool:
        db.select(eventStoreTransactions, "walletId = ? ORDER BY version ASC", $walletId)

    for eventStoreTransaction in eventStoreTransactions:
        transactions.add(parseEventStoreTransaction(eventStoreTransaction))

    result = transactions