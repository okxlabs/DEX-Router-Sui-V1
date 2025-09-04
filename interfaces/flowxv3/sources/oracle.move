module flowx_clmm::oracle {

    use flowx_clmm::i64::{Self, I64};

    struct Observation has copy, drop, store {
        timestamp_s: u64,
        tick_cumulative: I64,
        seconds_per_liquidity_cumulative: u256,
        initialized: bool
    }

}