module 0xb0575765166030556a6eafd3b1b970eba8183ff748860680245b9edd41c716e7::liquid_staking {
    struct LiquidStakingInfo<phantom T0> has store, key {
        id: 0x2::object::UID,
        lst_treasury_cap: 0x2::coin::TreasuryCap<T0>,
        fee_config: 0xb0575765166030556a6eafd3b1b970eba8183ff748860680245b9edd41c716e7::cell::Cell<0xb0575765166030556a6eafd3b1b970eba8183ff748860680245b9edd41c716e7::fees::FeeConfig>,
        fees: 0x2::balance::Balance<0x2::sui::SUI>,
        accrued_spread_fees: u64,
        storage: 0xb0575765166030556a6eafd3b1b970eba8183ff748860680245b9edd41c716e7::storage::Storage,
        version: 0xb0575765166030556a6eafd3b1b970eba8183ff748860680245b9edd41c716e7::version::Version,
        extra_fields: 0x2::bag::Bag,
    }
    
    struct AdminCap<phantom T0> has store, key {
        id: 0x2::object::UID,
    }
    
    // decompiled from Move bytecode v6
}
