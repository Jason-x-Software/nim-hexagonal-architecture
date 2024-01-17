import dotenv
import norm/[pool, sqlite]
import prologue
import std/[os, strutils]
import adapters/api/[api]
import adapters/event_store/[event_store_sqlite]
import domains/[wallet]

when isMainModule:
    dotenv.load()
    
    let eventStoreAdapter = newEventStoreSqliteAdapter(newPool[DbConn](parseInt(getEnv("DB_POOL", "16"))))
    let walletDomainInstance = WalletDomain(eventStore: eventStoreAdapter)
    let serverSettings = newSettings(
        appName = getEnv("SERVER_NAME", "Wallet"),
        address = getEnv("SERVER_ADDRESS", "127.0.0.1"),
        port = Port(parseInt(getEnv("SERVER_PORT", "8080"))),
        debug = parseBool(getEnv("SERVER_DEBUG", "true"))
    )

    eventStoreAdapter.createTables()
    configureAndRunServer(walletDomainInstance, serverSettings)
