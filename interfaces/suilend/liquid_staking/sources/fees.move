module 0xb0575765166030556a6eafd3b1b970eba8183ff748860680245b9edd41c716e7::fees {
    struct FeeConfig has store {
        sui_mint_fee_bps: u64,
        staked_sui_mint_fee_bps: u64,
        redeem_fee_bps: u64,
        staked_sui_redeem_fee_bps: u64,
        spread_fee_bps: u64,
        custom_redeem_fee_bps: u64,
        extra_fields: 0x2::bag::Bag,
    }
    
    // decompiled from Move bytecode v6
}
