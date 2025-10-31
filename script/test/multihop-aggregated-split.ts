/**
 * Multihop3: "Aggregated Split" Strategy
 * 
 * Flow Diagram:
 * 100% SUI
 * ├── 40% → Turbos (SUI → USDC) ──┐
 * │                               │
 * ├── 60% → FlowX V3 (SUI → USDC) ┤
 * │                               │
 * └─────────────── Merge USDC ────┘
 *             │
 *             ▼
 *       Split into two USDC
 *         │           │
 *         │           │
 *         ▼           ▼
 *    KriyaAMM      SuiSwap
 *  (USDC→USDT)   (USDC→USDT)
 *         │           │
 *         └─────┬─────┘
 *               ▼
 *            Merge USDT
 *               │
 *               ▼
 *            100% USDT
 * 
 * Strategy: Aggregation followed by proportional splitting
 * - 2 parallel SUI → USDC swaps (40% + 60%)
 * - Merge all USDC first for maximum liquidity
 * - Split merged USDC into 2 parts (20% + 80%)
 * - Parallel USDC → USDT conversions
 * - Final merge of all USDT
 * 
 * DAG Analysis:
 * - Fan-out degree: 2 (SUI splits into 2 paths)
 * - Fan-in degree: 1 (all paths merge at USDC level, then split again)
 * - Depth: 4 levels (SUI → USDC → merge → split → USDT)
 * - Parallelism: Low (sequential merge-split operations)
 */
import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { SuiClient } from "@mysten/sui.js/client";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { SUI_CLOCK_OBJECT_ID } from "@mysten/sui.js/utils";
import * as dotenv from "dotenv";

// Load environment variables
dotenv.config();

// ============================================================================
// Configuration Constants
// ============================================================================

// Environment validation
const PRIVATE_KEY_STR = process.env.PRIVATE_KEY_STR;
if (!PRIVATE_KEY_STR) {
    throw new Error("PRIVATE_KEY_STR environment variable is required");
}

// Private key processing
const PRIVATE_KEY = Buffer.from(PRIVATE_KEY_STR, "base64").subarray(1);

// Load configuration
const config = require("../config/configInfo.json");
const DEX_ROUTER = config["DEX"]!;

// Token configurations
const USDC_ID = config["USDC_ID"]!;
const USDC_DECIMAL = 6;
const USDC_TYPE = `${USDC_ID}::coin::COIN`;

const SUI_ID = config["SUI_ID"]!;
const SUI_DECIMAL = 9;
const SUI_TYPE = `${SUI_ID}::sui::SUI`;

const USDT_ID = config["USDT_ID"]!;
const USDT_DECIMAL = 6;
const USDT_TYPE = `${USDT_ID}::coin::COIN`;
// ============================================================================
// Multihop Aggregated Split Constants
// ============================================================================

// Pool addresses
const TURBOS_POOL = "0x5eb2dfcdd1b15d2021328258f6d5ec081e9a0cdcfa9e13a0eaeb9b5f7505ca78"; // SUI/USDC

// FlowX V3 constants
const FLOWX_V3_VERSIONED = "0x67624a1533b5aff5d0dfcf5e598684350efd38134d2d245f475524c03a64e656";
const FLOWX_V3_POOL_REGISTRY = "0x27565d24a4cd51127ac90e4074a841bbe356cca7bf5759ddc14a975be1632abc";

// USDC/USDT pools
const KRIYA_STABLE_POOL = "0xd0086b7713e0487bbf5bb4a1e30a000794e570590a6041155cdbebee3cb1cb77"; // USDC/USDT
const SUISWAP_USDC_USDT_POOL = "0x08948c60f307c52f8f9dc5b2a6a832feef159318998e375560d3187c1c25fbce"; // USDC/USDT

// Fee and version constants
const FEE_TYPE = "0x91bfbc386a41afcfd9b2533058d7e915a1d3829089cc268ff4333d54d6339ca1::fee3000bps::FEE3000BPS";
const TURBOS_VERSIONED = "0xf1cf0e81048df168ebeb1b8030fad24b3e0b53ae827c25053fff0779c1445b6f";

// ============================================================================
// Main Multihop Aggregated Split Function
// ============================================================================

