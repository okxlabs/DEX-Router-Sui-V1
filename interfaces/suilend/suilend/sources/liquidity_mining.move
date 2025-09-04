module 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::liquidity_mining {
    struct PoolRewardManager has store, key {
        id: 0x2::object::UID,
        total_shares: u64,
        pool_rewards: vector<0x1::option::Option<PoolReward>>,
        last_update_time_ms: u64,
    }
    
    struct PoolReward has store, key {
        id: 0x2::object::UID,
        pool_reward_manager_id: 0x2::object::ID,
        coin_type: 0x1::type_name::TypeName,
        start_time_ms: u64,
        end_time_ms: u64,
        total_rewards: u64,
        allocated_rewards: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        cumulative_rewards_per_share: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        num_user_reward_managers: u64,
        additional_fields: 0x2::bag::Bag,
    }
    
    struct RewardBalance<phantom T0> has copy, drop, store {
        dummy_field: bool,
    }
    
    struct UserRewardManager has store {
        pool_reward_manager_id: 0x2::object::ID,
        share: u64,
        rewards: vector<0x1::option::Option<UserReward>>,
        last_update_time_ms: u64,
    }
    
    struct UserReward has store {
        pool_reward_id: 0x2::object::ID,
        earned_rewards: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
        cumulative_rewards_per_share: 0xf95b06141ed4a174f239417323bde3f209b972f5930d8521ea38a52aff3a6ddf::decimal::Decimal,
    }
    
    // decompiled from Move bytecode v6
}
