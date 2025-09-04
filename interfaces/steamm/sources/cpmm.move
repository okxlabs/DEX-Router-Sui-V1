module 0x4fb1cf45dffd6230305f1d269dd1816678cc8e3ba0b747a813a556921219f261::cpmm {
    struct CpQuoter has store {
        version: 0x4fb1cf45dffd6230305f1d269dd1816678cc8e3ba0b747a813a556921219f261::version::Version,
        offset: u64,
    }
    
    public fun swap<T0, T1, T2: drop>(arg0: &mut 0x4fb1cf45dffd6230305f1d269dd1816678cc8e3ba0b747a813a556921219f261::pool::Pool<T0, T1, CpQuoter, T2>, arg1: &mut 0x2::coin::Coin<T0>, arg2: &mut 0x2::coin::Coin<T1>, arg3: bool, arg4: u64, arg5: u64, arg6: &mut 0x2::tx_context::TxContext) : 0x4fb1cf45dffd6230305f1d269dd1816678cc8e3ba0b747a813a556921219f261::pool::SwapResult {
        abort 0
    }
    
    // decompiled from Move bytecode v6
}
