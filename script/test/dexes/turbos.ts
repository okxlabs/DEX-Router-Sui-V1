// ============================================================================
// DEX Router Turbos Test Script
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
// Turbos Specific Constants
// ============================================================================

const TURBOS_POOL = "0x5eb2dfcdd1b15d2021328258f6d5ec081e9a0cdcfa9e13a0eaeb9b5f7505ca78";
const TURBOS_VERSIONED = "0xf1cf0e81048df168ebeb1b8030fad24b3e0b53ae827c25053fff0779c1445b6f";
const FEE_TYPE = "0x91bfbc386a41afcfd9b2533058d7e915a1d3829089cc268ff4333d54d6339ca1::fee3000bps::FEE3000BPS";

// ============================================================================
// Main Turbos Test Function
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
    const gasBudget = 4051120;
    const swapAmount = 1 * 10 ** SUI_DECIMAL; // 1 SUI in mist

    txb.setGasBudget(gasBudget);

    // Prepare input coin
    const inputCoin = txb.splitCoins(
        txb.gas,
        [txb.pure(swapAmount.toString())]
    );

    // ============================================================================
    // Turbos Swap: SUI → USDC
    // ============================================================================

    const [outputCoin, outputAmount] = txb.moveCall({
        target: `${DEX_ROUTER}::router::turbos_swap_a_b_with_return`,
        arguments: [
            txb.object(TURBOS_POOL),                    // pool
            txb.makeMoveVec({ objects: [inputCoin] }),  // coins
            txb.pure(swapAmount),                       // amount
            txb.pure(800000),                           // amount_threshold
            txb.pure(4295048017),                       // sqrt_price_limit
            txb.pure(true),                             // by_amount_in
            txb.pure(walletAddress),                    // recipient
            txb.pure(Date.now() + 3600000),             // deadline
            txb.object(SUI_CLOCK_OBJECT_ID),            // clock
            txb.object(TURBOS_VERSIONED),               // versioned
            txb.pure(0),                                // order_id
            txb.pure(SUI_DECIMAL),                      // decimal
        ],
        typeArguments: [SUI_TYPE, USDC_TYPE, FEE_TYPE]
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
            txb.pure(SUI_TYPE),            // from_coin_address
            txb.pure(swapAmount),          // from_coin_amount
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

    console.log("Turbos Swap Result:", result);
}

// ============================================================================
// Execute Script
// ============================================================================

main().catch((error) => {
    console.error("Error executing Turbos test:", error);
    process.exit(1);
});