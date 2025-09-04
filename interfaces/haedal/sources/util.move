module 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::util {
    public fun calculate_rewards(arg0: &mut 0x3::sui_system::SuiSystemState, arg1: 0x2::object::ID, arg2: u64, arg3: u64, arg4: u64) : u64 {
        abort 0
    }
    
    public fun get_sui_amount(arg0: &0x3::staking_pool::PoolTokenExchangeRate, arg1: u64) : u64 {
        abort 0
    }
    
    public fun get_token_amount(arg0: &0x3::staking_pool::PoolTokenExchangeRate, arg1: u64) : u64 {
        abort 0
    }
    
    public fun mul_div(arg0: u64, arg1: u64, arg2: u64) : u64 {
        abort 0
    }
    
    public fun pool_token_exchange_rate_at_epoch(arg0: &0x2::table::Table<u64, 0x3::staking_pool::PoolTokenExchangeRate>, arg1: u64) : 0x3::staking_pool::PoolTokenExchangeRate {
        abort 0
    }
    
    public fun pool_token_exchange_rate_at_epoch2(arg0: &0x2::table::Table<u64, 0x3::staking_pool::PoolTokenExchangeRate>, arg1: u64, arg2: u64) : 0x3::staking_pool::PoolTokenExchangeRate {
        abort 0
    }
    
    // decompiled from Move bytecode v6
}

