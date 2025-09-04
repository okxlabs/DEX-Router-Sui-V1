module 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::lending_market_registry {
    struct Registry has key {
        id: 0x2::object::UID,
        version: u64,
        lending_markets: 0x2::table::Table<0x1::type_name::TypeName, 0x2::object::ID>,
    }
    
    // decompiled from Move bytecode v6
}
