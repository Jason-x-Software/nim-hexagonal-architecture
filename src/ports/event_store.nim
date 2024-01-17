import uuids
import ../models/[transaction]

type
    EventStorePort* = ref object of RootObj

method addTransaction*(self: EventStorePort, transaction: Transaction): void {.base.} = discard

method getTransactionsByWalletId*(self: EventStorePort, walletId: UUID): seq[Transaction] {.base.} = discard