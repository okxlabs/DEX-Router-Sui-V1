// ============================================================================
// DEX Router Metastable Test Script
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
const SUI_ID = config["SUI_ID"]!;
const SUI_DECIMAL = 9;
const SUI_TYPE = `${SUI_ID}::sui::SUI`;

const SUPERSUI_TYPE = '0x790f258062909e3a0ffc78b3c53ac2f62d7084c3bab95644bdeb05add7250001::super_sui::SUPER_SUI';
const SUPERSUISUI_DECIMAL = 9;

// ============================================================================
// Metastable Specific Constants
// ============================================================================

const METASTABLE_SUI_LST_INTEGRATIONS = config["METASTABLE_SUI_LST_INTEGRATIONS"]!;
const METASTABLE_AFSUI_LST_INTEGRATIONS = config["METASTABLE_AFSUI_LST_INTEGRATIONS"]!;
const META_VAULT_SUI_INTEGRATION = "0x408618719d06c44a12e9c6f7fdf614a9c2fb79f262932c6f2da7621c68c7bcfa";
const SUPER_SUI_VAULT = "0x3062285974a5e517c88cf3395923aac788dce74f3640029a01e25d76c4e76f5d";
const SUPER_SUI_REGISTRY = "0x5ff2396592a20f7bf6ff291963948d6fc2abec279e11f50ee74d193c4cf0bba8";
const METASTABLE_VERSION = "0x4696559327b35ff2ab26904e7426a1646312e9c836d5c6cff6709a5ccc30915c";

// ============================================================================
// Main Metastable Test Function
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
    const swapAmount = 0.05 * 10 ** 9; // 0.05 SUI in mist

    txb.setGasBudget(gasBudget);

    // Prepare input coin
    const amountCoin = txb.splitCoins(txb.gas, [txb.pure(swapAmount.toString())]);

    // ============================================================================
    // Metastable Swap: SUI → SuperSUI
    // ============================================================================

    // Metastable specific objects
    const metaVaultSuiIntegration = txb.object(META_VAULT_SUI_INTEGRATION);
    const superSuiVault = txb.object(SUPER_SUI_VAULT);
    const superSuiRegistry = txb.object(SUPER_SUI_REGISTRY);
    const metastableVersion = txb.object(METASTABLE_VERSION);

    // Create deposit cap for SUI to SuperSUI swap
    const [depositCap] = txb.moveCall({
        target: `${METASTABLE_SUI_LST_INTEGRATIONS}::exchange_rate::create_deposit_cap`,
        arguments: [
            metaVaultSuiIntegration,
            superSuiVault,
            superSuiRegistry,
        ],
        typeArguments: [SUPERSUI_TYPE]
    });

    // Metastable swap call - SUI to SuperSUI
    const [outputCoin, outputAmount] = txb.moveCall({
        target: `${DEX_ROUTER}::router::metastable_swap_a2b_with_return`,
        arguments: [
            superSuiVault,
            metastableVersion,
            depositCap,
            amountCoin,
            txb.pure(0), // order_id
        ],
        typeArguments: [SUPERSUI_TYPE, SUI_TYPE]
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
            txb.pure(SUPERSUISUI_DECIMAL), // decimal
            txb.pure(SUI_TYPE), // from_coin_address
            txb.pure(swapAmount), // from_coin_amount
        ],
        typeArguments: [SUPERSUI_TYPE]
    });

    // Build and dry run transaction
    const builtTx = await txb.build({ client: provider });
    const result = await provider.dryRunTransactionBlock({
        transactionBlock: builtTx
    });

    console.log("Metastable Swap Result:", result);
}

// ============================================================================
// Execute Script
// ============================================================================

main().catch((error) => {
    console.error("Error executing Metastable test:", error);
    process.exit(1);
});