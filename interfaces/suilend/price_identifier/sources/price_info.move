module 0x8d97f1cd6ac663735be08d1d2b6d02a159e711586461306ce60a2b7a6a565a9e::price_info {
    struct PriceInfoObject has store, key {
        id: 0x2::object::UID,
        price_info: PriceInfo,
    }
    
    struct PriceInfo has copy, drop, store {
        attestation_time: u64,
        arrival_time: u64,
        price_feed: 0x8d97f1cd6ac663735be08d1d2b6d02a159e711586461306ce60a2b7a6a565a9e::price_feed::PriceFeed,
    }
    
    // decompiled from Move bytecode v6
}
