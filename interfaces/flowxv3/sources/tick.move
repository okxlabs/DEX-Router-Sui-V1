module flowx_clmm::tick {

    use flowx_clmm::i64::{Self, I64};
    use flowx_clmm::i128::{Self, I128};

    struct TickInfo has copy, drop, store {
        liquidity_gross: u128,
        liquidity_net: I128,
        fee_growth_outside_x: u128,
        fee_growth_outside_y: u128,
        reward_growths_outside: vector<u128>,
        tick_cumulative_out_side: I64,
        seconds_per_liquidity_out_side: u256,
        seconds_out_side: u64
    }

}