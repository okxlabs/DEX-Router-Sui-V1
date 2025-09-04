module 0x4fb1cf45dffd6230305f1d269dd1816678cc8e3ba0b747a813a556921219f261::fees {
    struct Fees<phantom T0, phantom T1> has store {
        config: FeeConfig,
        fee_a: 0x2::balance::Balance<T0>,
        fee_b: 0x2::balance::Balance<T1>,
    }
    
    struct FeeConfig has copy, drop, store {
        fee_numerator: u64,
        fee_denominator: u64,
        min_fee: u64,
    }
    
    // decompiled from Move bytecode v6
}
