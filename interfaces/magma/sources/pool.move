module 0x4a35d3dfef55ed3631b7158544c6322a23bc434fe4fca1234cb680ce0505f82d::pool {

    use 0x4a35d3dfef55ed3631b7158544c6322a23bc434fe4fca1234cb680ce0505f82d::config::GlobalConfig;

    struct Pool<phantom T0, phantom T1> has store, key {
        id: 0x2::object::UID,
        coin_a: 0x2::balance::Balance<T0>,
        coin_b: 0x2::balance::Balance<T1>,
        tick_spacing: u32,
        fee_rate: u64,
        liquidity: u128,
        current_sqrt_price: u128,
        current_tick_index: 0x659c0e9c4c8a416f040fa758d4fc4073a5fdd1fed97edadcd5cba5180fb36246::i32::I32,
        fee_growth_global_a: u128,
        fee_growth_global_b: u128,
        fee_protocol_coin_a: u64,
        fee_protocol_coin_b: u64,
        tick_manager: 0x4a35d3dfef55ed3631b7158544c6322a23bc434fe4fca1234cb680ce0505f82d::tick::TickManager,
        rewarder_manager: 0x4a35d3dfef55ed3631b7158544c6322a23bc434fe4fca1234cb680ce0505f82d::rewarder::RewarderManager,
        position_manager: 0x4a35d3dfef55ed3631b7158544c6322a23bc434fe4fca1234cb680ce0505f82d::position::PositionManager,
        is_pause: bool,
        index: u64,
        url: 0x1::string::String,
        unstaked_liquidity_fee_rate: u64,
        magma_distribution_gauger_id: 0x1::option::Option<0x2::object::ID>,
        magma_distribution_growth_global: u128,
        magma_distribution_rate: u128,
        magma_distribution_reserve: u64,
        magma_distribution_period_finish: u64,
        magma_distribution_rollover: u64,
        magma_distribution_last_updated: u64,
        magma_distribution_staked_liquidity: u128,
        magma_distribution_gauger_fee: PoolFee,
    }

    struct PoolFee has drop, store {
        coin_a: u64,
        coin_b: u64,
    }

    struct FlashSwapReceipt<phantom T0, phantom T1> {
        pool_id: 0x2::object::ID,
        a2b: bool,
        partner_id: 0x2::object::ID,
        pay_amount: u64,
        fee_amount: u64,
        protocol_fee_amount: u64,
        ref_fee_amount: u64,
        gauge_fee_amount: u64,
    }

    public fun flash_swap<T0, T1>(
        config: &GlobalConfig,
        pool: &mut Pool<T0, T1>,
        a2b: bool,
        by_amount_in: bool,
        amount: u64,
        sqrt_price_limit: u128,
        clock: &0x2::clock::Clock
    ): (0x2::balance::Balance<T0>, 0x2::balance::Balance<T1>, FlashSwapReceipt<T0, T1>) {
        abort 0
    }

    public fun repay_flash_swap<T0, T1>(
        config: &GlobalConfig,
        pool: &mut Pool<T0, T1>,
        repay_token_a: 0x2::balance::Balance<T0>,
        repay_token_b: 0x2::balance::Balance<T1>,
        flash_receipt: FlashSwapReceipt<T0, T1>
    ) {
        abort 0
    }
}