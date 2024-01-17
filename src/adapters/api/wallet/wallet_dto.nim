type
    WalletRequestDto* = object
        transactionId*: string
        amount*: int
    WalletResponseDto* = object
        transactionId*: string
        transactionNonce*: int
        balance*: int