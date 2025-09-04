module slippage_check::slippage_check {
    use mmt_v3::pool::{Self, Pool};

    public fun assert_slippage<T0, T1>(arg0: &mut Pool<T0, T1>, arg1: u128, arg2: bool) {
        abort 0
    }
}