async function main(): Promise<void> {
    // Initialize provider and wallet
    const provider = new SuiClient({
        url: "https://sui-rpc.publicnode.com"
    });

    const keypair = Ed25519Keypair.fromSecretKey(PRIVATE_KEY);
    const walletAddress = keypair.getPublicKey().toSuiAddress();

    console.log("Wallet Address:", walletAddress);

    // Create transaction block
    const txb = new TransactionBlock();

    // Transaction parameters
    const gasBudget = 20000000;
    const totalAmount = 0.1 * 10 ** SUI_DECIMAL; // 0.1 SUI in mist
    const deadline = 1816360958068;

    // Calculate amounts for each path
    const amount40 = Math.floor(totalAmount * 0.4); // 40% for Turbos
    const amount60 = Math.floor(totalAmount * 0.6); // 60% for FlowX

    txb.setGasBudget(gasBudget);

    console.log(`Total Amount: ${totalAmount} mist`);
    console.log(`Turbos Amount (40%): ${amount40} mist`);
    console.log(`FlowX Amount (60%): ${amount60} mist`);

    // Split coins from gas for different paths
    const amountCoin40 = txb.splitCoins(
        txb.gas,
        [txb.pure(amount40.toString())]
    );
    const amountCoin60 = txb.splitCoins(
        txb.gas,
        [txb.pure(amount60.toString())]
    );

    // ============================================================================
    // Step 1: Two Parallel SUI → USDC Swaps
    // ============================================================================

    // 1. Turbos: SUI → USDC (40%)
    const [turbosOut, turbosAmount] = txb.moveCall({
        target: `${DEX_ROUTER}::router::turbos_swap_a_b_with_return`,
        arguments: [
            txb.object(TURBOS_POOL),                        // pool
            txb.makeMoveVec({ objects: [amountCoin40] }),  // coins
            txb.pure(amount40),                            // amount
            txb.pure(0),                                   // amount_threshold
            txb.pure(4295048016),                          // sqrt_price_limit
            txb.pure(true),                                // by_amount_in
            txb.pure(walletAddress),               // referral
            txb.pure(deadline),                            // deadline
            txb.object(SUI_CLOCK_OBJECT_ID),              // clock
            txb.object(TURBOS_VERSIONED),                  // versioned
            txb.pure(0),                                   // order_id
            txb.pure(SUI_DECIMAL),                         // decimal
        ],
        typeArguments: [SUI_TYPE, USDC_TYPE, FEE_TYPE]
    });

    // 2. FlowX V3: SUI → USDC (60%)
    const [flowxOut, flowxAmount] = txb.moveCall({
        target: `${DEX_ROUTER}::router::flowxv3_swap_a2b_with_return`,
        arguments: [
            txb.object(SUI_CLOCK_OBJECT_ID),              // clock
            txb.object(FLOWX_V3_VERSIONED),               // versioned
            txb.object(FLOWX_V3_POOL_REGISTRY),           // pool_registry
            txb.pure(100),                                // fee_rate
            amountCoin60,                                 // coin_in
            txb.pure(true),                               // by_amount_in
            txb.pure(BigInt("4295048017")),              // sqrt_price_limit
            txb.pure(0),                                  // order_id
            txb.pure(USDC_DECIMAL),                       // decimal
        ],
        typeArguments: [SUI_TYPE, USDC_TYPE]
    });

    // ============================================================================
    // Step 2: Merge All USDC for Maximum Liquidity
    // ============================================================================

    // Merge Turbos and FlowX USDC outputs
    txb.mergeCoins(turbosOut, [flowxOut]);

    // ============================================================================
    // Step 3: Split Merged USDC into Two Parts (20% + 80%)
    // ============================================================================

    const [usdcForKriya, usdcForKriyaAmount, usdcForSuiSwap, usdcForSuiSwapAmount] = txb.moveCall({
        target: `${DEX_ROUTER}::router::split_with_percentage`,
        arguments: [
            turbosOut,                                  // input coin
            txb.pure(2000)                              // 20% (2000/10000)
        ],
        typeArguments: [USDC_TYPE]
    });

    // Transfer remaining USDC to receiver
    txb.transferObjects([turbosOut], txb.pure(walletAddress));

    // ============================================================================
    // Step 4: Parallel USDC → USDT Conversions
    // ============================================================================

    // KriyaAMM: USDC → USDT (20%)
    const [kriyaOut, kriyaAmount] = txb.moveCall({
        target: `${DEX_ROUTER}::router::kriya_amm_swap_token_x_with_return`,
        arguments: [
            txb.object(KRIYA_STABLE_POOL),              // USDC-USDT stable pool
            usdcForKriya,                               // coin_in
            usdcForKriyaAmount,                         // amount
            txb.pure(0),                                // min_return
            txb.pure(0),                                // order_id
            txb.pure(USDC_DECIMAL),                     // decimal
        ],
        typeArguments: [USDC_TYPE, USDT_TYPE]
    });

    // SuiSwap: USDC → USDT (80%)
    const [suiswapOut, suiswapAmount] = txb.moveCall({
        target: `${DEX_ROUTER}::router::suiswap_x_2_y_with_return`,
        arguments: [
            txb.object(SUISWAP_USDC_USDT_POOL),         // pool
            txb.makeMoveVec({ objects: [usdcForSuiSwap] }), // coins
            usdcForSuiSwapAmount,                       // amount
            txb.pure(0),                                // min_amount_out
            txb.object(SUI_CLOCK_OBJECT_ID),            // clock
            txb.pure(0),                                // order_id
            txb.pure(USDC_DECIMAL),                     // decimal
        ],
        typeArguments: [USDC_TYPE, USDT_TYPE]
    });

    // ============================================================================
    // Step 5: Finalize All Transactions
    // ============================================================================

    // Set transaction sender
    txb.setSender(walletAddress);

    // Merge all USDT outputs
    txb.mergeCoins(kriyaOut, [suiswapOut]);

    // Standard finalize call
    txb.moveCall({
        target: `${DEX_ROUTER}::router::finalize`,
        arguments: [
            kriyaOut,                                   // input_coin
            txb.pure(1),                                // min_amount
            txb.pure(0),                                // commission_rate
            txb.pure(walletAddress),                    // referral_address
            txb.pure(walletAddress),                    // receiver_address
            txb.pure(0),                                // order_id
            txb.pure(USDT_DECIMAL),                     // decimal
            txb.pure(SUI_TYPE),                         // from_coin_address
            txb.pure(totalAmount),                      // from_coin_amount
        ],
        typeArguments: [USDT_TYPE]
    });

    // Build and dry run transaction
    const builtTx = await txb.build({ client: provider });
    const result = await provider.dryRunTransactionBlock({
        transactionBlock: builtTx
    });

    // Uncomment to execute transaction
    // const executeResult = await provider.signAndExecuteTransactionBlock({
    //     transactionBlock: builtTx,
    //     signer: keypair,
    //     options: {
    //         showObjectChanges: true,
    //         showEvents: true,
    //         showBalanceChanges: true
    //     }
    // });

    console.log("Multihop Aggregated Split Result:", result);
}

// ============================================================================
// Execute Script
// ============================================================================

main().catch((error) => {
    console.error("Error executing multihop aggregated split:", error);
    process.exit(1);
}); 