// ============================================================================
// DEX Router FlowXV3 Test Script
// ============================================================================

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
const config = require("../../config/configInfo.json");
const DEX_ROUTER = config["DEX"]!;

// Token configurations
const USDC_ID = config["USDC_ID"]!;
const USDC_DECIMAL = 6;
const USDC_TYPE = `${USDC_ID}::coin::COIN`;

const SUI_ID = config["SUI_ID"]!;
const SUI_DECIMAL = 9;
const SUI_TYPE = `${SUI_ID}::sui::SUI`;
  
// ============================================================================
// FlowX V3 Specific Constants
// ============================================================================

const FLOWX_V3_CLOCK = "0x0000000000000000000000000000000000000000000000000000000000000006";
const FLOWX_V3_VERSIONED = "0x67624a1533b5aff5d0dfcf5e598684350efd38134d2d245f475524c03a64e656";
const FLOWX_V3_POOL_REGISTRY = "0x27565d24a4cd51127ac90e4074a841bbe356cca7bf5759ddc14a975be1632abc";
const FLOWX_V3_FEE_RATE = 100;

// ============================================================================
// Main FlowXV3 Test Function
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
    const gasBudget = 150000000;
    const swapAmount = 0.1 * 10 ** SUI_DECIMAL; // 0.1 SUI in mist

    txb.setGasBudget(gasBudget);

    // Prepare input coin
    const inputCoin = txb.splitCoins(
        txb.gas,
        [txb.pure(swapAmount.toString())]
    );

    // ============================================================================
    // FlowX V3 Swap: SUI → USDC
    // ============================================================================

    // FlowX V3 specific objects
    const clock = txb.object(FLOWX_V3_CLOCK);
    const versioned = txb.object(FLOWX_V3_VERSIONED);
    const poolRegistry = txb.object(FLOWX_V3_POOL_REGISTRY);

    const [outputCoin, outputAmount] = txb.moveCall({
        target: `${DEX_ROUTER}::router::flowxv3_swap_a2b_with_return`,
        arguments: [
            clock,                              // clock
            versioned,                          // versioned
            poolRegistry,                       // pool_registry
            txb.pure(FLOWX_V3_FEE_RATE),        // fee_rate
            inputCoin,                          // coins_a
            txb.pure(true),                     // by_amount_in
            txb.pure(BigInt("4295048017")),     // sqrt_price_max_limit
            txb.pure(0),                        // order_id
            txb.pure(USDC_DECIMAL),             // decimal
        ],
        typeArguments: [SUI_TYPE, USDC_TYPE]
    });

    // ============================================================================
    // Finalize Transaction
    // ============================================================================

    // Set transaction sender
    txb.setSender(walletAddress);

    txb.moveCall({
        target: `${DEX_ROUTER}::router::finalize`,
        arguments: [
            outputCoin,                    // input_coin
            txb.pure(1),                   // min_amount
            txb.pure(0),                   // commission_rate
            txb.pure(walletAddress),       // referral_address
            txb.pure(walletAddress),       // receiver_address
            txb.pure(0),                   // order_id
            txb.pure(USDC_DECIMAL),        // decimal
        ],
        typeArguments: [USDC_TYPE]
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

    console.log("FlowXV3 Swap Result:", result);
}

// ============================================================================
// Execute Script
// ============================================================================

main().catch((error) => {
    console.error("Error executing FlowXV3 test:", error);
    process.exit(1);
});