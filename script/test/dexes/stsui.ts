// ============================================================================
// DEX Router StSUI Test Script
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
const DEX_ROUTER = "0xb46e9ff3bab59a85251c3e87988cf4a55e0fd6fcd785d395397d8f36f0fa7b44";

// Token configurations
const SUI_ID = config["SUI_ID"]!;
const SUI_DECIMAL = 9;
const SUI_TYPE = `${SUI_ID}::sui::SUI`;

const STSUI_DECIMAL = 9;
const STSUI_TYPE = "0xd1b72982e40348d069bb1ff701e634c117bb5f741f44dff91e472d3b01461e55::stsui::STSUI";

// ============================================================================
// StSUI Specific Constants
// ============================================================================

const LIQUID_STAKING_INFO = "0x1adb343ab351458e151bc392fbf1558b3332467f23bda45ae67cd355a57fd5f5";
const SUI_SYSTEM_STATE = "0x0000000000000000000000000000000000000000000000000000000000000005";

// ============================================================================
// Main StSUI Test Function
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
    const swapAmount = 1 * 10 ** 9; // 1 SUI in mist

    txb.setGasBudget(gasBudget);

    // Prepare input coin
    const amountCoin = txb.splitCoins(txb.gas, [txb.pure(swapAmount.toString())]);

    // ============================================================================
    // StSUI Swap: SUI → StSUI
    // ============================================================================

    // StSUI specific objects
    const liquidStakingInfo = txb.object(LIQUID_STAKING_INFO);
    const suiSystemState = txb.object(SUI_SYSTEM_STATE);

    const [outputCoin, outputAmount] = txb.moveCall({
        target: `${DEX_ROUTER}::router::alphafi_swap_a2b_with_return`,
        arguments: [
            liquidStakingInfo,
            suiSystemState,
            amountCoin
        ],
        typeArguments: [STSUI_TYPE]
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
            txb.pure(STSUI_DECIMAL),
        ],
        typeArguments: [STSUI_TYPE]
        });

    // Build and dry run transaction
    const builtTx = await txb.build({ client: provider });
    const result = await provider.dryRunTransactionBlock({
        transactionBlock: builtTx
    });

    console.log("StSUI Swap Result:", result);
}

// ============================================================================
// Execute Script
// ============================================================================

main().catch((error) => {
    console.error("Error executing StSUI test:", error);
    process.exit(1);
});