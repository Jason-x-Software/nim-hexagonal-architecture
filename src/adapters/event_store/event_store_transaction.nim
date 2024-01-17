import norm/[model, pragmas]
import std/[strutils]
import uuids
import ../../models/[transaction]

type
    EventStoreTransaction* = ref object of Model
        transactionId*: string
        walletId* {.uniqueGroup.} : string
        transactionType*: string
        transactionNonce* {.uniqueGroup.}: int
        amount*: int

proc newEventStoreTransaction*(transactionId: string = "", walletId: string = "", transactionType: string = "", transactionNonce: int = 0, amount: int = 0): EventStoreTransaction =
    EventStoreTransaction(
        transactionId: transactionId,
        walletId: walletId,
        transactionType: transactionType,
        transactionNonce: transactionNonce,
        amount: amount
    )

proc parseTransaction*(transaction: Transaction): EventStoreTransaction =
    EventStoreTransaction(
        transactionId: $transaction.id,
        walletId: $transaction.walletId,
        transactionType: $transaction.transactionType,
        transactionNonce: transaction.transactionNonce,
        amount: transaction.amount
    )

proc parseEventStoreTransaction*(eventStoreTransaction: EventStoreTransaction): Transaction =
    Transaction(
        id: parseUUID(eventStoreTransaction.transactionId),
        walletId: parseUUID(eventStoreTransaction.walletId),
        transactionType: parseEnum[TransactionType](eventStoreTransaction.transactionType),
        transactionNonce: eventStoreTransaction.transactionNonce,
        amount: eventStoreTransaction.amount
    )