module 0x4fb1cf45dffd6230305f1d269dd1816678cc8e3ba0b747a813a556921219f261::pool {
    struct Pool<phantom T0, phantom T1, T2: store, phantom T3: drop> has store, key {
        id: 0x2::object::UID,
        quoter: T2,
        balance_a: 0x2::balance::Balance<T0>,
        balance_b: 0x2::balance::Balance<T1>,
        lp_supply: 0x2::balance::Supply<T3>,
        protocol_fees: 0x4fb1cf45dffd6230305f1d269dd1816678cc8e3ba0b747a813a556921219f261::fees::Fees<T0, T1>,
        pool_fee_config: 0x4fb1cf45dffd6230305f1d269dd1816678cc8e3ba0b747a813a556921219f261::fees::FeeConfig,
        trading_data: TradingData,
        version: 0x4fb1cf45dffd6230305f1d269dd1816678cc8e3ba0b747a813a556921219f261::version::Version,
    }
    
    struct TradingData has store {
        swap_a_in_amount: u128,
        swap_b_out_amount: u128,
        swap_a_out_amount: u128,
        swap_b_in_amount: u128,
        protocol_fees_a: u64,
        protocol_fees_b: u64,
        pool_fees_a: u64,
        pool_fees_b: u64,
    }
    
    struct SwapResult has copy, drop, store {
        user: address,
        pool_id: 0x2::object::ID,
        amount_in: u64,
        amount_out: u64,
        output_fees: 0x4fb1cf45dffd6230305f1d269dd1816678cc8e3ba0b747a813a556921219f261::quote::SwapFee,
        a2b: bool,
        balance_a: u64,
        balance_b: u64,
    }
    
    // decompiled from Move bytecode v6
}
