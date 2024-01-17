import uuids
import ../utils/[uuid]

type
    Wallet* = ref object
        id*: UUID = DEFAULT_UUID
        latestTransactionId*: UUID = DEFAULT_UUID
        latestTransactionNonce*: int = 0
        balance*: int = 0