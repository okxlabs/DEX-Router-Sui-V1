module 0x4a35d3dfef55ed3631b7158544c6322a23bc434fe4fca1234cb680ce0505f82d::position {

    struct PositionManager has store {
        tick_spacing: u32,
        position_index: u64,
        positions: 0x682eaba7450909645bf949db3fc5881432a00b49b4c06d6974ecc4ee684e7992::linked_table::LinkedTable<0x2::object::ID, PositionInfo>,
    }

    struct PositionInfo has copy, drop, store {
        position_id: 0x2::object::ID,
        liquidity: u128,
        tick_lower_index: 0x659c0e9c4c8a416f040fa758d4fc4073a5fdd1fed97edadcd5cba5180fb36246::i32::I32,
        tick_upper_index: 0x659c0e9c4c8a416f040fa758d4fc4073a5fdd1fed97edadcd5cba5180fb36246::i32::I32,
        fee_growth_inside_a: u128,
        fee_growth_inside_b: u128,
        fee_owned_a: u64,
        fee_owned_b: u64,
        points_owned: u128,
        points_growth_inside: u128,
        rewards: vector<PositionReward>,
        magma_distribution_staked: bool,
        magma_distribution_growth_inside: u128,
        magma_distribution_owned: u64,
    }

    struct PositionReward has copy, drop, store {
        growth_inside: u128,
        amount_owned: u64,
    }



}