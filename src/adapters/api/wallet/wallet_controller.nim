import prologue
import std/[json]
import uuids
import ../../../domains/[wallet]
import ../../../models/[wallet, wallet_exception]
import ./[wallet_dto, wallet_inject_wallet_domain_middleware]

proc getWalletHandler*(ctx: Context) {.async.} =
    let ctx = WalletContext(ctx)
    let walletId = parseUUID(ctx.getPathParams("walletId"))

    try:
        let wallet = ctx.walletDomain.getWallet(walletId)

        resp jsonResponse(%WalletResponseDto(
            transactionId: $wallet.latestTransactionId,
            transactionNonce: wallet.latestTransactionNonce,
            balance: wallet.balance
        ), Http200)
    except WalletNotFoundException as exception:
        resp(jsonResponse(%*{
            "message": exception.msg
        }, Http404))
    except:
        resp(jsonResponse(%*{
            "message": "Something went wrong."
        }, Http500))

proc creditWalletHandler*(ctx: Context) {.async.} =
    let ctx = WalletContext(ctx)
    let walletId = parseUUID(ctx.getPathParams("walletId"))
    let transaction = to(parseJson(ctx.request.body()), WalletRequestDto)

    try:
        let wallet = ctx.walletDomain.creditWallet(
            walletId,
            parseUUID(transaction.transactionId),
            transaction.amount
        )

        resp(jsonResponse(%WalletResponseDto(
            transactionId: $wallet.latestTransactionId,
            transactionNonce: wallet.latestTransactionNonce,
            balance: wallet.balance
        ), Http201))
    except DuplicateTransactionException:
        let wallet = ctx.walletDomain.getWallet(walletId)

        resp(jsonResponse(%WalletResponseDto(
            transactionId: $wallet.latestTransactionId,
            transactionNonce: wallet.latestTransactionNonce,
            balance: wallet.balance
        ), Http202))
    except InsufficientBalanceException as exception:
        resp(jsonResponse(%*{
            "message": exception.msg
        }, Http400))
    except NegativeCreditException as exception:
        resp(jsonResponse(%*{
            "message": exception.msg
        }, Http400))
    except:
        resp(jsonResponse(%*{
            "message": "Something went wrong."
        }, Http500))

proc debitWalletHandler*(ctx: Context) {.async.} =
    let ctx = WalletContext(ctx)
    let walletId = parseUUID(ctx.getPathParams("walletId"))
    let transaction = to(parseJson(ctx.request.body()), WalletRequestDto)

    try:
        let wallet = ctx.walletDomain.debitWallet(
            walletId,
            parseUUID(transaction.transactionId),
            transaction.amount
        )

        resp(jsonResponse(%WalletResponseDto(
            transactionId: $wallet.latestTransactionId,
            transactionNonce: wallet.latestTransactionNonce,
            balance: wallet.balance
        ), Http201))
    except DuplicateTransactionException:
        let wallet = ctx.walletDomain.getWallet(walletId)

        resp(jsonResponse(%WalletResponseDto(
            transactionId: $wallet.latestTransactionId,
            transactionNonce: wallet.latestTransactionNonce,
            balance: wallet.balance
        ), Http202))
    except InsufficientBalanceException as exception:
        resp(jsonResponse(%*{
            "message": exception.msg
        }, Http400))
    except NegativeDebitException as exception:
        resp(jsonResponse(%*{
            "message": exception.msg
        }, Http400))
    except:
        resp(jsonResponse(%*{
            "message": "Something went wrong."
        }, Http500))