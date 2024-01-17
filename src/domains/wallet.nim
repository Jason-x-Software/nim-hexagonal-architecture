import std/[strformat]
import uuids
import ../models/[transaction, wallet, wallet_exception]
import ../ports/[event_store]
import ../utils/[uuid]

type
    WalletDomain* = ref object
        eventStore*: EventStorePort

proc reduceTransactions(self: WalletDomain, wallet: Wallet, transactions: seq[Transaction]): Wallet =
    for _, transaction in transactions:
        case transaction.transactionType:
            of CREDIT:
                wallet.balance += transaction.amount
            of DEBIT:
                wallet.balance -= transaction.amount

        if wallet.balance < 0:
            raise InsufficientBalanceException.newException(&"Insufficient balance {$wallet.balance}.")

        wallet.latestTransactionNonce += 1
        wallet.latestTransactionId = transaction.id

    result = wallet

proc processTransaction(self: WalletDomain, walletId: UUID, transactionId: UUID, transactionType: TransactionType, amount: int): Wallet =
    if amount < 0:
        case transactionType:
            of CREDIT:
                raise NegativeCreditException.newException(&"Negative credit amount {$amount}.")
            of DEBIT:
                raise NegativeDebitException.newException(&"Negative debit amount {$amount}.")

    let transactions = self.eventStore.getTransactionsByWalletId(walletId)
    var wallet = Wallet(id: walletId)

    wallet = self.reduceTransactions(wallet, transactions)

    if transactionId == wallet.latestTransactionId:
        raise DuplicateTransactionException.newException(&"Transaction {$transactionId} already processed.")
    if transactionId == DEFAULT_UUID:
        raise InvalidTransactionException.newException(&"Invalid transaction id {$transactionId}.")

    let transaction = Transaction(
        id: transactionId,
        transactionType: transactionType,
        transactionNonce: wallet.latestTransactionNonce,
        amount: amount
    )

    wallet = self.reduceTransactions(wallet, @[transaction])
    self.eventStore.addTransaction(transaction)

    result = wallet

proc getWallet*(self: WalletDomain, walletId: UUID): Wallet =
    let transactions = self.eventStore.getTransactionsByWalletId(walletId)

    if transactions.len == 0:
        raise WalletNotFoundException.newException(&"Wallet {$walletId} not found.")
    
    let wallet = Wallet(id: walletId)

    result = self.reduceTransactions(wallet, transactions)

proc creditWallet*(self: WalletDomain, walletId: UUID, transactionId: UUID, amount: int): Wallet =
    result = self.processTransaction(walletId, transactionId, CREDIT, amount)

proc debitWallet*(self: WalletDomain, walletId: UUID, transactionId: UUID, amount: int): Wallet =
    result = self.processTransaction(walletId, transactionId, DEBIT, amount)