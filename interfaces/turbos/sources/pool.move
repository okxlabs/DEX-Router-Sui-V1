module turbos_clmm::pool {
    use std::vector;
    use std::type_name;
    use sui::pay;
    use sui::event;
    use sui::transfer;
    use std::string::{Self, String};
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::dynamic_object_field as dof;
    use sui::dynamic_field as df;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use turbos_clmm::i32::{Self, I32};
    use sui::table::{Self, Table};
    use sui::clock::{Self, Clock};

    const VERSION: u64 = 13;
    const EWrongVersion: u64 = 23;

    struct Versioned has key, store {
        id: UID,
        version: u64,
    }
    
    struct PoolRewardInfo has key, store {
        id: UID,
        vault: address,
        vault_coin_type: String,
        emissions_per_second: u128,
        growth_global: u128,
        manager: address,
    }

    struct Pool<phantom CoinTypeA, phantom CoinTypeB, phantom FeeType> has key, store {
        id: UID,
        coin_a: Balance<CoinTypeA>,
        coin_b: Balance<CoinTypeB>,
        protocol_fees_a: u64,
        protocol_fees_b: u64,
        sqrt_price: u128,
        tick_current_index: I32,
        tick_spacing: u32,
        max_liquidity_per_tick: u128,
        fee: u32,
        fee_protocol: u32,
        unlocked: bool,
        fee_growth_global_a: u128,
        fee_growth_global_b: u128,
        liquidity: u128,
        tick_map: Table<I32, u256>,
        deploy_time_ms: u64,
        reward_infos: vector<PoolRewardInfo>,
        reward_last_updated_time_ms: u64,
    }

    public fun check_version(versioned: &Versioned) {
        assert!(versioned.version == VERSION, EWrongVersion);
    }
}