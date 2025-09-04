module 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::manage {
    struct AdminCap has store, key {
        id: 0x2::object::UID,
        init: bool,
    }
    
    struct OperatorCap has store, key {
        id: 0x2::object::UID,
    }
    
    public entry fun set_deposit_fee(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg2: u64) {
        abort 0
    }
    
    public entry fun set_reward_fee(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg2: u64) {
        abort 0
    }
    
    public entry fun set_service_fee(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg2: u64) {
        abort 0
    }
    
    public entry fun set_validator_count(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg2: u64) {
        abort 0
    }
    
    public entry fun set_validator_reward_fee(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg2: u64) {
        abort 0
    }
    
    public entry fun set_withdraw_time_limit(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg2: u64) {
        abort 0
    }
    
    public entry fun collect_rewards_fee_v2(arg0: &AdminCap, arg1: &mut 0x3::sui_system::SuiSystemState, arg2: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg3: address, arg4: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public entry fun collect_service_fee(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg2: address, arg3: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public entry fun do_stake(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg2: &mut 0x3::sui_system::SuiSystemState, arg3: vector<address>, arg4: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public entry fun initialize(arg0: &mut AdminCap, arg1: 0x2::coin::TreasuryCap<0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::hasui::HASUI>, arg2: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public entry fun migrate(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking) {
        abort 0
    }
    
    public entry fun sort_validators(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg2: vector<address>) {
        abort 0
    }
    
    public entry fun toggle_claim(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg2: bool) {
        abort 0
    }
    
    public entry fun toggle_stake(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg2: bool) {
        abort 0
    }
    
    public entry fun toggle_unstake(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg2: bool) {
        abort 0
    }
    
    public entry fun unstake_from_validator(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg2: &mut 0x3::sui_system::SuiSystemState, arg3: address, arg4: u64, arg5: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public entry fun unstake_inactive_validators(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg2: &mut 0x3::sui_system::SuiSystemState, arg3: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public entry fun update_total_rewards_onchain(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg2: &mut 0x3::sui_system::SuiSystemState, arg3: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public entry fun update_validator_rewards(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg2: &mut 0x3::sui_system::SuiSystemState, arg3: address, arg4: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public entry fun collect_rewards_fee(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg2: address, arg3: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public entry fun do_unstake_onchain(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg2: &mut 0x3::sui_system::SuiSystemState, arg3: vector<address>, arg4: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    fun init(arg0: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public entry fun unstake_pools(arg0: &AdminCap, arg1: &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking::Staking, arg2: &mut 0x3::sui_system::SuiSystemState, arg3: vector<address>, arg4: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    // decompiled from Move bytecode v6
}

