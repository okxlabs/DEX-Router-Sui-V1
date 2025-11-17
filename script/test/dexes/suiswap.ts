// ============================================================================
// DEX Router SuiSwap Test Script
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
// SuiSwap Specific Constants
// ============================================================================

const SUISWAP_POOL = "0xddb2164a724d13690e347e9078d4234c9205b396633dfc6b859b09b61bbcd257";

// ============================================================================
// Main SuiSwap Test Function
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
    const swapAmount = 10000;

    txb.setGasBudget(gasBudget);

    // Prepare input coin
    const inputCoin = txb.splitCoins(
        txb.gas,
        [txb.pure(swapAmount.toString())]
    );

    // ============================================================================
    // SuiSwap Swap: USDC → SUI
    // ============================================================================

    const [outputCoin, outputAmount] = txb.moveCall({
        target: `${DEX_ROUTER}::router::suiswap_y_2_x_with_return`,
        arguments: [
            txb.object(SUISWAP_POOL),               // pool
            txb.makeMoveVec({ objects: [inputCoin] }), // coins
            txb.pure(swapAmount),                   // amount
            txb.pure(0),                            // min_amount_out
            txb.object(SUI_CLOCK_OBJECT_ID),        // clock
            txb.pure(0),                            // order_id
            txb.pure(SUI_DECIMAL),                  // decimal
        ],
        typeArguments: [USDC_TYPE, SUI_TYPE]
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

    console.log("SuiSwap Swap Result:", result);
}

// ============================================================================
// Execute Script
// ============================================================================

main().catch((error) => {
    console.error("Error executing SuiSwap test:", error);
    process.exit(1);
});