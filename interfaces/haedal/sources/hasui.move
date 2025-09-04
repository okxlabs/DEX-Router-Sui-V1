module 0xbde4ba4c2e274a60ce15c1cfff9e5c42e41654ac8b6d906a57efa4bd3c29f47d::hasui {
    struct HASUI has drop {
        dummy_field: bool,
    }
    
    fun init(arg0: HASUI, arg1: &mut 0x2::tx_context::TxContext) {
        abort 0
    }
    
    // decompiled from Move bytecode v6
}

