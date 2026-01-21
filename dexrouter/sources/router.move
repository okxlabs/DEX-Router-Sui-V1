module dexrouter::router {
    use sui::sui::SUI;
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::tx_context::{Self, TxContext};
    use sui::clock::Clock;
    use sui::balance::{Self};
    use std::vector;
    use sui::pay;


    // cetus
    use cetusclmm::config::{GlobalConfig};
    use cetusclmm::pool::{Self as cetus_pool};

    // turbos
    use sui::transfer;
    use turbos_clmm::pool::{Self as turbos_pool, Versioned, check_version};
    use turbos_clmm::swap_router::{swap_a_b_with_return_, swap_b_a_with_return_};

    // suiswap
    use suiswap::pool::{Self as suiswap_pool};

    // bluemove
    use bluemove::router::{Self as router};
    use bluemove::stable_router::{Self as stable_router};
    use bluemove::swap::{Dex_Info};
    use bluemove::stable_swap::{Dex_Stable_Info};

    // movepump
    use movepump::move_pump::{buy_returns, sell_returns, Configuration};

    // aftermath
    use amm::swap::{swap_exact_in};

    // kriya
    use kriya_amm::spot_dex::{Self as kriya_amm};
    use kriya_clmm::trade::{Self as kriya_clmm};
    use kriya_clmm::pool::{Self as kriya_clmmpool};
    use kriya_clmm::tick_math;
    use kriya_clmm::version::Version;

    // deepbook
    use deepbook::pool::swap_exact_base_for_quote;
    use deepbook::pool::swap_exact_quote_for_base;
    use deeptoken::deep::DEEP;

    // flowx clmm
    use flowx_clmm::versioned::{Self as flowx_versiond};
    use flowx_clmm::pool::{Self as flowx_pool};
    use flowx_clmm::pool_manager::{Self as pool_manager};

    // afsui
    use lsd::staked_sui_vault::{request_stake, request_unstake_atomic, StakedSuiVault};
    use safe::safe::Safe;
    use afsui_referral_vault::referral_vault::ReferralVault;
    use afsui::afsui::AFSUI;
    use afsui_treasury::treasury::Treasury;

    const MAX_COMMISSION_RATE: u64 = 300;
    const MAX_PERCENTAGE: u64 = 10000;
    const PERCENTAGE_DIVISOR: u64 = 10000;

    const E_ROUTER_MIN_RETURN_NOT_REACH: u64 = 1;
    const E_PERCENTAGE: u64 = 2;
    const E_COMMISSION_PERCENTAGE: u64 = 3;
    const E_SUISWAP_MIN_RETURN_NOT_REACH: u64 = 4;
    const E_INVALID_PARAMETER: u64 = 5;
    const E_AFTERMATH_INPUT_AMOUNT: u64 = 6;
    const E_KRIYA_CLMM_MIN_RETURN_NOT_REACH: u64 = 7;
    // const E_MIN_AMOUNT_ZERO: u64 = 8;
    const E_CETUS_MIN_RETURN_NOT_REACH: u64 = 9;
    const E_KRIYA_CLMM_INPUT_AMOUNT: u64 = 10;

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

    public fun afsui_swap_a2b_with_return(
        staked_sui_vault: &mut StakedSuiVault,
        safe: &mut Safe<TreasuryCap<AFSUI>>,
        sui_system_state: &mut 0x3::sui_system::SuiSystemState,
        referral_vault: &ReferralVault,
        coin_in: Coin<SUI>, 
        validater_address: address, 
        ctx: &mut TxContext,
    ): (Coin<AFSUI>, u64) {
        let afsui = request_stake(
            staked_sui_vault,
            safe,
            sui_system_state,
            referral_vault,
            coin_in,
            validater_address,
            ctx
        );

        let afsui_value = coin::value(&afsui);

        event::emit(HopRecord{ 
            out_amount: afsui_value
        });

        (afsui, afsui_value)
    }

    public fun afsui_swap_b2a_with_return(
        staked_sui_vault: &mut StakedSuiVault,
        safe: &Safe<TreasuryCap<AFSUI>>,
        referral_vault: &ReferralVault,
        treasury: &mut Treasury,
        coin_in: Coin<AFSUI>,
        ctx: &mut TxContext,
    ): (Coin<SUI>, u64) {
        let sui = request_unstake_atomic(
            staked_sui_vault,
            safe,
            referral_vault,
            treasury,
            coin_in,
            ctx
        );

        let sui_value = coin::value(&sui);

        event::emit(HopRecord{ 
            out_amount: sui_value
        });

        (sui, sui_value)
    }

    public fun deepbook_swap_base_to_quote_with_return<BaseAsset, QuoteAsset>(
        self: &mut deepbook::pool::Pool<BaseAsset, QuoteAsset>,
        base_in: Coin<BaseAsset>,
        min_quote_out: u64,
        clock: &Clock,
        ctx: &mut TxContext,
    ): (Coin<QuoteAsset>, u64) {
        let (base_left, quote_return, deep_return) = swap_exact_base_for_quote(
            self,
            base_in,
            coin::zero<DEEP>(ctx),
            min_quote_out,
            clock,
            ctx
        );

        destroy_or_transfer(deep_return, ctx);
        destroy_or_transfer(base_left, ctx);

        let quote_out_value = coin::value(&quote_return);

        event::emit(HopRecord{ 
            out_amount: quote_out_value
        });

        (quote_return, quote_out_value)
    }

    public fun deepbook_swap_quote_to_base_with_return<BaseAsset, QuoteAsset>(
        self: &mut deepbook::pool::Pool<BaseAsset, QuoteAsset>,
        quote_in: Coin<QuoteAsset>,
        min_base_out: u64,
        clock: &Clock,
        ctx: &mut TxContext,
    ) : (Coin<BaseAsset>, u64) {
        let (base_return, quote_left, deep_return) = swap_exact_quote_for_base(
            self,
            quote_in,
            coin::zero<DEEP>(ctx),
            min_base_out,
            clock,
            ctx
        );

        destroy_or_transfer(deep_return, ctx);
        destroy_or_transfer(quote_left, ctx);

        let base_out_value = coin::value(&base_return);

        event::emit(HopRecord{ 
            out_amount: base_out_value
        });

        (base_return, base_out_value)
    }

    //kriya clmm
    public fun kriya_clmm_swap_token_x_with_return<T0, T1>(
        pool: &mut kriya_clmmpool::Pool<T0, T1>,
        coin_x: sui::coin::Coin<T0>,
        amount_in: u64,
        min_out: u64,
        clock: &Clock,
        version: &Version,
        _order_id: u64,
        _decimal: u8,
        ctx: &mut TxContext
    ): (Coin<T1>, u64) {
        assert!(coin::value<T0>(&coin_x) == amount_in, E_KRIYA_CLMM_INPUT_AMOUNT);
        let (receive_x, receive_y, flash_receipt) = kriya_clmm::flash_swap<T0, T1>(
            pool,
            true,
            true,
            amount_in,
            tick_math::min_sqrt_price(),
            clock,
            version,
            ctx
        );

        let amount_out = balance::value(&receive_y);
        assert!(amount_out >= min_out, E_KRIYA_CLMM_MIN_RETURN_NOT_REACH);

        balance::destroy_zero(receive_x);
        let (amount_x_debt, _) = kriya_clmm::swap_receipt_debts(&flash_receipt);
        let balance_x = coin::into_balance(coin::split(&mut coin_x, amount_x_debt, ctx));
        let balance_y = balance::zero<T1>();

        kriya_clmm::repay_flash_swap<T0, T1>(
            pool,
            flash_receipt,
            balance_x,
            balance_y,
            version,
            ctx
        );

        destroy_or_transfer(coin_x, ctx);

        event::emit(HopRecord{ 
            out_amount: amount_out
        });

        (coin::from_balance(receive_y, ctx), amount_out)
    }

    public fun kriya_clmm_swap_token_y_with_return<T0, T1>(
        pool: &mut kriya_clmmpool::Pool<T0, T1>,
        coin_y: sui::coin::Coin<T1>,
        amount_in: u64,
        min_out: u64,
        clock: &Clock,
        version: &Version,
        _order_id: u64,
        _decimal: u8,
        ctx: &mut TxContext
    ): (Coin<T0>, u64) {
        assert!(coin::value<T1>(&coin_y) == amount_in, E_KRIYA_CLMM_INPUT_AMOUNT);
        let (receive_x, receive_y, flash_receipt) = kriya_clmm::flash_swap<T0, T1>(
            pool,
            false,
            true,
            amount_in,
            tick_math::max_sqrt_price(),
            clock,
            version,
            ctx
        );

        let amount_out = balance::value(&receive_x);
        assert!(amount_out >= min_out, E_KRIYA_CLMM_MIN_RETURN_NOT_REACH);

        balance::destroy_zero(receive_y);
        let (_, amount_y_debt) = kriya_clmm::swap_receipt_debts(&flash_receipt);
        let balance_x = balance::zero<T0>();
        let balance_y = coin::into_balance(coin::split(&mut coin_y, amount_y_debt, ctx));

        kriya_clmm::repay_flash_swap<T0, T1>(
            pool,
            flash_receipt,
            balance_x,
            balance_y,
            version,
            ctx
        );

        destroy_or_transfer(coin_y, ctx);

        event::emit(HopRecord{ 
            out_amount: amount_out
        });

        (coin::from_balance(receive_x, ctx), amount_out)
    }

    // kriya amm
    public fun kriya_amm_swap_token_x_with_return<T0, T1>(
        pool: &mut kriya_amm::Pool<T0, T1>,
        coin_in: sui::coin::Coin<T0>,
        amount_in: u64,
        min_out: u64,
        _order_id: u64,
        _decimal: u8,
        ctx: &mut TxContext
    ): (Coin<T1>, u64) {
        let coin_y_out = kriya_amm::swap_token_x<T0, T1>(
            pool,
            coin_in,
            amount_in,
            min_out,
            ctx
        );

        let coin_y_value = coin::value(&coin_y_out);

        event::emit(HopRecord{ 
            out_amount: coin_y_value
        });

        (coin_y_out, coin_y_value)
    }

    public fun kriya_amm_swap_token_y_with_return<T0, T1>(
        pool: &mut kriya_amm::Pool<T0, T1>,
        coin_in: sui::coin::Coin<T1>,
        amount_in: u64,
        min_out: u64,
        _order_id: u64,
        _decimal: u8,
        ctx: &mut TxContext
    ): (Coin<T0>, u64) {
        let coin_x_out = kriya_amm::swap_token_y<T0, T1>(
            pool,
            coin_in,
            amount_in,
            min_out,
            ctx
        );

        let coin_x_value = coin::value(&coin_x_out);

        event::emit(HopRecord{ 
            out_amount: coin_x_value
        });

        (coin_x_out, coin_x_value)
    }

    // aftermath
    public fun aftermath_swap_exact_in_with_return<T0, T1, T2>(
        pool: &mut amm::pool::Pool<T0>,
        pool_registry: &amm::pool_registry::PoolRegistry,
        vault: &protocol_fee_vault::vault::ProtocolFeeVault,
        treasury: &mut treasury::treasury::Treasury,
        insurance_fund: &mut insurance_fund::insurance_fund::InsuranceFund,
        referral_vault: &referral_vault::referral_vault::ReferralVault,
        coin_in: sui::coin::Coin<T1>,
        amount_in: u64,
        expected_coin_out: u64,
        allowable_slippage: u64,
        _order_id: u64,
        _decimal: u8,
        ctx: &mut TxContext
    ): (Coin<T2>, u64) {
        assert!(coin::value<T1>(&coin_in) == amount_in, E_AFTERMATH_INPUT_AMOUNT);
        
        let out_coin = swap_exact_in<T0, T1, T2>(
            pool, 
            pool_registry, 
            vault, 
            treasury, 
            insurance_fund,
            referral_vault,
            coin_in,
            expected_coin_out,
            allowable_slippage,
            ctx
        );
        let out_amount = coin::value(&out_coin);

        event::emit(HopRecord{ 
            out_amount: out_amount
        });

        (out_coin, out_amount)
    }

    // movepump
    public fun movepump_buy_returns<CoinType>(
        config: &mut Configuration,
        sui_coin: Coin<SUI>,
        dex_info: &mut Dex_Info,
        coin_min_out: u64,
        clock: &Clock,
        _order_id: u64,
        _decimal: u8,
        ctx: &mut TxContext
    ): (Coin<CoinType>, u64) {
        let (left_sui, out_coin) = buy_returns<CoinType>(config, sui_coin, dex_info, coin_min_out, clock, ctx);
        destroy_or_transfer(left_sui, ctx);
        let out_amount = coin::value(&out_coin);

        event::emit(HopRecord{ 
            out_amount: out_amount
        });

        (out_coin, out_amount)
    }

    public fun movepump_sell_returns<CoinType>(
        config: &mut Configuration,
        coin: Coin<CoinType>,
        sui_min_out: u64,
        clock: &Clock,
        _order_id: u64,
        _decimal: u8,
        ctx: &mut TxContext
    ): (Coin<SUI>, u64){
        let (out_sui, left_coin) = sell_returns<CoinType>(config, coin, sui_min_out, clock, ctx);
        destroy_or_transfer(left_coin, ctx);
        let out_amount = coin::value(&out_sui);

        event::emit(HopRecord{ 
            out_amount: out_amount
        });

        (out_sui, out_amount)
    }

    // suiswap
    public fun suiswap_x_2_y_with_return<Ty0, Ty1>(
        pool: &mut suiswap_pool::Pool<Ty0, Ty1>,
        coins: vector<Coin<Ty0>>,
        amount_in: u64,
        min_out: u64,
        clock: &Clock,
        _order_id: u64,
        _decimal: u8,
        ctx: &mut TxContext
    ):(Coin<Ty1>, u64) {
        let (coin_x_left, coin_y_out) = suiswap_pool::do_swap_x_to_y_direct<Ty0, Ty1>(
            pool,
            coins,
            amount_in,
            clock,
            ctx
        );

        assert!(coin::value<Ty1>(&coin_y_out) >= min_out, E_SUISWAP_MIN_RETURN_NOT_REACH);

        destroy_or_transfer<Ty0>(coin_x_left, ctx);
        let coin_y_value = coin::value(&coin_y_out);

        event::emit(HopRecord{ 
            out_amount: coin_y_value
        });

        (coin_y_out, coin_y_value)
    }

    public fun suiswap_y_2_x_with_return<Ty0, Ty1>(
        pool: &mut suiswap_pool::Pool<Ty0, Ty1>,
        coins: vector<Coin<Ty1>>,
        amount_in: u64,
        min_out: u64,
        clock: &Clock,
        _order_id: u64,
        _decimal: u8,
        ctx: &mut TxContext
    ):(Coin<Ty0>, u64) {    
        let (coin_y_left, coin_x_out) = suiswap_pool::do_swap_y_to_x_direct<Ty0, Ty1>(
            pool,
            coins,
            amount_in,
            clock,
            ctx
        );

        assert!(coin::value<Ty0>(&coin_x_out) >= min_out, E_SUISWAP_MIN_RETURN_NOT_REACH);

        destroy_or_transfer<Ty1>(coin_y_left, ctx);
        let coin_x_value = coin::value(&coin_x_out);

        event::emit(HopRecord{ 
            out_amount: coin_x_value
        });

        (coin_x_out, coin_x_value)
    }

    // cetus
    public fun cetus_swap_a2b_with_return<CoinTypeA, CoinTypeB>(
        config: &GlobalConfig,
        pool: &mut cetus_pool::Pool<CoinTypeA, CoinTypeB>,
        coins_a: vector<Coin<CoinTypeA>>,
        by_amount_in: bool,
        amount: u64,
        amount_limit: u64,
        sqrt_price_limit: u128,
        clock: &Clock,
        _order_id: u64,
        _decimal: u8,
        ctx: &mut TxContext
    ): (Coin<CoinTypeB>, u64) {
        let (coin_a_left, coin_b_out) = swapWithReturn(
            config,
            pool,
            coins_a,
            vector::empty(),
            true,
            by_amount_in,
            amount,
            amount_limit,
            sqrt_price_limit,
            clock,
            ctx
        );

        destroy_or_transfer(coin_a_left, ctx);
        let coin_b_value = coin::value(&coin_b_out);

        event::emit(HopRecord{ 
            out_amount: coin_b_value
        });

        (coin_b_out, coin_b_value)
    }

    public fun cetus_swap_b2a_with_return<CoinTypeA, CoinTypeB>(
        config: &GlobalConfig,
        pool: &mut cetus_pool::Pool<CoinTypeA, CoinTypeB>,
        coins_b: vector<Coin<CoinTypeB>>,
        by_amount_in: bool,
        amount: u64,
        amount_limit: u64,
        sqrt_price_limit: u128,
        clock: &Clock,
        _order_id: u64,
        _decimal: u8,
        ctx: &mut TxContext
    ): (Coin<CoinTypeA>, u64) {
        let (coin_a_out, coin_b_left) = swapWithReturn(
            config,
            pool,
            vector::empty(),
            coins_b,
            false,
            by_amount_in,
            amount,
            amount_limit,
            sqrt_price_limit,
            clock,
            ctx
        );

        destroy_or_transfer(coin_b_left, ctx);
        let coin_a_value = coin::value(&coin_a_out);

        event::emit(HopRecord{ 
            out_amount: coin_a_value
        });

        (coin_a_out, coin_a_value)
    }

    fun merge_coins<CoinType> (
        coins: vector<Coin<CoinType>>,
        ctx: &mut TxContext
    ): Coin<CoinType> {
        if (vector::is_empty(&coins)) {
            vector::destroy_empty(coins);
            coin::zero<CoinType>(ctx)
        } else {
            let coin = vector::pop_back(&mut coins);
            pay::join_vec(&mut coin, coins);
            coin
        }
    }
        
    fun swapWithReturn<CoinTypeA, CoinTypeB>(
        config: &GlobalConfig,
        pool: &mut cetus_pool::Pool<CoinTypeA, CoinTypeB>,
        coins_a: vector<Coin<CoinTypeA>>,
        coins_b: vector<Coin<CoinTypeB>>,
        a2b: bool,
        by_amount_in: bool,
        amount: u64,
        amount_limit: u64,
        sqrt_price_limit: u128,
        clock: &Clock,
        ctx: &mut TxContext
    ): (Coin<CoinTypeA>, Coin<CoinTypeB>) {
        let (coin_a, coin_b) = (merge_coins(coins_a, ctx), merge_coins(coins_b, ctx));
        let (receive_a, receive_b, flash_receipt) = cetus_pool::flash_swap<CoinTypeA, CoinTypeB>(
            config,
            pool,
            a2b,
            by_amount_in,
            amount,
            sqrt_price_limit,
            clock
        );
        let (in_amount, _out_amount) = (
            cetus_pool::swap_pay_amount(&flash_receipt),
            if (a2b) balance::value(&receive_b) else balance::value(&receive_a)
        );

        // pay for flash swap
        let (pay_coin_a, pay_coin_b) = if (a2b) {
            (coin::into_balance(coin::split(&mut coin_a, in_amount, ctx)), balance::zero<CoinTypeB>())
        } else {
            (balance::zero<CoinTypeA>(), coin::into_balance(coin::split(&mut coin_b, in_amount, ctx)))
        };

        coin::join(&mut coin_b, coin::from_balance(receive_b, ctx));
        coin::join(&mut coin_a, coin::from_balance(receive_a, ctx));

        cetus_pool::repay_flash_swap<CoinTypeA, CoinTypeB>(
            config,
            pool,
            pay_coin_a,
            pay_coin_b,
            flash_receipt
        );

        if (a2b) {
            let coin_b_value = coin::value(&coin_b);
            if (coin_b_value < amount_limit) {
                abort E_CETUS_MIN_RETURN_NOT_REACH
            }
        } else {
            let coin_a_value = coin::value(&coin_a);
            if (coin_a_value < amount_limit) {
                abort E_CETUS_MIN_RETURN_NOT_REACH
            }
        };

        (coin_a, coin_b)
    }

    //Turbos
    public fun turbos_swap_a_b_with_return<CoinTypeA, CoinTypeB, FeeType> (
        pool: &mut turbos_pool::Pool<CoinTypeA, CoinTypeB, FeeType>,
        coins_a: vector<Coin<CoinTypeA>>, 
        amount: u64,
        amount_threshold: u64,
        sqrt_price_limit: u128,
        is_exact_in: bool,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
        _order_id: u64,
        _decimal: u8,
        ctx: &mut TxContext
    ): (Coin<CoinTypeB>, u64) {
        check_version(versioned);
        let (coin_b_out, coin_a_left) = swap_a_b_with_return_(
            pool,
            coins_a,
            amount,
            amount_threshold,
            sqrt_price_limit,
            is_exact_in,
            recipient,
            deadline,
            clock,
            versioned,
            ctx
        );

        destroy_or_transfer(coin_a_left, ctx);
        let coin_b_out_value = coin::value(&coin_b_out);

        event::emit(HopRecord{ 
            out_amount: coin_b_out_value
        });

        (coin_b_out, coin_b_out_value)
    }

    public fun turbos_swap_b_a_with_return<CoinTypeA, CoinTypeB, FeeType>(
        pool: &mut turbos_pool::Pool<CoinTypeA, CoinTypeB, FeeType>,
        coins_b: vector<Coin<CoinTypeB>>, 
        amount: u64,
        amount_threshold: u64,
        sqrt_price_limit: u128,
        is_exact_in: bool,
        recipient: address,
        deadline: u64,
        clock: &Clock,
        versioned: &Versioned,
        _order_id: u64,
        _decimal: u8,
        ctx: &mut TxContext
    ): (Coin<CoinTypeA>, u64) {
        check_version(versioned);
        let (coin_a_out, coin_b_left) = swap_b_a_with_return_(
            pool,
            coins_b, 
            amount,
            amount_threshold,
            sqrt_price_limit,
            is_exact_in,
            recipient,
            deadline,
            clock,
            versioned,
            ctx
        );

        destroy_or_transfer(coin_b_left, ctx);
        let coin_a_out_value = coin::value(&coin_a_out);

        event::emit(HopRecord{ 
            out_amount: coin_a_out_value
        });

        (coin_a_out, coin_a_out_value)
    }

    public fun bluemove_swap_exact_input_with_return<T0, T1>(
        amount_in: u64, 
        coin_in: Coin<T0>, 
        min_return: u64, 
        dex_info: &mut Dex_Info, 
        _order_id: u64,
        _decimal: u8,
        ctx: &mut TxContext
    ): (Coin<T1>, u64) {
        let coin_out = router::swap_exact_input_<T0, T1>(
            amount_in,
            coin_in,
            min_return,
            dex_info,
            ctx
        );

        let coin_out_value = coin::value(&coin_out);

        event::emit(HopRecord{ 
            out_amount: coin_out_value
        });

        (coin_out, coin_out_value)
    }

    public fun bluemove_stable_swap_exact_input_with_return<T0, T1>(
        coin_in: Coin<T0>,
        amount_in: u64,
        min_return: u64,
        dex_stable_info: &mut Dex_Stable_Info,
        clock: &Clock,
        _order_id: u64,
        _decimal: u8,
        ctx: &mut TxContext
    ): (Coin<T1>, u64) {
        let coin_out = stable_router::swap_exact_input_<T0, T1>(
            coin_in,
            amount_in,
            min_return,
            dex_stable_info,
            clock,
            ctx
        );

        let coin_out_value = coin::value(&coin_out);

        event::emit(HopRecord{ 
            out_amount: coin_out_value
        });

        (coin_out, coin_out_value)
    }

    public fun flowxv3_swap_a2b_with_return<CoinTypeA, CoinTypeB>(
        clock: &Clock,
        versioned: &flowx_versiond::Versioned,
        pool_registry:  &mut pool_manager::PoolRegistry,
        fee_rate: u64,
        coins_a: Coin<CoinTypeA>,
        by_amount_in: bool,
        sqrt_price_max_limit: u128,
        _order_id: u64,
        _decimal: u8,
        ctx: &mut TxContext
    ): (Coin<CoinTypeB>, u64) {
        let pool = pool_manager::borrow_mut_pool<CoinTypeA, CoinTypeB>(pool_registry, fee_rate);

        let (a_out, b_out, receipt) = flowx_pool::swap(
            pool,
            true,
            by_amount_in,
            coin::value(&coins_a),
            sqrt_price_max_limit,
            versioned,
            clock,
            ctx
        );

        balance::destroy_zero(a_out);

        let (amount_a_required, _) = flowx_pool::swap_receipt_debts(&receipt);
        flowx_pool::pay(
            pool,
            receipt,
            balance::split(coin::balance_mut(&mut coins_a), amount_a_required),
            balance::zero(),
            versioned,
            ctx
        );

        let b_out_value = balance::value(&b_out);
        let coin_b_out = coin::from_balance<CoinTypeB>(b_out, ctx);

        destroy_or_transfer(coins_a, ctx);

        event::emit(HopRecord{ 
            out_amount: b_out_value
        });

        (coin_b_out, b_out_value)
    }

    public fun flowxv3_swap_b2a_with_return<CoinTypeA, CoinTypeB>(
        clock: &Clock,
        versioned: &flowx_versiond::Versioned,
        pool_registry: &mut pool_manager::PoolRegistry,
        fee_rate: u64,
        coins_b: Coin<CoinTypeB>,
        by_amount_in: bool,
        sqrt_price_max_limit: u128,
        _order_id: u64,
        _decimal: u8,
        ctx: &mut TxContext
    ): (Coin<CoinTypeA>, u64) {

        let pool = pool_manager::borrow_mut_pool<CoinTypeA, CoinTypeB>(pool_registry, fee_rate);

        let (a_out, b_out, receipt) = flowx_pool::swap(
            pool,
            false,
            by_amount_in,
            coin::value(&coins_b),
            sqrt_price_max_limit,
            versioned,
            clock,
            ctx
        );
        balance::destroy_zero(b_out);

        let (_, amount_b_required) = flowx_pool::swap_receipt_debts(&receipt);
        flowx_pool::pay(
            pool,
            receipt,
            balance::zero(),
            balance::split(coin::balance_mut(&mut coins_b), amount_b_required),
            versioned,
            ctx
        );

        let a_out_value = balance::value(&a_out);
        let coin_a_out = coin::from_balance<CoinTypeA>(a_out, ctx);

        destroy_or_transfer(coins_b, ctx);

        event::emit(HopRecord{ 
            out_amount: a_out_value
        });

        (coin_a_out, a_out_value)
    }

    public fun flowx_swap_exact_input_direct_with_return<CoinTypeA, CoinTypeB>(
        container: &mut flowxv2::factory::Container,
        input: Coin<CoinTypeA>,
        ctx: &mut TxContext
    ): (Coin<CoinTypeB>, u64) {
        let output = flowxv2::router::swap_exact_input_direct(container, input, ctx);

        let output_value = coin::value(&output);

        event::emit(HopRecord{ 
            out_amount: output_value
        });

        (output, output_value)
    }

    public fun finalize_without_transfer<CoinType>(
        coin: Coin<CoinType>,
        order_id: u64,
        decimal: u8,
        _ctx: &mut TxContext,
    ) : (Coin<CoinType>, u64) {
        let amount_out = coin::value(&coin);
        
        event::emit(OrderRecord{ 
            order_id: order_id,
            decimal: decimal,
            out_amount: amount_out
        });
        
        (coin, amount_out)
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