import prologue
import ../../../domains/[wallet]

type
    WalletContext* = ref object of Context
        walletDomain*: WalletDomain

proc setWallet*(self: WalletContext, walletDomain: WalletDomain) =
    self.walletDomain = walletDomain

proc injectWalletDomainMiddleware*(walletDomain: WalletDomain): HandlerAsync =
    result = proc(ctx: Context) {.async.} =
        let ctx = WalletContext(ctx)

        ctx.setWallet(walletDomain)

        await switch(ctx)