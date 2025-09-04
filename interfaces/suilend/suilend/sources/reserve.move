module 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::reserve {
    struct Reserve<phantom T0> has store, key {
        id: 0x2::object::UID,
        lending_market_id: 0x2::object::ID,
        array_index: u64,
        coin_type: 0x1::type_name::TypeName,
        config: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::cell::Cell<0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::reserve_config::ReserveConfig>,
        mint_decimals: u8,
        price_identifier: 0x8d97f1cd6ac663735be08d1d2b6d02a159e711586461306ce60a2b7a6a565a9e::price_identifier::PriceIdentifier,
        price: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        smoothed_price: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        price_last_update_timestamp_s: u64,
        available_amount: u64,
        ctoken_supply: u64,
        borrowed_amount: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        cumulative_borrow_rate: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        interest_last_update_timestamp_s: u64,
        unclaimed_spread_fees: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        attributed_borrow_value: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        deposits_pool_reward_manager: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::liquidity_mining::PoolRewardManager,
        borrows_pool_reward_manager: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::liquidity_mining::PoolRewardManager,
    }
    
    struct CToken<phantom T0, phantom T1> has drop {
        dummy_field: bool,
    }
    
    struct LiquidityRequest<phantom T0, phantom T1> {
        amount: u64,
        fee: u64,
    }
    
    struct BalanceKey has copy, drop, store {
        dummy_field: bool,
    }
    
    struct StakerKey has copy, drop, store {
        dummy_field: bool,
    }
    
    struct Balances<phantom T0, phantom T1> has store {
        available_amount: 0x2::balance::Balance<T1>,
        ctoken_supply: 0x2::balance::Supply<CToken<T0, T1>>,
        fees: 0x2::balance::Balance<T1>,
        ctoken_fees: 0x2::balance::Balance<CToken<T0, T1>>,
        deposited_ctokens: 0x2::balance::Balance<CToken<T0, T1>>,
    }
    
    struct InterestUpdateEvent has copy, drop {
        lending_market_id: address,
        coin_type: 0x1::type_name::TypeName,
        reserve_id: address,
        cumulative_borrow_rate: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        available_amount: u64,
        borrowed_amount: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        unclaimed_spread_fees: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        ctoken_supply: u64,
        borrow_interest_paid: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        spread_fee: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        supply_interest_earned: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        borrow_interest_paid_usd_estimate: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        protocol_fee_usd_estimate: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        supply_interest_earned_usd_estimate: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
    }
    
    struct ReserveAssetDataEvent has copy, drop {
        lending_market_id: address,
        coin_type: 0x1::type_name::TypeName,
        reserve_id: address,
        available_amount: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        supply_amount: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        borrowed_amount: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        available_amount_usd_estimate: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        supply_amount_usd_estimate: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        borrowed_amount_usd_estimate: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        borrow_apr: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        supply_apr: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        ctoken_supply: u64,
        cumulative_borrow_rate: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        price: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        smoothed_price: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        price_last_update_timestamp_s: u64,
    }
    
    struct ClaimStakingRewardsEvent has copy, drop {
        lending_market_id: address,
        coin_type: 0x1::type_name::TypeName,
        reserve_id: address,
        amount: u64,
    }
    
    // decompiled from Move bytecode v6
}
