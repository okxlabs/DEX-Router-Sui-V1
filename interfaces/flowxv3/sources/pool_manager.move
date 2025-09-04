module flowx_clmm::pool_manager {

    use sui::object::{Self, UID, ID};
    use sui::table::{Self, Table};

    use flowx_clmm::pool::{Self, Pool};

    struct PoolRegistry has key, store {
        id: UID,
        fee_amount_tick_spacing: Table<u64, u32>,
        num_pools: u64
    }

    public fun borrow_mut_pool<X, Y>(self: &mut PoolRegistry, fee_rate: u64): &mut Pool<X, Y> {
        abort 0
    }

}