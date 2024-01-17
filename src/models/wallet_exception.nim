type
    WalletException* = object of CatchableError
    WalletNotFoundException* = object of WalletException
    InsufficientBalanceException* = object of WalletException
    NegativeCreditException* = object of WalletException
    NegativeDebitException* = object of WalletException
    DuplicateTransactionException* = object of WalletException
    InvalidTransactionException* = object of WalletException