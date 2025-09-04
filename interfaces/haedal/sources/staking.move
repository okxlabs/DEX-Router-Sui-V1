module 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::staking {
    struct Staking has key {
        id: 0x2::object::UID,
        version: u64,
        config: 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::config::StakingConfig,
        sui_vault: 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::vault::Vault<0x2::sui::SUI>,
        claim_sui_vault: 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::vault::Vault<0x2::sui::SUI>,
        protocol_sui_vault: 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::vault::Vault<0x2::sui::SUI>,
        service_sui_vault: 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::vault::Vault<0x2::sui::SUI>,
        stsui_treasury_cap: 0x2::coin::TreasuryCap<0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::hasui::HASUI>,
        unstake_epochs: vector<EpochClaim>,
        total_staked: u64,
        total_unstaked: u64,
        total_rewards: u64,
        total_protocol_fees: u64,
        uncollected_protocol_fees: u64,
        stsui_supply: u64,
        unclaimed_sui_amount: u64,
        pause_stake: bool,
        pause_unstake: bool,
        validators: vector<address>,
        pools: 0x2::table::Table<address, PoolInfo>,
        user_selected_validator_bals: 0x2::vec_map::VecMap<address, 0x2::balance::Balance<0x2::sui::SUI>>,
        rewards_last_updated_epoch: u64,
    }
    
    struct PoolInfo has store {
        staked_suis: 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::table_queue::TableQueue<0x3::staking_pool::StakedSui>,
        total_staked: u64,
        rewards: u64,
    }
    
    struct EpochClaim has store {
        epoch: u64,
        amount: u64,
        approved: bool,
    }
    
    struct UnstakeTicket has key {
        id: 0x2::object::UID,
        unstake_timestamp_ms: u64,
        st_amount: u64,
        sui_amount: u64,
        claim_epoch: u64,
        claim_timestamp_ms: u64,
    }
    
    struct UserStaked has copy, drop {
        owner: address,
        sui_amount: u64,
        st_amount: u64,
        validator: address,
    }
    
    struct UserInstantUnstaked has copy, drop {
        owner: address,
        sui_amount: u64,
        st_amount: u64,
    }
    
    struct UserNormalUnstaked has copy, drop {
        owner: address,
        epoch: u64,
        epoch_timestamp_ms: u64,
        unstake_timestamp_ms: u64,
        sui_amount: u64,
        st_amount: u64,
    }
    
    struct UserClaimed has copy, drop {
        id: 0x2::object::ID,
        owner: address,
        sui_amount: u64,
    }
    
    struct SystemStaked has copy, drop {
        staked_sui_id: 0x2::object::ID,
        epoch: u64,
        sui_amount: u64,
        validator: address,
    }
    
    struct SystemUnstaked has copy, drop {
        epoch: u64,
        sui_amount: u64,
        approved_amount: u64,
    }
    
    struct PoolSystemUnstaked has copy, drop {
        validator: address,
        epoch: u64,
        sui_amount: u64,
        unstaked_all: bool,
    }
    
    struct SuiRewardsUpdated has copy, drop {
        old: u64,
        new: u64,
        fee: u64,
    }
    
    struct RewardsFeeCollected has copy, drop {
        owner: address,
        sui_amount: u64,
    }
    
    struct ServiceFeeCollected has copy, drop {
        owner: address,
        sui_amount: u64,
    }
    
    struct VersionUpdated has copy, drop {
        old: u64,
        new: u64,
    }
    
    struct ExchangeRateUpdated has copy, drop {
        old: u64,
        new: u64,
    }
    
    struct RewardsInjected has copy, drop {
        owner: address,
        sui_amount: u64,
    }
    
    struct ValidatorStakedInfo has store {
        validator: address,
        total_staked: u64,
        rewards: u64,
        staked_sui_count: u64,
    }
    
    struct ValidatorStakedInfoV2 has store {
        validator: address,
        total_staked: u64,
        rewards: u64,
        staked_sui_count: u64,
        pool_id: 0x2::object::ID,
        exchange_rates_unexisted_epoches: vector<u64>,
        stake_activation_epoches: vector<u64>,
    }
    
    struct UserSelectedStaking has drop {
        validator: address,
        amount: u64,
    }
    
    public fun assert_version(arg0: &Staking) {
        abort 0
    }
    
    fun calculate_staked_sui_rewards(arg0: &mut 0x3::sui_system::SuiSystemState, arg1: &0x3::staking_pool::StakedSui, arg2: u64) : u64 {
        abort 0
    }
    
    fun calculate_validator_pool_rewards_increase(arg0: &mut 0x3::sui_system::SuiSystemState, arg1: &mut PoolInfo, arg2: u64) : u64 {
        abort 0
    }
    
    public fun claim(arg0: &mut Staking, arg1: UnstakeTicket, arg2: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public fun claim_coin(arg0: &mut Staking, arg1: UnstakeTicket, arg2: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<0x2::sui::SUI> {
        abort 0
    }
    
    public fun claim_coin_v2(arg0: &mut 0x3::sui_system::SuiSystemState, arg1: &mut Staking, arg2: UnstakeTicket, arg3: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<0x2::sui::SUI> {
        abort 0
    }
    
    public fun claim_v2(arg0: &mut 0x3::sui_system::SuiSystemState, arg1: &mut Staking, arg2: UnstakeTicket, arg3: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public(friend) fun collect_rewards_fee(arg0: &mut Staking, arg1: address, arg2: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public(friend) fun collect_rewards_fee_v2(arg0: &mut 0x3::sui_system::SuiSystemState, arg1: &mut Staking, arg2: address, arg3: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public(friend) fun collect_service_fee(arg0: &mut Staking, arg1: address, arg2: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public fun destroy_ValidatorStakedInfoV2(arg0: ValidatorStakedInfoV2) {
        abort 0
    }
    
    public(friend) fun do_stake(arg0: &mut Staking, arg1: &mut 0x3::sui_system::SuiSystemState, arg2: vector<address>, arg3: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public(friend) fun do_unstake_onchain_by_validator(arg0: &mut Staking, arg1: &mut 0x3::sui_system::SuiSystemState, arg2: vector<address>, arg3: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    fun do_validator_unstake(arg0: &mut Staking, arg1: &mut 0x3::sui_system::SuiSystemState, arg2: &mut 0x2::balance::Balance<0x2::sui::SUI>, arg3: address, arg4: u64, arg5: u64, arg6: &mut 0x2::tx_context::TxContext) : u64 {
        abort 0
    }
    
    public fun get_all_current_validator_staked_info(arg0: &Staking, arg1: &mut 0x3::sui_system::SuiSystemState, arg2: &0x2::tx_context::TxContext) : vector<ValidatorStakedInfo> {
        abort 0
    }
    
    public fun get_cached_validator_number(arg0: &Staking) : u64 {
        abort 0
    }
    
    public fun get_config_mut(arg0: &mut Staking) : &mut 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::config::StakingConfig {
        abort 0
    }
    
    public fun get_current_validator_staked_info(arg0: &Staking, arg1: &mut 0x3::sui_system::SuiSystemState, arg2: address, arg3: &0x2::tx_context::TxContext) : ValidatorStakedInfo {
        abort 0
    }
    
    public fun get_current_validator_staked_info_detail_single(arg0: &Staking, arg1: &mut 0x3::sui_system::SuiSystemState, arg2: address, arg3: bool, arg4: &0x2::tx_context::TxContext) : ValidatorStakedInfoV2 {
        abort 0
    }
    
    public fun get_current_validator_staked_info_detail_vector(arg0: &Staking, arg1: &mut 0x3::sui_system::SuiSystemState, arg2: bool, arg3: &0x2::tx_context::TxContext) : vector<ValidatorStakedInfoV2> {
        abort 0
    }
    
    public fun get_exchange_rate(arg0: &Staking) : u64 {
        abort 0
    }
    
    public fun get_protocol_sui_vault_amount(arg0: &Staking) : u64 {
        abort 0
    }
    
    public fun get_service_sui_vault_amount(arg0: &Staking) : u64 {
        abort 0
    }
    
    fun get_split_amount(arg0: &mut 0x3::sui_system::SuiSystemState, arg1: &0x3::staking_pool::StakedSui, arg2: u64, arg3: u64) : (u64, u64) {
        abort 0
    }
    
    public fun get_staked_validator(arg0: &Staking, arg1: address) : bool {
        abort 0
    }
    
    public fun get_staked_validators(arg0: &Staking) : vector<address> {
        abort 0
    }
    
    public fun get_stsui_by_sui(arg0: &Staking, arg1: u64) : u64 {
        abort 0
    }
    
    public fun get_stsui_supply(arg0: &Staking) : u64 {
        abort 0
    }
    
    public fun get_sui_by_stsui(arg0: &Staking, arg1: u64) : u64 {
        abort 0
    }
    
    public fun get_sui_vault_amount(arg0: &Staking) : u64 {
        abort 0
    }
    
    public fun get_total_protocol_fees(arg0: &Staking) : u64 {
        abort 0
    }
    
    public fun get_total_rewards(arg0: &Staking) : u64 {
        abort 0
    }
    
    public fun get_total_staked(arg0: &Staking) : u64 {
        abort 0
    }
    
    public fun get_total_sui(arg0: &Staking) : u64 {
        abort 0
    }
    
    public fun get_total_sui_cap(arg0: &Staking) : u64 {
        abort 0
    }
    
    public fun get_total_unstaked(arg0: &Staking) : u64 {
        abort 0
    }
    
    public fun get_unclaimed_sui_amount(arg0: &Staking) : u64 {
        abort 0
    }
    
    public fun get_uncollected_protocol_fees(arg0: &Staking) : u64 {
        abort 0
    }
    
    public fun get_user_selected_staking(arg0: &mut Staking) : vector<UserSelectedStaking> {
        abort 0
    }
    
    fun get_user_selected_validators(arg0: &mut Staking, arg1: &vector<address>) : (vector<address>, vector<0x2::balance::Balance<0x2::sui::SUI>>, 0x2::balance::Balance<0x2::sui::SUI>) {
        abort 0
    }
    
    public fun get_validator_staked_info(arg0: &Staking) : vector<ValidatorStakedInfo> {
        abort 0
    }
    
    public fun get_version(arg0: &Staking) : u64 {
        abort 0
    }
    
    public fun import_stake_sui_vec(arg0: &mut 0x3::sui_system::SuiSystemState, arg1: &mut Staking, arg2: vector<0x3::staking_pool::StakedSui>, arg3: address, arg4: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::hasui::HASUI> {
        abort 0
    }
    
    public(friend) fun initialize(arg0: 0x2::coin::TreasuryCap<0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::hasui::HASUI>, arg1: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public fun inject_rewards(arg0: &mut 0x3::sui_system::SuiSystemState, arg1: &mut Staking, arg2: 0x2::coin::Coin<0x2::sui::SUI>, arg3: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    fun is_active_validator(arg0: address, arg1: &vector<address>) : bool {
        abort 0
    }
    
    public(friend) fun migrate(arg0: &mut Staking) {
        abort 0
    }
    
    public fun query_pause_claim(arg0: &Staking) : bool {
        abort 0
    }
    
    public fun request_stake_coin(arg0: &mut 0x3::sui_system::SuiSystemState, arg1: &mut Staking, arg2: 0x2::coin::Coin<0x2::sui::SUI>, arg3: address, arg4: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::hasui::HASUI> {
        // assert_version(arg1);
        // assert!(!arg1.pause_stake, 12);
        // let v0 = 0x2::coin::value<0x2::sui::SUI>(&arg2);
        // assert!(v0 >= 1000000000, 4);
        // let v1 = get_stsui_by_sui(arg1, v0);
        // assert!(v1 > 0, 5);
        // let v2 = 0x3::sui_system::active_validator_addresses(arg0);
        // if (arg3 == @0x0 || !is_active_validator(arg3, &v2)) {
        //     0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::vault::deposit<0x2::sui::SUI>(&mut arg1.sui_vault, 0x2::coin::into_balance<0x2::sui::SUI>(arg2));
        // } else {
        //     save_user_selected_staking(arg1, arg2, arg3);
        // };
        // arg1.total_staked = arg1.total_staked + v0;
        // arg1.stsui_supply = 0x2::coin::total_supply<0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::hasui::HASUI>(&arg1.stsui_treasury_cap);
        // let v3 = UserStaked{
        //     owner      : 0x2::tx_context::sender(arg4), 
        //     sui_amount : v0, 
        //     st_amount  : v1, 
        //     validator  : arg3,
        // };
        // 0x2::event::emit<UserStaked>(v3);
        // 0x2::coin::mint<0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::hasui::HASUI>(&mut arg1.stsui_treasury_cap, v1, arg4)
        abort 0
    }
    
    public fun request_unstake_delay(arg0: &mut Staking, arg1: &0x2::clock::Clock, arg2: 0x2::coin::Coin<0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::hasui::HASUI>, arg3: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public fun request_unstake_instant(arg0: &mut Staking, arg1: 0x2::coin::Coin<0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::hasui::HASUI>, arg2: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public fun request_unstake_instant_coin(arg0: &mut 0x3::sui_system::SuiSystemState, arg1: &mut Staking, arg2: 0x2::coin::Coin<0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::hasui::HASUI>, arg3: &mut 0x2::tx_context::TxContext) : 0x2::coin::Coin<0x2::sui::SUI> {
        // assert_version(arg1);
        // assert!(!arg1.pause_unstake, 13);
        // let v0 = 0x2::coin::value<0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::hasui::HASUI>(&arg2);
        // let v1 = get_sui_by_stsui(arg1, v0);
        // assert!(v0 > 0, 11);
        // assert!(v1 <= get_total_sui(arg1) && v1 >= 1000000000, 8);
        // let v2 = withdraw_sui(arg0, arg1, v1, arg3);
        // 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::vault::deposit<0x2::sui::SUI>(&mut arg1.service_sui_vault, 0x2::balance::split<0x2::sui::SUI>(&mut v2, ((v1 as u128) * (0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::config::get_service_fee(&arg1.config) as u128) / (10000000 as u128)) as u64));
        // 0x2::coin::burn<0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::hasui::HASUI>(&mut arg1.stsui_treasury_cap, arg2);
        // let v3 = UserInstantUnstaked{
        //     owner      : 0x2::tx_context::sender(arg3), 
        //     sui_amount : v1, 
        //     st_amount  : v0,
        // };
        // 0x2::event::emit<UserInstantUnstaked>(v3);
        // arg1.total_unstaked = arg1.total_unstaked + v1;
        // arg1.stsui_supply = 0x2::coin::total_supply<0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::hasui::HASUI>(&arg1.stsui_treasury_cap);
        // 0x2::coin::from_balance<0x2::sui::SUI>(v2, arg3)
        abort 0
    }
    
    public fun request_unstake_instant_v2(arg0: &mut 0x3::sui_system::SuiSystemState, arg1: &mut Staking, arg2: 0x2::coin::Coin<0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::hasui::HASUI>, arg3: &mut 0x2::tx_context::TxContext) {
        // 0x2::transfer::public_transfer<0x2::coin::Coin<0x2::sui::SUI>>(request_unstake_instant_coin(arg0, arg1, arg2, arg3), 0x2::tx_context::sender(arg3));
        abort 0
    }
    
    fun save_user_selected_staking(arg0: &mut Staking, arg1: 0x2::coin::Coin<0x2::sui::SUI>, arg2: address) {
        abort 0
    }
    
    public(friend) fun sort_validators(arg0: &mut Staking, arg1: vector<address>) {
        abort 0
    }
    
    fun stake_to_validator(arg0: 0x2::balance::Balance<0x2::sui::SUI>, arg1: &mut Staking, arg2: &mut 0x3::sui_system::SuiSystemState, arg3: address, arg4: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    fun stake_user_selected_validators(arg0: &mut Staking, arg1: &mut 0x3::sui_system::SuiSystemState, arg2: &vector<address>, arg3: &mut 0x2::tx_context::TxContext) : 0x2::balance::Balance<0x2::sui::SUI> {
        abort 0
    }
    
    public fun ticket_claim_epoch(arg0: &UnstakeTicket) : u64 {
        abort 0
    }
    
    public fun ticket_claim_timestamp_ms(arg0: &UnstakeTicket) : u64 {
        abort 0
    }
    
    public fun ticket_st_amount(arg0: &UnstakeTicket) : u64 {
        abort 0
    }
    
    public fun ticket_sui_amount(arg0: &UnstakeTicket) : u64 {
        abort 0
    }
    
    public fun ticket_unstake_timestamp_ms(arg0: &UnstakeTicket) : u64 {
        abort 0
    }
    
    public(friend) fun toggle_claim(arg0: &mut Staking, arg1: bool) {
        abort 0
    }
    
    public(friend) fun toggle_stake(arg0: &mut Staking, arg1: bool) {
        abort 0
    }
    
    public(friend) fun toggle_unstake(arg0: &mut Staking, arg1: bool) {
        abort 0
    }
    
    public(friend) fun unstake_from_validator(arg0: &mut Staking, arg1: &mut 0x3::sui_system::SuiSystemState, arg2: address, arg3: u64, arg4: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public(friend) fun unstake_inactive_validators(arg0: &mut Staking, arg1: &mut 0x3::sui_system::SuiSystemState, arg2: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public(friend) fun unstake_validator_pools(arg0: &mut Staking, arg1: &mut 0x3::sui_system::SuiSystemState, arg2: vector<address>, arg3: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public(friend) fun update_total_rewards_onchain(arg0: &mut Staking, arg1: &mut 0x3::sui_system::SuiSystemState, arg2: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    public(friend) fun update_validator_rewards(arg0: &mut Staking, arg1: &mut 0x3::sui_system::SuiSystemState, arg2: address, arg3: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    fun withdraw_staked_sui(arg0: &mut 0x3::sui_system::SuiSystemState, arg1: 0x3::staking_pool::StakedSui, arg2: &mut 0x2::balance::Balance<0x2::sui::SUI>, arg3: &mut 0x2::tx_context::TxContext) : (u64, u64) {
        abort 0
    }
    
    fun withdraw_sui(arg0: &mut 0x3::sui_system::SuiSystemState, arg1: &mut Staking, arg2: u64, arg3: &mut 0x2::tx_context::TxContext) : 0x2::balance::Balance<0x2::sui::SUI> {
        abort 0
    }
    
    // decompiled from Move bytecode v6
}

