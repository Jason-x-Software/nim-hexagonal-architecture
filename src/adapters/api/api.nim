import prologue
import ../../domains/[wallet]
import ./wallet/[wallet_controller, wallet_inject_wallet_domain_middleware]

proc configureAndRunServer*(wallet: WalletDomain, settings: Settings) =
    var server = newApp(settings)

    server.use(injectWalletDomainMiddleware(wallet))
    server.addRoute(@[
        pattern("/{walletId}", getWalletHandler, HttpGet),
        pattern("/{walletId}/credit", creditWalletHandler, HttpPost),
        pattern("/{walletId}/debit", debitWalletHandler, HttpPost)
    ], "/wallets")
        
    server.run(WalletContext)