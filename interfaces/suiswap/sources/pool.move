module suiswap::pool {
    // https://suiscan.xyz/testnet/object/0xe158e6df182971bb6c85eb9de9fbfb460b68163d19afc45873c8672b5cc521b2
    
    use sui::tx_context::{TxContext};
    use sui::balance::{Balance};
    use suiswap::permission::{Permission};
    use sui::coin::{Self,Coin};
    use sui::object::{ID,UID};
    use sui::clock::Clock;

    // std moduiles
    use std::vector;
    use std::option::{Option};

    use suiswap::TOKEN::TokenBank;
    use suiswap::vpt::ValuePerToken;

    struct PoolCreateEvent has copy, drop, store {
        pool_id: ID
    }

    struct SwapTokenEvent has copy, drop {
        pool_id: ID,
        x_to_y: bool,
        in_amount: u64,
        out_amount: u64
    }

    struct LiquidityEvent has copy, drop {
        pool_id: ID,
        is_added: bool,
        x_amount: u64,
        y_amount: u64,
        lsp_amount: u64
    }

    struct SnapshotEvent has copy, drop, store {
        pool_id: ID,
        x: u64,
        y: u64
    }

    struct SwapCap has key {
        id: UID,
        registry_id: Option<ID>
    }

    struct PoolCreateInfo has copy, drop, store {
        pool_id: ID,
        reverse: bool
    }

    struct PoolCreateInfoKey<phantom Ty0, phantom Ty1> has copy, drop, store {
        dummy_field: bool
    }

    struct LSP<phantom Ty0, phantom Ty1> has drop {
        dummy_field: bool
    }

    struct PoolNoAdminSetupInfo has store {
        allowance: bool,
        fee_direction: u8,
        admin_fee: u64,
        lp_fee: u64,
        th_fee: u64,
        withdraw_fee: u64
    }

    struct PoolBoostMultiplierData has copy, drop, store {
        epoch: u64,
        boost_multiplier: u64
    }

    struct PoolRegistry has key {
        id: UID,
        pool_counter: u64,
        pool_no_admin: PoolNoAdminSetupInfo,
        pool_th_reward_nepoch: u64,
        pool_boost_multiplier_data: vector<PoolBoostMultiplierData>
    }

    struct PoolTotalTradeInfo has store {
        x: u128,
        y: u128,
        x_last_epoch: u128,
        y_last_epoch: u128,
        x_current_epoch: u128,
        y_current_epoch: u128
    }

    struct PoolTokenHolderRewardInfo<phantom Ty0, phantom Ty1> has store {
        type: u8,
        x: Balance<Ty0>,
        y: Balance<Ty1>,
        x_supply: u64,
        y_supply: u64,
        nepoch: u64,
        start_epcoh: u64,
        end_epoch: u64,
        total_stake_amount: u64,
        total_stake_boost: u128
    }

    struct PoolLiquidityMiningInfo has store {
        permission: Option<Permission<TokenBank>>,
        speed: u256,
        ampt: ValuePerToken,
        last_epoch: u64
    }

    struct PoolFeeInfo has store {
        direction: u8,
        admin: u64,
        lp: u64,
        th: u64,
        withdraw: u64
    }

    struct PoolBalanceInfo<phantom Ty0, phantom Ty1> has store {
        x: Balance<Ty0>,
        y: Balance<Ty1>,
        x_admin: Balance<Ty0>,
        y_admin: Balance<Ty1>,
        x_th: Balance<Ty0>,
        y_th: Balance<Ty1>
    }

    struct PoolStableInfo has store {
        amp: u64,
        x_scale: u64,
        y_scale: u64
    }

    struct Pool<phantom Ty0, phantom Ty1> has key {
        id: UID,
        index: u64,
        pool_type: u8,
        lsp_supply: u64,
        freeze: bool,
        trade_epoch: u64,
        boost_multiplier_data: vector<PoolBoostMultiplierData>,
        fee: PoolFeeInfo,
        stable: PoolStableInfo,
        balance: PoolBalanceInfo<Ty0, Ty1>,
        total_trade: PoolTotalTradeInfo,
        th_reward: PoolTokenHolderRewardInfo<Ty0, Ty1>,
        mining: PoolLiquidityMiningInfo
    }

    struct PoolLsp<phantom Ty0, phantom Ty1> has key {
        id: UID,
        pool_id: ID,
        value: u64,
        pool_x: u64,
        pool_y: u64,
        pool_mining_ampt: ValuePerToken,
        start_epoch: u64,
        end_epoch: u64,
        boost_multiplier: u64
    }

    public fun do_swap_x_to_y<Ty0, Ty1> (
        _pool: &mut Pool<Ty0, Ty1>,
        _coins: vector<Coin<Ty0>>,
        _amount_in: u64,
        _min_out: u64,
        _clock: &Clock,
        _arg5: &mut TxContext
    ) {
        abort 0
    }  

    public fun do_swap_y_to_x<Ty0, Ty1> (
        _pool: &mut Pool<Ty0, Ty1>,
        _coins: vector<Coin<Ty1>>,
        _amount_in: u64,
        _min_out: u64,
        _clock: &Clock,
        _arg5: &mut TxContext
    ) {
        abort 0
    }

    public fun do_swap_x_to_y_direct<T0, T1>(arg0: &mut Pool<T0, T1>, arg1: vector<0x2::coin::Coin<T0>>, arg2: u64, arg3: &0x2::clock::Clock, arg4: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T0>, 0x2::coin::Coin<T1>) {
        abort 0
    }

    public fun do_swap_y_to_x_direct<T0, T1>(arg0: &mut Pool<T0, T1>, arg1: vector<0x2::coin::Coin<T1>>, arg2: u64, arg3: &0x2::clock::Clock, arg4: &mut 0x2::tx_context::TxContext) : (0x2::coin::Coin<T1>, 0x2::coin::Coin<T0>) {
        abort 0
    }
}