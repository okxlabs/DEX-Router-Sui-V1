module 0x682eaba7450909645bf949db3fc5881432a00b49b4c06d6974ecc4ee684e7992::random {
    struct Random has copy, drop, store {
        seed: u64,
    }
}