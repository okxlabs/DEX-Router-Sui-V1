// ============================================================================
// DEX Router Momentum Test Script
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
const DEX_ROUTER = config["DEX_EXTENDED"]!;

// Token configurations
const SUI_TYPE = "0x2::sui::SUI";
const SUI_DECIMAL = 9;

const USDC_TYPE = "0xdba34672e30cb065b1f93e3ab55318768fd6fef66c15942c9f7cb846e2f900e7::usdc::USDC";
const USDC_DECIMAL = 6;

// ============================================================================
// Momentum Specific Constants
// ============================================================================

const POOL_ID = "0x455cf8d2ac91e7cb883f515874af750ed3cd18195c970b7a2d46235ac2b0c388";
const VERSION_ID = "0x2375a0b1ec12010aaea3b2545acfa2ad34cfbba03ce4b59f4c39e1e25eed1b2a";

const SUI_TO_USDC_LIMIT_PRICE = "4295048017";
const USDC_TO_SUI_LIMIT_PRICE = "79226673515401279992447579050";

const SUI_AMOUNT = 0.1 * 10 ** SUI_DECIMAL;
const USDC_AMOUNT = 0.1 * 10 ** USDC_DECIMAL;

// ============================================================================
// Main Momentum Test Function
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
    txb.setGasBudget(gasBudget);

    const POOL = txb.object(POOL_ID);
    const VERSION = txb.object(VERSION_ID);
    const CLOCK = txb.object(SUI_CLOCK_OBJECT_ID);

    // ============================================================================
    // Momentum Swap: USDC → SUI
    // ============================================================================

    // Get USDC coins from wallet
    const usdcCoins = await provider.getCoins({
        owner: walletAddress,
        coinType: USDC_TYPE
    });

    if (usdcCoins.data.length === 0) {
        throw new Error("No USDC coins found in wallet");
    }

    // Merge USDC coins if multiple
    const coins = usdcCoins.data;
    const [primaryCoin, ...mergeCoins] = coins.filter((coin) => coin.coinType === USDC_TYPE);
    let primaryCoinIn = txb.object(primaryCoin.coinObjectId);

    if (mergeCoins.length > 0) {
        txb.mergeCoins(
            primaryCoinIn,
            mergeCoins.map((coin) => txb.object(coin.coinObjectId)),
        );
        console.log("Merged coins:", mergeCoins.length);
    }

    // Split the required amount
    const [amountCoin] = txb.splitCoins(primaryCoinIn, [txb.pure(USDC_AMOUNT)]);

    const [outputCoin, outputAmount] = txb.moveCall({
        target: `${DEX_ROUTER}::router::momentum_swap_b2a_with_return`,
        arguments: [
            POOL,
            amountCoin,
            txb.pure(USDC_AMOUNT),
            txb.pure(BigInt(USDC_TO_SUI_LIMIT_PRICE), "u128"),
            CLOCK,
            VERSION,
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
            outputCoin,
            txb.pure(1),
            txb.pure(0),
            txb.pure(walletAddress),
            txb.pure(walletAddress),
            txb.pure(0),
            txb.pure(SUI_DECIMAL),
        ],
        typeArguments: [SUI_TYPE]
    });

    // Build and dry run transaction
    const builtTx = await txb.build({ client: provider });
    const dryRunResult = await provider.dryRunTransactionBlock({
        transactionBlock: builtTx
    });

    console.log("Dry Run Result:", dryRunResult);

    // Check if dry run was successful
    if (dryRunResult.effects.status.status !== "success") {
        console.error("Dry run failed:", dryRunResult.effects.status);
        return;
    }

    console.log("\n✅ Dry run successful! Executing real transaction...\n");

    // Execute real transaction
    const realResult = await provider.signAndExecuteTransactionBlock({
        transactionBlock: txb,
        signer: keypair,
        options: {
            showEffects: true,
            showEvents: true,
            showBalanceChanges: true,
        }
    });

    console.log("Transaction Digest:", realResult.digest);
    console.log("Transaction Status:", realResult.effects?.status);
    console.log("Balance Changes:", realResult.balanceChanges);
    console.log("\n🎉 Momentum Swap executed successfully!");
    console.log(`View on explorer: https://suiscan.xyz/mainnet/tx/${realResult.digest}`);
}

// ============================================================================
// Execute Script
// ============================================================================

main().catch((error) => {
    console.error("Error executing Momentum test:", error);
    process.exit(1);
});