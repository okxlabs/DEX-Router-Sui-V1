// ============================================================================
// DEX Router KriyaCLMM Test Script
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
const SUI_ID = config["SUI_ID"]!;
const SUI_DECIMAL = 9;
const SUI_TYPE = `${SUI_ID}::sui::SUI`;

const VSUI_TYPE = "0x549e8b69270defbfafd4f94e17ec44cdbdd99820b33bda2278dea3b9a32d3f55::cert::CERT"
const VSUI_DECIMAL = 9;
  
// Kriya CLMM specific constants
const POOL = "0xf1b6a7534027b83e9093bec35d66224daa75ea221d555c79b499f88c93ea58a9"
const VERSION = "0xf5145a7ac345ca8736cf8c76047d00d6d378f30e81be6f6eb557184d9de93c78"

// ============================================================================
// Main KriyaCLMM Test Function
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
    const swapAmount = 0.1 * 10 ** 9; // 0.1 SUI in mist

    txb.setGasBudget(gasBudget);

    // Prepare input coin
    const amountCoin = txb.splitCoins(txb.gas, [txb.pure(swapAmount.toString())]);

    // ============================================================================
    // Kriya CLMM Swap: SUI → vSUI
    // ============================================================================

    // Kriya CLMM specific objects
    const pool = txb.object(POOL);
    const version = txb.object(VERSION);
    const clock = txb.object(SUI_CLOCK_OBJECT_ID);

    // Kriya CLMM swap call - SUI to vSUI
    const [outputCoin, outputAmount] = txb.moveCall({
        target: `${DEX_ROUTER}::router::kriya_clmm_swap_token_y_with_return`,
        arguments: [
            pool, // pool
            amountCoin, // coin_in
            txb.pure(swapAmount), // amount_in
            txb.pure(1), // min_out
            clock, // clock
            version, // version
            txb.pure(0), // order_id
            txb.pure(SUI_DECIMAL) // decimal
        ],
        typeArguments: [VSUI_TYPE, SUI_TYPE]
    });

    // ============================================================================
    // Finalize Transaction
    // ============================================================================

    // Set transaction sender
    txb.setSender(walletAddress);

    txb.moveCall({
        target: `${DEX_ROUTER}::router::finalize`,
        arguments: [
            outputCoin, // inputCoin
            txb.pure(1), // min_amount
            txb.pure(0), // toCommissionRate
            txb.pure(walletAddress), // referalAddress
            txb.pure(walletAddress), // swapReceiverAddress
            txb.pure(0), // orderId
            txb.pure(VSUI_DECIMAL), // decimal
            txb.pure(SUI_TYPE), // from_coin_address
            txb.pure(swapAmount), // from_coin_amount
        ],
        typeArguments: [VSUI_TYPE]
    });

    // Build and dry run transaction
    const builtTx = await txb.build({ client: provider });
    const result = await provider.dryRunTransactionBlock({
        transactionBlock: builtTx
    });

    console.log("KriyaCLMM Swap Result:", result);
}

// ============================================================================
// Execute Script
// ============================================================================

main().catch((error) => {
    console.error("Error executing KriyaCLMM test:", error);
    process.exit(1);
});