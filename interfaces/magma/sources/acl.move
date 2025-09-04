module 0x4a35d3dfef55ed3631b7158544c6322a23bc434fe4fca1234cb680ce0505f82d::acl {
    struct ACL has store {
        permissions: 0x682eaba7450909645bf949db3fc5881432a00b49b4c06d6974ecc4ee684e7992::linked_table::LinkedTable<address, u128>,
    }
}