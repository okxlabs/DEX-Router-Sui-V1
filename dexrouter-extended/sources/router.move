module dexrouter_extended::router {
    use sui::coin::{Self, Coin};
    use sui::tx_context::{Self, TxContext};
    use sui::clock::Clock;
    use sui::sui::SUI;
    use sui::transfer;
    use sui::balance;

    // magma
    use magma::tick_math;
    use magma::pool::Pool as MagmaPool;
    use magma::config::GlobalConfig as MagmaGlobalConfig;
    use magma::pool;

    // haedal
    use haedal::staking::{request_stake_coin, request_unstake_instant_coin, Staking};
    use haedal::hasui::HASUI;

    //momentum
    use mmt_v3::pool::Pool;
    use mmt_v3::trade;
    use mmt_v3::version::Version as Mntv3Version;
    use slippage_check::slippage_check;

    // scallop
    use scallop::mint;
    use scallop::redeem;
    use scallop::version::Version as ScallopVersion;
    use scallop::market::Market;
    use scallop_treasury::s_coin_converter::{
        SCoinTreasury,
        mint_s_coin,
        burn_s_coin
    };

    // metastable
    use meta_vault::vault as metavault;
    use meta_vault::vault::{Vault, DepositCap, WithdrawCap};
    use meta_vault::version::Version;

    // steamm
    use steamm::pool::Pool as SteammPool;
    use steamm::cpmm::CpQuoter;
    use steamm::cpmm::swap as steamm_cpmm_swap;
    use steamm::omm_v2::swap as steamm_ommv2_swap;
    use steamm::omm_v2::OracleQuoterV2;
    use steamm::bank::{Bank, burn_btoken, mint_btoken};
    use suilend::lending_market::LendingMarket;
    use oracles::oracles::OraclePriceUpdate;

    const MAX_COMMISSION_RATE: u64 = 300;
    const MAX_PERCENTAGE: u64 = 10000;
    const PERCENTAGE_DIVISOR: u64 = 10000;

    const E_ROUTER_MIN_RETURN_NOT_REACH: u64 = 1;
    const E_PERCENTAGE: u64 = 2;
    const E_COMMISSION_PERCENTAGE: u64 = 3;

    const E_INVALID_PARAMETER: u64 = 5;
    // const E_MIN_AMOUNT_ZERO: u64 = 6;

    const E_SLIPPAGE_EXCEEDED: u64 = 7;
    const E_INPUT_AMOUNT: u64 = 8;

    // event
    // order_id: an order_id for oklink
    // decimal: toToken decimal for oklink
    use sui::event;

    // out_amount: amountOut for record
    struct OrderRecord has copy, drop {
        order_id: u64,
        decimal: u8,
        out_amount: u64
    }

    struct CommissionRecord has copy, drop {
        commission_amount: u64,
        referral_address: address
    }

    struct HopRecord has copy, drop {
        out_amount: u64
    }

    public fun haedal_swap_a2b_with_return(
        sui_system_state: &mut 0x3::sui_system::SuiSystemState,
        staking: &mut Staking,
        coin_in: Coin<SUI>,
        validater_address: address,
        ctx: &mut TxContext,
    ): (Coin<HASUI>, u64) {
        let haedal = request_stake_coin(
            sui_system_state,
            staking,
            coin_in,
            validater_address,
            ctx
        );

        let haedal_value = coin::value(&haedal);

        event::emit(HopRecord{
            out_amount: haedal_value
        });

        (haedal, haedal_value)
    }

    public fun haedal_swap_b2a_with_return(
        sui_system_state: &mut 0x3::sui_system::SuiSystemState,
        staking: &mut Staking,
        coin_in: Coin<HASUI>,
        ctx: &mut TxContext,
    ): (Coin<SUI>, u64) {
        let sui = request_unstake_instant_coin(
            sui_system_state,
            staking,
            coin_in,
            ctx
        );

        let sui_value = coin::value(&sui);

        event::emit(HopRecord{
            out_amount: sui_value
        });

        (sui, sui_value)
    }

    public fun scallop_swap_exact_swap_a2b_with_return<CoinType0, CoinType1>(
        version: &ScallopVersion,
        market: &mut Market,
        treasury: &mut SCoinTreasury<CoinType1, CoinType0>,
        coins_0: Coin<CoinType0>,
        clock: &Clock,
        ctx: &mut TxContext
    ): (Coin<CoinType1>, u64) {
        let minted = mint::mint<CoinType0>(version, market, coins_0, clock, ctx);
        let output = mint_s_coin<CoinType1, CoinType0>(treasury, minted, ctx);
        let coin_value = coin::value(&output);

        event::emit(HopRecord{
            out_amount: coin_value
        });

        (output, coin_value)
    }

    public fun scallop_swap_exact_swap_b2a_with_return<CoinType1, CoinType0>(
        version: &ScallopVersion,
        market: &mut Market,
        treasury: &mut SCoinTreasury<CoinType1, CoinType0>,
        coins_1: Coin<CoinType1>,
        clock: &Clock,
        ctx: &mut TxContext
    ): (Coin<CoinType0>, u64) {
        let burned = burn_s_coin<CoinType1, CoinType0>(treasury, coins_1, ctx);
        let output = redeem::redeem<CoinType0>(version, market, burned, clock, ctx);
        let coin_value = coin::value(&output);

        event::emit(HopRecord{
            out_amount: coin_value
        });

        (output, coin_value)
    }

    public fun alphafi_swap_a2b_with_return<P: drop>(
        self: &mut alphafin_liquid_staking::liquid_staking::LiquidStakingInfo<P>, 
        system_state: &mut 0x3::sui_system::SuiSystemState, 
        sui: Coin<SUI>, 
        ctx: &mut TxContext
    ): (Coin<P>, u64) {
        let output = alphafin_liquid_staking::liquid_staking::mint<P>(self, system_state, sui, ctx);
        let coin_value = coin::value(&output);

        event::emit(HopRecord{
            out_amount: coin_value
        });

        (output, coin_value)
    }

    public fun alphafi_swap_b2a_with_return<P: drop>(
        self: &mut alphafin_liquid_staking::liquid_staking::LiquidStakingInfo<P>,
        lst: Coin<P>,
        system_state: &mut 0x3::sui_system::SuiSystemState,
        ctx: &mut TxContext
    ): (Coin<SUI>, u64) {
        let output = alphafin_liquid_staking::liquid_staking::redeem<P>(self, lst, system_state, ctx);
        let coin_value = coin::value(&output);

        event::emit(HopRecord{
            out_amount: coin_value
        });

        (output, coin_value)
    }

    public fun momentum_swap_a2b_with_return<CoinType0, CoinType1>(
        pool: &mut Pool<CoinType0, CoinType1>,
        coin_a: Coin<CoinType0>,
        amount_specified: u64,
        sqrt_price_limit: u128,
        clock: &Clock,
        version: &Mntv3Version,
        ctx: &mut TxContext,
    ): (Coin<CoinType1>, u64) {
        let (receive_a, receive_b, receipt) = trade::flash_swap<CoinType0, CoinType1>(
            pool,
            true,
            true,
            amount_specified,
            sqrt_price_limit,
            clock,
            version,
            ctx,
        );

        let (_debt_a, _) = trade::swap_receipt_debts(&receipt);
        let pay_coin_a = coin::split(&mut coin_a, _debt_a, ctx);
        let pay_coin_a_balance = coin::into_balance(pay_coin_a);
        balance::destroy_zero(receive_a);

        let coin_b = coin::from_balance(receive_b, ctx);
        let coin_value = coin::value(&coin_b);

        trade::repay_flash_swap<CoinType0, CoinType1>(
            pool,
            receipt,
            pay_coin_a_balance,
            balance::zero<CoinType1>(),
            version,
            ctx,
        );

        slippage_check::assert_slippage<CoinType0, CoinType1>(
            pool,
            sqrt_price_limit,
            true,
        );

        destroy_or_transfer<CoinType0>(coin_a, ctx);

        event::emit(HopRecord{
            out_amount: coin_value
        });

        (coin_b, coin_value)
    }

    public fun momentum_swap_b2a_with_return<CoinType0, CoinType1>(
        pool: &mut Pool<CoinType0, CoinType1>,
        coin_b: Coin<CoinType1>,
        amount_specified: u64,
        sqrt_price_limit: u128,
        clock: &Clock,
        version: &Mntv3Version,
        ctx: &mut TxContext,
    ): (Coin<CoinType0>, u64) {
        let (receive_a, receive_b, receipt) = trade::flash_swap<CoinType0, CoinType1>(
            pool,
            false,
            true,
            amount_specified,
            sqrt_price_limit,
            clock,
            version,
            ctx,
        );

        let (_, _debt_b) = trade::swap_receipt_debts(&receipt);
        let pay_coin_b = coin::split(&mut coin_b, _debt_b, ctx);
        let pay_coin_b_balance = coin::into_balance(pay_coin_b);
        balance::destroy_zero(receive_b);

        let coin_a = coin::from_balance(receive_a, ctx);
        let coin_value = coin::value(&coin_a);

        trade::repay_flash_swap<CoinType0, CoinType1>(
            pool,
            receipt,
            balance::zero<CoinType0>(),
            pay_coin_b_balance,
            version,
            ctx,
        );

        slippage_check::assert_slippage<CoinType0, CoinType1>(
            pool,
            sqrt_price_limit,
            false,
        );

        destroy_or_transfer<CoinType1>(coin_b, ctx);

        event::emit(HopRecord{
            out_amount: coin_value
        });

        (coin_a, coin_value)
    }

    public fun bluefin_spot_swap_a2b_with_return<CoinTypeA, CoinTypeB>(
        clock: &Clock,
        protocol_config: &bluefin_spot::config::GlobalConfig,
        pool: &mut bluefin_spot::pool::Pool<CoinTypeA, CoinTypeB>,
        coins_a: Coin<CoinTypeA>,
        by_amount_in: bool,
        amount: u64,
        amount_limit: u64,
        sqrt_price_max_limit: u128,
        _order_id: u64,
        _decimal: u8,
        ctx: &mut TxContext
    ): (Coin<CoinTypeB>, u64) {
        let (a_left_balance, b_out_balance) = bluefin_spot::pool::swap(
            clock,
            protocol_config,
            pool,
            coin::into_balance<CoinTypeA>(coins_a),
            0x2::balance::zero<CoinTypeB>(),
            true,
            by_amount_in,
            amount,
            amount_limit,
            sqrt_price_max_limit,
        );
        let coin_a_left = coin::from_balance<CoinTypeA>(a_left_balance, ctx);
        let coin_b_out = coin::from_balance<CoinTypeB>(b_out_balance, ctx);

        destroy_or_transfer(coin_a_left, ctx);
        let coin_b_value = coin::value(&coin_b_out);

        event::emit(HopRecord{
            out_amount: coin_b_value
        });

        (coin_b_out, coin_b_value)
    }

    public fun bluefin_spot_swap_b2a_with_return<CoinTypeA, CoinTypeB>(
        clock: &Clock,
        protocol_config: &bluefin_spot::config::GlobalConfig,
        pool: &mut bluefin_spot::pool::Pool<CoinTypeA, CoinTypeB>,
        coins_b: Coin<CoinTypeB>,
        by_amount_in: bool,
        amount: u64,
        amount_limit: u64,
        sqrt_price_max_limit: u128,
        _order_id: u64,
        _decimal: u8,
        ctx: &mut TxContext
    ): (Coin<CoinTypeA>, u64) {
        let (a_out_balance, b_left_balance) = bluefin_spot::pool::swap(
            clock,
            protocol_config,
            pool,
            0x2::balance::zero<CoinTypeA>(),
            coin::into_balance<CoinTypeB>(coins_b),
            false,
            by_amount_in,
            amount,
            amount_limit,
            sqrt_price_max_limit,
        );
        let coin_a_out = coin::from_balance<CoinTypeA>(a_out_balance, ctx);
        let coin_b_left = coin::from_balance<CoinTypeB>(b_left_balance, ctx);

        destroy_or_transfer(coin_b_left, ctx);
        let coin_a_value = coin::value(&coin_a_out);

        event::emit(HopRecord{
            out_amount: coin_a_value
        });

        (coin_a_out, coin_a_value)
    }

    public fun metastable_swap_a2b_with_return<CoinTypeA, CoinTypeB>(
        metastable_vault: &mut Vault<CoinTypeA>,
        version: &Version,
        deposit_cap: DepositCap<CoinTypeA, CoinTypeB>,
        coin_in: Coin<CoinTypeB>,
        min_amount_out: u64,
        ctx: &mut TxContext,
    ): (Coin<CoinTypeA>, u64) {
        let coin_b_out = metavault::deposit<CoinTypeA, CoinTypeB>(
            metastable_vault,
            version,
            deposit_cap,
            coin_in,
            min_amount_out,
            ctx
        );

        let coin_b_value = coin::value(&coin_b_out);

        event::emit(HopRecord{
            out_amount: coin_b_value
        });

        (coin_b_out, coin_b_value)
    }

    public fun metastable_swap_b2a_with_return<CoinTypeA, CoinTypeB>(
        metastable_vault: &mut Vault<CoinTypeA>,
        version: &Version,
        withdraw_cap: WithdrawCap<CoinTypeA, CoinTypeB>,
        coin_in: Coin<CoinTypeA>,
        min_amount_out: u64,
        ctx: &mut TxContext,
    ): (Coin<CoinTypeB>, u64) {
        let coin_a_out = metavault::withdraw<CoinTypeA, CoinTypeB>(
            metastable_vault,
            version,
            withdraw_cap,
            coin_in,
            min_amount_out,
            ctx
        );

        let coin_a_value = coin::value(&coin_a_out);

        event::emit(HopRecord{ 
            out_amount: coin_a_value
        });

        (coin_a_out, coin_a_value)
    }

    public fun magma_swap_token_x_with_return<T0, T1>(
        config: &MagmaGlobalConfig,
        pool: &mut MagmaPool<T0, T1>,
        coin_x: Coin<T0>,
        amount_in: u64,
        min_out: u64,
        clock: &Clock,
        ctx: &mut TxContext
    ): (sui::coin::Coin<T1>, u64) {

        assert!(coin::value<T0>(&coin_x) == amount_in, E_INPUT_AMOUNT);

        let (receive_x, receive_y, flash_receipt) = pool::flash_swap<T0, T1>(
            config,
            pool,
            true, // is_a_to_b
            true, // by_amount_in
            amount_in,
            tick_math::min_sqrt_price(),
            clock
        );

        let amount_out = balance::value(&receive_y);
        assert!(amount_out >= min_out, E_SLIPPAGE_EXCEEDED);

        // handle repay
        balance::destroy_zero(receive_x);
        let balance_x = coin::into_balance(coin_x);
        let balance_y = balance::zero<T1>();

        pool::repay_flash_swap<T0, T1>(
            config,
            pool,
            balance_x,
            balance_y,
            flash_receipt
        );

        event::emit(HopRecord { out_amount: amount_out });

        (coin::from_balance(receive_y, ctx), amount_out)
    }

    public fun magma_swap_token_y_with_return<T0, T1>(
        config: &MagmaGlobalConfig,
        pool: &mut MagmaPool<T0, T1>,
        coin_y: Coin<T1>,
        amount_in: u64,
        min_out: u64,
        clock: &Clock,
        ctx: &mut TxContext
    ): (sui::coin::Coin<T0>, u64) {

        assert!(coin::value<T1>(&coin_y) == amount_in, E_INPUT_AMOUNT);

        let (receive_x, receive_y, flash_receipt) = pool::flash_swap<T0, T1>(
            config,
            pool,
            false, // is_a_to_b
            true, // by_amount_in
            amount_in,
            tick_math::max_sqrt_price(),
            clock
        );

        let amount_out = balance::value(&receive_x);
        assert!(amount_out >= min_out, E_SLIPPAGE_EXCEEDED);

        // handle repay
        balance::destroy_zero(receive_y);
        let balance_x = balance::zero<T0>();
        let balance_y = coin::into_balance(coin_y);

        pool::repay_flash_swap<T0, T1>(
            config,
            pool,
            balance_x,
            balance_y,
            flash_receipt
        );

        event::emit(HopRecord { out_amount: amount_out });

        (coin::from_balance(receive_x, ctx), amount_out)
    }

    fun to_btokens<P, A, B, BTokenA, BTokenB>(
        bank_a: &mut Bank<P, A, BTokenA>,
        bank_b: &mut Bank<P, B, BTokenB>,
        lending_market: &LendingMarket<P>,
        coin_a: &mut Coin<A>,
        coin_b: &mut Coin<B>,
        a2b: bool,
        amount_in: u64,
        clock: &Clock,
        ctx: &mut TxContext,
    ): (Coin<BTokenA>, Coin<BTokenB>, u64) {
        let (btoken_a, btoken_b) = if (a2b) {
            (
                mint_btoken(bank_a, lending_market, coin_a, amount_in, clock, ctx),
                coin::zero(ctx),
            )
        } else {
            (
                coin::zero(ctx),
                mint_btoken(bank_b, lending_market, coin_b, amount_in, clock, ctx)
            )
        };

        let btoken_amount_in = if (a2b) { coin::value(&btoken_a) } else { coin::value(&btoken_b) };

        (btoken_a, btoken_b, btoken_amount_in)
    }

    public fun steamm_cpmm_swap_a2b_with_return<P, A, B, BTokenA, BTokenB, LpType: drop>(
        pool: &mut SteammPool<BTokenA, BTokenB, CpQuoter, LpType>,
        bank_a: &mut Bank<P, A, BTokenA>,
        bank_b: &mut Bank<P, B, BTokenB>,
        lending_market: &LendingMarket<P>,
        coin_a: Coin<A>,
        amount_in: u64,
        min_amount_out: u64,
        clock: &Clock,
        ctx: &mut TxContext,
    ): (Coin<B>, u64) {
        let coin_b = coin::zero<B>(ctx);
        let (btoken_a, btoken_b, btoken_amount_in) = to_btokens(
            bank_a,
            bank_b,
            lending_market,
            &mut coin_a,
            &mut coin_b,
            true,   // a2b: bool, must true, A->B
            amount_in,
            clock,
            ctx,
        );

        // let swap_result = steamm_cpmm_swap(
        steamm_cpmm_swap(
            pool,
            &mut btoken_a,
            &mut btoken_b,
            true,
            btoken_amount_in,
            min_amount_out,
            ctx,
        );

        let btoken_b_value = coin::value(&btoken_b);
        let coin_b_out = burn_btoken(
            bank_b,
            lending_market,
            &mut btoken_b,
            btoken_b_value,
            clock,
            ctx,
        );
        coin::join(&mut coin_b, coin_b_out);

        destroy_or_transfer(coin_a, ctx);
        destroy_or_transfer(btoken_a, ctx);
        destroy_or_transfer(btoken_b, ctx);
        let coin_b_value = coin::value(&coin_b);

        event::emit(HopRecord{ 
            out_amount: coin_b_value
        });
        (coin_b, coin_b_value)
    }

    public fun steamm_cpmm_swap_b2a_with_return<P, A, B, BTokenA, BTokenB, LpType: drop>(
        pool: &mut SteammPool<BTokenA, BTokenB, CpQuoter, LpType>,
        bank_a: &mut Bank<P, A, BTokenA>,
        bank_b: &mut Bank<P, B, BTokenB>,
        lending_market: &LendingMarket<P>,
        coin_b: Coin<B>,
        amount_in: u64,
        min_amount_out: u64,
        clock: &Clock,
        ctx: &mut TxContext,
    ): (Coin<A>, u64) {
        let coin_a = coin::zero<A>(ctx);
        let (btoken_a, btoken_b, btoken_amount_in) = to_btokens(
            bank_a,
            bank_b,
            lending_market,
            &mut coin_a,
            &mut coin_b,
            false,   // a2b: bool, must false, B->A
            amount_in,
            clock,
            ctx,
        );

        steamm_cpmm_swap(
            pool,
            &mut btoken_a,
            &mut btoken_b,
            false,
            btoken_amount_in,
            min_amount_out,
            ctx,
        );

        let btoken_a_value = coin::value(&btoken_a);
        let coin_a_out = burn_btoken(
            bank_a,
            lending_market,
            &mut btoken_a,
            btoken_a_value,
            clock,
            ctx,
        );
        coin::join(&mut coin_a, coin_a_out);

        destroy_or_transfer(coin_b, ctx);
        destroy_or_transfer(btoken_a, ctx);
        destroy_or_transfer(btoken_b, ctx);
        let coin_a_value = coin::value(&coin_a);

        event::emit(HopRecord{ 
            out_amount: coin_a_value
        });
        (coin_a, coin_a_value)
    }

    public fun steamm_ommv2_swap_a2b_with_return<P, A, B, BTokenA, BTokenB, LpType: drop>(
        pool: &mut SteammPool<BTokenA, BTokenB, OracleQuoterV2, LpType>,
        bank_a: &mut Bank<P, A, BTokenA>,
        bank_b: &mut Bank<P, B, BTokenB>,
        lending_market: &LendingMarket<P>,
        oracle_price_update_a: OraclePriceUpdate,
        oracle_price_update_b: OraclePriceUpdate,
        coin_a: Coin<A>,
        amount_in: u64,
        min_amount_out: u64,
        clock: &Clock,
        ctx: &mut TxContext,
    ): (Coin<B>, u64) {
        let coin_b = coin::zero<B>(ctx);
        let (btoken_a, btoken_b, btoken_amount_in) = to_btokens(
            bank_a,
            bank_b,
            lending_market,
            &mut coin_a,
            &mut coin_b,
            true,   // a2b: bool, must true, A->B
            amount_in,
            clock,
            ctx,
        );

        steamm_ommv2_swap(
            pool,
            bank_a,
            bank_b,
            lending_market,
            oracle_price_update_a,
            oracle_price_update_b,
            &mut btoken_a,
            &mut btoken_b,
            true,
            btoken_amount_in,
            min_amount_out,
            clock,
            ctx,
        );

        let btoken_b_value = coin::value(&btoken_b);
        let coin_b_out = burn_btoken(
            bank_b,
            lending_market,
            &mut btoken_b,
            btoken_b_value,
            clock,
            ctx,
        );
        coin::join(&mut coin_b, coin_b_out);

        destroy_or_transfer(coin_a, ctx);
        destroy_or_transfer(btoken_a, ctx);
        destroy_or_transfer(btoken_b, ctx);
        let coin_b_value = coin::value(&coin_b);

        event::emit(HopRecord{ 
            out_amount: coin_b_value
        });
        (coin_b, coin_b_value)
    }

    public fun steamm_ommv2_swap_b2a_with_return<P, A, B, BTokenA, BTokenB, LpType: drop>(
        pool: &mut SteammPool<BTokenA, BTokenB, OracleQuoterV2, LpType>,
        bank_a: &mut Bank<P, A, BTokenA>,
        bank_b: &mut Bank<P, B, BTokenB>,
        lending_market: &LendingMarket<P>,
        oracle_price_update_a: OraclePriceUpdate,
        oracle_price_update_b: OraclePriceUpdate,
        coin_b: Coin<B>,
        amount_in: u64,
        min_amount_out: u64,
        clock: &Clock,
        ctx: &mut TxContext,
    ): (Coin<A>, u64) {
        let coin_a = coin::zero<A>(ctx);
        let (btoken_a, btoken_b, btoken_amount_in) = to_btokens(
            bank_a,
            bank_b,
            lending_market,
            &mut coin_a,
            &mut coin_b,
            false,   // a2b: bool, must false, B->A
            amount_in,
            clock,
            ctx,
        );

        steamm_ommv2_swap(
            pool,
            bank_a,
            bank_b,
            lending_market,
            oracle_price_update_a,
            oracle_price_update_b,
            &mut btoken_a,
            &mut btoken_b,
            false,
            btoken_amount_in,
            min_amount_out,
            clock,
            ctx,
        );

        let btoken_a_value = coin::value(&btoken_a);
        let coin_a_out = burn_btoken(
            bank_a,
            lending_market,
            &mut btoken_a,
            btoken_a_value,
            clock,
            ctx,
        );
        coin::join(&mut coin_a, coin_a_out);

        destroy_or_transfer(coin_b, ctx);
        destroy_or_transfer(btoken_a, ctx);
        destroy_or_transfer(btoken_b, ctx);
        let coin_a_value = coin::value(&coin_a);

        event::emit(HopRecord{ 
            out_amount: coin_a_value
        });
        (coin_a, coin_a_value)
    }

    public fun finalize<CoinType>(
        coin: Coin<CoinType>,
        min_amount: u64,
        toCommissionRate: u64,
        referralAddress: address,
        swapReceiverAddress: address,
        order_id: u64,
        decimal: u8,
        ctx: &mut TxContext,
    ) { 
        assert!(toCommissionRate == 0 || (toCommissionRate > 0 && referralAddress != @0x0), E_INVALID_PARAMETER);
        let amount_out = coin::value(&coin);
        let receiver = if (swapReceiverAddress != @0x0) swapReceiverAddress else tx_context::sender(ctx);
        if (amount_out < min_amount) {
            abort E_ROUTER_MIN_RETURN_NOT_REACH
        };

        if(toCommissionRate > 0){
            let (coin_left, _coin_left_value) = split_with_percentage_for_commission(&mut coin, toCommissionRate, referralAddress, ctx);
            transfer::public_transfer(coin_left, receiver);
            destroy_or_transfer<CoinType>(coin, ctx);
        } else {
            transfer::public_transfer(coin, receiver);
        };

        event::emit(OrderRecord{ 
            order_id: order_id,
            decimal: decimal,
            out_amount: amount_out
        });
    }

    #[allow(lint(self_transfer))]
    fun destroy_or_transfer<CoinType>(coin: Coin<CoinType>, ctx: & TxContext) {
        if (coin::value(&coin) == 0) {
            coin::destroy_zero(coin);
        } else {
            transfer::public_transfer(coin, tx_context::sender(ctx));
        };
    }

    public fun split_with_percentage<T>(
        coin: &mut Coin<T>,
        percentage: u64,
        ctx: &mut TxContext
    ): (Coin<T>, u64, Coin<T>, u64) {
        assert!(percentage <= MAX_PERCENTAGE, E_PERCENTAGE);
        let total_value = coin::value(coin);
        let split_amount = ((((total_value as u128) * (percentage as u128)) / (PERCENTAGE_DIVISOR as u128)) as u64);
        let split_coin = coin::split(coin, split_amount, ctx);
        (split_coin, split_amount, coin::split(coin, total_value - split_amount, ctx), total_value - split_amount)
    }

    public fun split_with_percentage_for_commission<T>(
        coin: &mut Coin<T>,
        commissionRate: u64,
        referralAddress: address,
        ctx: &mut TxContext
    ): (Coin<T>, u64) {
        assert!(commissionRate <= MAX_COMMISSION_RATE, E_COMMISSION_PERCENTAGE);
        assert!(commissionRate == 0 || (commissionRate > 0 && referralAddress != @0x0), E_INVALID_PARAMETER);
        let (coin_split, coin_split_value, coin_left, coin_left_value) = split_with_percentage(coin, commissionRate, ctx);
        if(coin_split_value == 0){
            coin::destroy_zero(coin_split);
        } else {
            transfer::public_transfer(coin_split, referralAddress);
            event::emit(CommissionRecord{ 
                commission_amount: coin_split_value,
                referral_address: referralAddress
            });
        };
        (coin_left, coin_left_value)
    }
}