module 0xb53b0f4174108627fbee72e2498b58d6a2714cded53fac537034c220d26302::price_feed {
    struct PriceFeed has copy, drop, store {
        price_identifier: 0xb53b0f4174108627fbee72e2498b58d6a2714cded53fac537034c220d26302::price_identifier::PriceIdentifier,
        price: 0xb53b0f4174108627fbee72e2498b58d6a2714cded53fac537034c220d26302::price::Price,
        ema_price: 0xb53b0f4174108627fbee72e2498b58d6a2714cded53fac537034c220d26302::price::Price,
    }
    
    
    // decompiled from Move bytecode v6
}
