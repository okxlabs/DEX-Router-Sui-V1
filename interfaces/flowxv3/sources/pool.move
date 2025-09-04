module flowx_clmm::pool {
    use std::type_name::TypeName;

    use sui::balance::Balance;
    use sui::clock::Clock;
    use sui::object::{ID, UID};
    use sui::table::Table;
    use sui::tx_context::TxContext;

    use flowx_clmm::i32::{I32};
    use flowx_clmm::oracle::{Observation};
    use flowx_clmm::tick::{TickInfo};
    use flowx_clmm::versioned::{Versioned};

    struct Pool<phantom CoinX, phantom CoinY> has key, store {
        id: UID,
        coin_type_x: TypeName,
        coin_type_y: TypeName,
        // the current price
        sqrt_price: u128,
        // the current tick
        tick_index: I32,
        observation_index: u64,
        observation_cardinality: u64,
        observation_cardinality_next: u64,
        // the pool tick spacing
        tick_spacing: u32,
        max_liquidity_per_tick: u128,
        // the current protocol fee as a percentage of the swap fee taken on withdrawal
        // represented as an integer denominator (1/x)%
        protocol_fee_rate: u64,
        // used for the swap fee, either static at initialize or dynamic via hook
        swap_fee_rate: u64,
        fee_growth_global_x: u128,
        fee_growth_global_y: u128,
        protocol_fee_x: u64,
        protocol_fee_y: u64,
        // the currently in range liquidity available to the pool
        liquidity: u128,
        ticks: Table<I32, TickInfo>,
        tick_bitmap: Table<I32, u256>,
        observations: vector<Observation>,
        locked: bool,
        reward_infos: vector<PoolRewardInfo>,
        reserve_x: Balance<CoinX>,
        reserve_y: Balance<CoinY>,
    }

    struct PoolRewardInfo has copy, store, drop {
        reward_coin_type: TypeName,
        last_update_time: u64,
        ended_at_seconds: u64,
        total_reward: u64,
        total_reward_allocated: u64,
        reward_per_seconds: u128,
        reward_growth_global: u128
    }

    struct SwapReceipt {
        pool_id: ID,
        amount_x_debt: u64,
        amount_y_debt: u64
    }

    public fun swap_receipt_debts(receipt: &SwapReceipt): (u64, u64) { abort 0 }

    public fun swap<X, Y>(
        self: &mut Pool<X, Y>,
        x_for_y: bool,
        exact_in: bool,
        amount_specified: u64,
        sqrt_price_limit: u128,
        versioned: &Versioned,
        clock: &Clock,
        ctx: &TxContext
    ): (Balance<X>, Balance<Y>, SwapReceipt) {
        abort 0
    }

    public fun pay<X, Y>(
        self: &mut Pool<X, Y>,
        receipt: SwapReceipt,
        payment_x: Balance<X>,
        payment_y: Balance<Y>,
        versioned: &Versioned,
        ctx: &TxContext
    ) {
        abort 0
    }
}
