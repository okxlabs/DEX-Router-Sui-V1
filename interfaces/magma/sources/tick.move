module 0x4a35d3dfef55ed3631b7158544c6322a23bc434fe4fca1234cb680ce0505f82d::tick {
    struct TickManager has store {
        tick_spacing: u32,
        ticks: 0x682eaba7450909645bf949db3fc5881432a00b49b4c06d6974ecc4ee684e7992::skip_list::SkipList<Tick>,
    }
    struct Tick has copy, drop, store {
        index: 0x659c0e9c4c8a416f040fa758d4fc4073a5fdd1fed97edadcd5cba5180fb36246::i32::I32,
        sqrt_price: u128,
        liquidity_net: 0x659c0e9c4c8a416f040fa758d4fc4073a5fdd1fed97edadcd5cba5180fb36246::i128::I128,
        liquidity_gross: u128,
        fee_growth_outside_a: u128,
        fee_growth_outside_b: u128,
        points_growth_outside: u128,
        rewards_growth_outside: vector<u128>,
        magma_distribution_staked_liquidity_net: 0x659c0e9c4c8a416f040fa758d4fc4073a5fdd1fed97edadcd5cba5180fb36246::i128::I128,
        magma_distribution_growth_outside: u128,
    }
}