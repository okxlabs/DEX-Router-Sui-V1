module flowx_clmm::versioned {
    use sui::object::{Self, UID};

    struct Versioned has key, store {
        id: UID,
        version: u64
    }
}