module 0x682eaba7450909645bf949db3fc5881432a00b49b4c06d6974ecc4ee684e7992::linked_table {
    struct LinkedTable<T0: copy + drop + store, phantom T1: store> has store, key {
        id: 0x2::object::UID,
        head: 0x1::option::Option<T0>,
        tail: 0x1::option::Option<T0>,
        size: u64,
    }
}