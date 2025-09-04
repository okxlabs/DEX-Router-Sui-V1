module 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::config {
    struct StakingConfig has store {
        deposit_fee: u64,
        reward_fee: u64,
        validator_reward_fee: u64,
        service_fee: u64,
        withdraw_time_limit: u64,
        validator_count: u64,
    }
    
    struct StakingConfigCreated has copy, drop {
        deposit_fee: u64,
        reward_fee: u64,
        validator_reward_fee: u64,
        service_fee: u64,
        withdraw_time_limit: u64,
        validator_count: u64,
    }
    
    struct StakingFeeConfigUpdated has copy, drop {
        name: vector<u8>,
        old: u64,
        new: u64,
    }
    
    public fun get_deposit_fee(arg0: &StakingConfig) : u64 {
        abort 0
    }
    
    public fun get_reward_fee(arg0: &StakingConfig) : u64 {
        abort 0
    }
    
    public fun get_service_fee(arg0: &StakingConfig) : u64 {
        abort 0
    }
    
    public fun get_validator_count(arg0: &StakingConfig) : u64 {
        abort 0
    }
    
    public fun get_validator_reward_fee(arg0: &StakingConfig) : u64 {
        abort 0
    }
    
    public fun get_withdraw_time_limit(arg0: &StakingConfig) : u64 {
        abort 0
    }
    
    public(friend) fun new(arg0: u64, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: u64) : StakingConfig {
        abort 0
    }
    
    fun new_event(arg0: u64, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: u64) {
        abort 0
    }
    
    public(friend) fun set_deposit_fee(arg0: &mut StakingConfig, arg1: u64) {
        abort 0
    }
    
    public(friend) fun set_reward_fee(arg0: &mut StakingConfig, arg1: u64) {
        abort 0
    }
    
    public(friend) fun set_service_fee(arg0: &mut StakingConfig, arg1: u64) {
        abort 0
    }
    
    public(friend) fun set_validator_count(arg0: &mut StakingConfig, arg1: u64) {
        abort 0
    }
    
    public(friend) fun set_validator_reward_fee(arg0: &mut StakingConfig, arg1: u64) {
        abort 0
    }
    
    public(friend) fun set_withdraw_time_limit(arg0: &mut StakingConfig, arg1: u64) {
        abort 0
    }
    
    // decompiled from Move bytecode v6
}

