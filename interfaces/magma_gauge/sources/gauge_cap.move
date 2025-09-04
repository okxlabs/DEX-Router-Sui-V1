module 0x2de81c0f5cc2aa176da9f093834efbf846d581afa46516bf4952b6efd3a44992::gauge_cap {
    struct GAUGE_CAP has drop {
        dummy_field: bool,
    }

    struct CreateCap has store, key {
        id: 0x2::object::UID,
    }

    struct GaugeCap has store, key {
        id: 0x2::object::UID,
        gauge_id: 0x2::object::ID,
        pool_id: 0x2::object::ID,
    }

}

