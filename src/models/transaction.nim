import uuids
import ../utils/[uuid]

type
    TransactionType* {.pure.} = enum
        CREDIT = "credit"
        DEBIT = "debit"

type
    Transaction* = ref object
        id*: UUID = DEFAULT_UUID
        walletId*: UUID = DEFAULT_UUID
        transactionType*: TransactionType = CREDIT
        transactionNonce*: int = 0
        amount*: int = 0