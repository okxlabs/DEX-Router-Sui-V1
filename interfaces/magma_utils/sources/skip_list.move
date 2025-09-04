module 0x682eaba7450909645bf949db3fc5881432a00b49b4c06d6974ecc4ee684e7992::skip_list {
    struct SkipList<phantom T0: store> has store, key {
        id: 0x2::object::UID,
        head: vector<0x682eaba7450909645bf949db3fc5881432a00b49b4c06d6974ecc4ee684e7992::option_u64::OptionU64>,
        tail: 0x682eaba7450909645bf949db3fc5881432a00b49b4c06d6974ecc4ee684e7992::option_u64::OptionU64,
        level: u64,
        max_level: u64,
        list_p: u64,
        size: u64,
        random: 0x682eaba7450909645bf949db3fc5881432a00b49b4c06d6974ecc4ee684e7992::random::Random,
    }
}