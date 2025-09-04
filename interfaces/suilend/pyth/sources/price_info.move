module 0xb53b0f4174108627fbee72e2498b58d6a2714cded53fac537034c220d26302::price_info {
    struct PriceInfoObject has store, key {
        id: 0x2::object::UID,
        price_info: PriceInfo,
    }
    
    struct PriceInfo has copy, drop, store {
        attestation_time: u64,
        arrival_time: u64,
        price_feed: 0xb53b0f4174108627fbee72e2498b58d6a2714cded53fac537034c220d26302::price_feed::PriceFeed,
    }
    
    // decompiled from Move bytecode v6
}
