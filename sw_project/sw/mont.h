/*
 * mont.h
 *
 *  Created on: Dec 6, 2019
 *      Author: r0775819
 */

#ifndef SRC_MONT_H_
#define SRC_MONT_H_

/*--------------------------------------------------------------------------------------------------------
 * Montgomery Multiplication
--------------------------------------------------------------------------------------------------------*/

//TV1

uint32_t a[32]         = { 0xa2e47eba, 0xdb5e3e7d, 0x5fd9a7cb, 0x9e7a37c3, 0x4dc37416, 0x834fe315, 0x0080dbac, 0x47280a4d, 0x722dc3dd, 0x7f0ca6f4, 0x7f0da3db, 0xfc20cbb9, 0xb749699e, 0xc5abc925, 0x8bc67669, 0x23a30d3f, 0xffe44e1c, 0xdb22d6ee, 0x5dc3d3b3, 0xfe7e980d, 0x894075d2, 0xdeabe7c4, 0x58042c3b, 0x1cc18107, 0xf0abb2e1, 0x7bd31dc0, 0x72355db9, 0xf55a0178, 0x99f5d831, 0x12ccb47a, 0x44eef089, 0x81bf5831 };
uint32_t b[32]         = { 0xe47d092a, 0xd7615ed9, 0xa8aff661, 0xc3d7bb8c, 0x2d22b31c, 0x5050b808, 0xb0bc44bb, 0x93e46f4f, 0xac0332e5, 0x81ad7f85, 0x23de9197, 0x4b35f0a2, 0x6303744a, 0x615740bf, 0x54ebbaef, 0xf36273c2, 0xaf0d1080, 0x4740c9d6, 0x458e6699, 0xaaa1040b, 0x614df162, 0xaf7fe30d, 0xac73e3ed, 0x49204145, 0x1653523c, 0x5ee4f3b1, 0x2b3f4339, 0x5b9a2426, 0x62e3ffb3, 0xf4c32df1, 0x94f2db82, 0x80deb209 };
uint32_t n[32]         = { 0xb2e52d11, 0x8f850a5f, 0x08edfb0c, 0x4f02a1ac, 0xdd070636, 0x6c59cfc8, 0x16a40db7, 0x85bba009, 0x598eba07, 0x5d0fa3cc, 0x32bc6fb5, 0x4aa27cd0, 0x0928454e, 0x027d3081, 0xd1caec35, 0xa98e4223, 0x533983de, 0x36370bb4, 0xe8b0b4c6, 0xfe3655ab, 0x27a4a51e, 0xb403c449, 0xa679cf3b, 0xc1fc4391, 0x884e5080, 0xa65d4d30, 0xcd90ed67, 0x55fcb457, 0x989d6f4c, 0x0303d70e, 0x9a09328e, 0x82260dd0 };
uint32_t n_prime[32]   = { 0xd42a0be9, 0xedf2faf4, 0x4de391f0, 0x1923b90b, 0xa3fd5a28, 0x6ea16726, 0x008f3c4d, 0x6aaa1f6e, 0x765df4a6, 0x23631436, 0xcab18820, 0x82d4cd91, 0xfd76c415, 0x56d70254, 0xb401c03f, 0x05819878, 0xee071fe3, 0x2ce9a246, 0x04229cda, 0x6998f0b5, 0x2710788b, 0x755a7771, 0xc2eb4ded, 0x0ad4bfa9, 0x86fa411e, 0xd67f5eef, 0xf2b94db6, 0x4174b007, 0x08a412dc, 0x6e349dcf, 0x796f356e, 0x1c2a9d7f };
uint32_t eres[32]      = { 0x919af36d, 0x201c5a15, 0x763debb4, 0x54b92abd, 0xc3d09af8, 0x0269454a, 0x35a42e09, 0x1149a6e6, 0x381cfa5b, 0x61b91a68, 0x7180faf5, 0x8c7536c6, 0x0368f56d, 0x0ce9c2ab, 0xd6180f19, 0x0cf8b5ac, 0x62ca69e8, 0x8789e2ec, 0x080ca2ea, 0x4dea79c7, 0xf3b4499d, 0xbae3cd24, 0x148e24af, 0x83e7cc56, 0x22548763, 0x1e0f13bf, 0xc6b26d8e, 0xfc9c092d, 0x8fa70ce2, 0xb5098439, 0x9f7d1f55, 0x50a9e0c6 };

////TV2
//uint32_t a[32]         = { 0x1f0edd56, 0x8691cebb, 0xa5afdf0f, 0x3c5599dd, 0xab3747d1, 0x8e0a4e8e, 0x34605680, 0x5ea149a1, 0x264f2c8d, 0x2b4efadf, 0x519bec3f, 0x384064e2, 0x5cc5b013, 0xc2d92389, 0x8cee7307, 0x1f21efd1, 0xe39de0c0, 0x4a51e09c, 0x247e5d6a, 0x8d179b6c, 0x14fb55d6, 0x1f024a58, 0xe514a97d, 0xe5248ea5, 0xd0a19c0f, 0x1f7e0279, 0x39608eec, 0x2f82bab5, 0x76520c4e, 0x220181cd, 0xbc9cc9c2, 0x83f56658 };
//uint32_t b[32]         = { 0xdb859839, 0x75e720f7, 0xf6b0f083, 0xcb192bc8, 0x3e8ac26f, 0x5e0e2b38, 0xb3827fd9, 0x486da9d8, 0x8a7cf84d, 0x6185f629, 0xbb3a0081, 0x8ec85c25, 0x5ebba407, 0x47222bae, 0x5216bb76, 0x182287c7, 0x914f443a, 0x8d75b5ff, 0x79512028, 0x1474a1db, 0xf4152178, 0x68f4d4f7, 0xa690cc64, 0x20038f37, 0x31a4a850, 0x4522078d, 0xe0f9dd45, 0x2f1a7026, 0xb2be48ce, 0x5b5b6579, 0xdaceff34, 0x8b0845eb };
//uint32_t n[32]         = { 0xb242b8cf, 0xcdbb4afe, 0x80136d88, 0x2e372690, 0x4b1a746a, 0xed5059f0, 0xbb35cb54, 0xc2a962f9, 0xbf18656a, 0xe36ad376, 0x4b2c6da0, 0x754cf41b, 0x4c259bfa, 0x77572d4f, 0xdb6198e9, 0x98593a80, 0x3d451d3a, 0x1c0d5195, 0x2b8e2b80, 0x196d4e0a, 0xa1a42f7a, 0x4f9d258c, 0x00d28490, 0xc52c5829, 0xeeac176c, 0xa77796f0, 0x1f956e90, 0xede77f0a, 0x5143f44a, 0x7d94fc47, 0x2e9e8b04, 0x9ef1ed65 };
//uint32_t n_prime[32]   = { 0x92e83c99, 0x212bfe8c, 0x75c37155, 0xcf4f65c9, 0x99ddad28, 0x89270b1e, 0x93fdf536, 0xfe4c050a, 0x60f5b3b6, 0x81e8c58c, 0xd08a54e5, 0x2b74ed04, 0x8d146ca0, 0x664fc6ef, 0x44f003ad, 0x5c847627, 0x514b86b1, 0xb2ba18cb, 0x31f68d6b, 0x64c4dc18, 0xcea9cea9, 0x6ded76d6, 0xb7e1a0a1, 0x7df3495f, 0x883e5346, 0xd6fc6642, 0x0c77cc91, 0xa67f3f20, 0x9614280d, 0x7297941d, 0x78c428c7, 0x40051c81 };
//uint32_t eres[32]      = { 0x185b5a, 0xfe1b80d1, 0x991f765d, 0x99604b4e, 0xf4464a2d, 0x7a59435e, 0xa0e87d9c, 0x5f976286, 0x68ef466d, 0x0bfc5e5b, 0x8817bea4, 0x006c6e49, 0xa099f646, 0xb111811d, 0x6e644dfe, 0x15a6ef9a, 0x0c639de0, 0xc863ad44, 0x7dce9c60, 0xad87b367, 0xd3fa8b74, 0x7538ae63, 0xfbf8003e, 0x330b2f4d, 0x3de2229b, 0x93135143, 0x0391504c, 0xa2aafd5f, 0x3f31f907, 0xa0520cff, 0x274c153d, 0x5f1fff33, 0x00000004 };
//
////TV3
//uint32_t a[32]         = { 0xaee66c08, 0x35233dcc, 0x2a299325, 0xd9e3d338, 0x42081c8b, 0xd57a9f22, 0xb62ef3a2, 0x2a166d34, 0x1717b18b, 0xc28518b0, 0xd1213e23, 0xcc1653c1, 0x01fdee5d, 0xcb1ec76c, 0xc64ca144, 0xd0df3f61, 0x9a92d2a5, 0x126a18ef, 0xf3e38e26, 0xa02c0ac2, 0xa3c8db54, 0x99f0c2dd, 0x1b7e7556, 0x21a39126, 0xc9f5b399, 0x90bb5146, 0x08066fca, 0x73174f16, 0xdb009cd3, 0xd473ffc8, 0x16270736, 0x82e9a839 };
//uint32_t b[32]         = { 0x855eb6f8, 0x6e9b6dff, 0xcd0636cc, 0xbf5773ea, 0xf72af8e6, 0xcbfa44fa, 0x5d58f185, 0xb35d23aa, 0xbfb8a381, 0xa7e23c00, 0x87c6781b, 0x1b1a3c5b, 0xdcc5432f, 0x7360269e, 0x2af92cef, 0xd5b62bf5, 0x9c45cf04, 0x5cfd6b26, 0xf48bb4b4, 0x9b2cb965, 0xa0579f37, 0xaef2010f, 0x955db2d8, 0xf9c705c4, 0x499c3848, 0x05408b7f, 0x0eca67a7, 0x37290375, 0x16fe438f, 0xb0ca5786, 0x26db96be, 0x84726aeb };
//uint32_t n[32]         = { 0xe8c48a51, 0x1b8dee14, 0x862f952f, 0x8f6b8168, 0x4ea4e323, 0xd35aa574, 0x87f03b6a, 0x3bd7a5a6, 0x8d9479b6, 0xfa121d94, 0x1872cf6f, 0xbd86b870, 0xf4b9ae66, 0x08e92fb5, 0x717bc726, 0x48d634f3, 0x11a967ba, 0x7c79d4b0, 0xc516ec1f, 0x891f3089, 0x15cb661e, 0x1c8b0888, 0x631ec6e3, 0xc02484c2, 0x79b4f388, 0x0d6cba7c, 0x8b63007a, 0x95544192, 0x41425a07, 0x3ae0b97e, 0xc48ce827, 0x9fa0fb98 };
//uint32_t n_prime[32]   = { 0xefa070, 0x0442cfc6, 0x1adbe44b, 0xe1c8bdbc, 0xb4f04ff8, 0xae4f8262, 0xfe11091a, 0x1a1ecbb5, 0x41ead8f5, 0x7cd791a5, 0x74f48cf1, 0x079d2ea4, 0x214ff9fe, 0xe8451ccc, 0x21f15ee0, 0x0df4ab79, 0xe989b89b, 0xb1c5aaea, 0x91545b16, 0x57018c3e, 0xbda12c4f, 0xd65980d2, 0xf5df3d9c, 0x7b342454, 0x80a07e9b, 0x876c2917, 0x4a095719, 0xeaf6f96c, 0x214925c5, 0x7723a96c, 0xddc872fc, 0xcac281af, 0x0000000e };
//uint32_t eres[32]      = { 0xc34f285c, 0x8dd72476, 0xd6dabaa4, 0x4981dbb8, 0x7692f817, 0x6c97e92a, 0x1d1102c4, 0xf2a4b1ce, 0x9769a3c0, 0xd98bd612, 0x9f4367be, 0x745954be, 0x9953945a, 0x2c32eaeb, 0x80a4d755, 0xb0567f1f, 0x274aa325, 0x4d363ded, 0x4f5e47d4, 0xede7bd3b, 0x69f860a9, 0x115c6838, 0xfbbbf48a, 0x256f0980, 0x7f834df5, 0xe3b1a38b, 0xba6d557a, 0x148e5717, 0x76259941, 0x3acc86da, 0xda543866, 0x9b20a57e };
//
//
//
////TV4
//uint32_t a[32]         = { 0xbd285bba, 0xa2744a8a, 0xd68bc63b, 0xac821e74, 0x258714d2, 0x658d27e6, 0x7cd28124, 0x4473205d, 0xb34f0055, 0x230e0ed1, 0x4c4236a4, 0xbaf99c72, 0x8d603532, 0xb4ee2643, 0xcdfe92ae, 0x64a9c538, 0x1fbcd126, 0xf009b4c7, 0x742e6328, 0x40eb8bd9, 0x3be79b74, 0x2b0fb7a4, 0x0a54cebf, 0xb8a8d9c8, 0x31607b8a, 0xc9f43c4b, 0x5fbba83a, 0xa860848c, 0xf6cd64dc, 0xebc4b812, 0xd6af9481, 0x81218cad };
//uint32_t b[32]         = { 0xf6c96be4, 0xdeee0e09, 0x441b5c89, 0xb970838b, 0x27cfe6ff, 0x0a1e5013, 0xdd9d7004, 0x89357f8c, 0x527df80a, 0x6fb1a326, 0x85c3cadf, 0xc8b8468c, 0xe488a70d, 0xa2fdcb09, 0x534ca7cd, 0xc92698b5, 0xb309131e, 0xf3f5e349, 0x7bb17039, 0x97641560, 0xbe49f556, 0xe4d5f509, 0x9b21ffed, 0x83e1d13e, 0x1422ffa9, 0x167596b9, 0xad2ee782, 0x84352d05, 0x4e1156f2, 0xa8211387, 0xeb6d511b, 0x87b979a6 };
//uint32_t n[32]         = { 0xa707ed6f, 0xab414a85, 0x7e173f5a, 0x6c24da68, 0x9f58339a, 0x6125324f, 0xb47c2fab, 0xf386716c, 0x433dafa4, 0xa43b0563, 0xbd2b360b, 0x955c9bf6, 0x1a126fbd, 0x44785779, 0xaaa76a6f, 0x89026dd0, 0x7b8e4bc9, 0xb2258247, 0x3814b83a, 0xbd621fe9, 0x73f6ecb4, 0xadc10989, 0xd06f771a, 0xf7737938, 0x726824c0, 0xd329a1c0, 0x2377c0fb, 0xef252fcf, 0x6a8bc76b, 0x98bd08cb, 0x9c8c2ec7, 0x89cf3173 };
//uint32_t n_prime[32]   = { 0x0eaf7dbe, 0x87f460b4, 0x95947bb2, 0xcf998faa, 0x097cd2d2, 0x6cff3eb5, 0xd07b2238, 0x356d0343, 0x9fe5f2af, 0x30af24e0, 0xd4d3e25e, 0x7e150a1c, 0xa5a6d871, 0x8cf6edc0, 0x7a6443ed, 0x343102ff, 0x334c9af3, 0x3178d041, 0x6778ff0c, 0x43f33e95, 0x1b0d381b, 0xafc602ba, 0xeb3cf448, 0xc356348a, 0xda1c47fc, 0xe60ec7e8, 0xed90d969, 0xd0bbf6db, 0x6b5771f6, 0xa2ae40d6, 0x52b9ce2a, 0x57e37d63 };
//uint32_t eres[32]      = { 0x7f31981b, 0x3471d222, 0x5b7a9b56, 0x2efad2e8, 0x0b687759, 0xd37bd10c, 0xde0a2652, 0x35d52522, 0xf1204282, 0x0b3d3e89, 0x82857bcb, 0x3ee5b948, 0x88ac2b6a, 0x26d60101, 0x9da5d911, 0x88d79d10, 0x22f0e701, 0x3ee840cc, 0xb943ee39, 0x0cd6232e, 0x0256c268, 0x211d50c6, 0xf89a4604, 0xa05f40a9, 0x07da0446, 0xbc249cce, 0x4b040b90, 0x069024fa, 0xaf7e46a6, 0xabc485bd, 0x9a248ff1, 0x5c152058 };
//
//
//
////TV5
//uint32_t a[32]         = { 0x032a54dd, 0x32ecc7f7, 0x4b3f65dc, 0x6289951d, 0x23b6035f, 0x692ac401, 0xc5807c38, 0x339cc8ea, 0x89d4c01d, 0x75d42ba3, 0xef87feb5, 0x49d122c9, 0x40908196, 0x3fc057f0, 0xb018b6c7, 0x5227db09, 0xe097a96d, 0xd24c9ceb, 0xb7215ef7, 0x99419929, 0x07ce3433, 0xed30cbdf, 0x732c108d, 0xac15e431, 0x49df68fa, 0x2a6fdde2, 0xa865e371, 0x34d678bb, 0x2f137471, 0x83b10d03, 0xea5058b3, 0xb47c991d };
//uint32_t b[32]         = { 0x3011afb6, 0x8c405f38, 0x21ca3907, 0x4ccd391f, 0xd19f16cf, 0x51b1b4b1, 0xfa4bbb3d, 0x547ea95d, 0xa2aadc39, 0x2d35f274, 0x34253134, 0x916b18a8, 0xcba117f3, 0x34093dae, 0x53bbfa23, 0x053dd4c3, 0xc0568e71, 0x95f49362, 0xe10256f2, 0xf4fa1481, 0xfc16ea2d, 0x8e32788e, 0x62113021, 0xda0be254, 0x44fc5df0, 0xbbc94142, 0xa3ffd8b8, 0xdd2cd21a, 0x83eb6850, 0x9a91ebda, 0x273e76a6, 0xa19c4870 };
//uint32_t n[32]         = { 0xb284365b, 0xcc99d666, 0xc1a9c7e9, 0x2d218998, 0x1357d643, 0xe97bd873, 0x72d97c8b, 0x36e026e4, 0x34b90f99, 0x1fc04b4b, 0x58e24aab, 0xab963a2e, 0xd47e4952, 0x39a26279, 0x7d03e259, 0x13073378, 0xe64016c0, 0x94a6c0da, 0x771843c2, 0x54e30935, 0x06a3ea58, 0x63d6d843, 0x3540a679, 0x4d1c85b5, 0x57fb38b8, 0xe556c8f6, 0xf5918c0c, 0x61b8a5d0, 0x69ea6b37, 0x4a128387, 0xd240b3a1, 0xbde637ba };
//uint32_t n_prime[32]   = { 0xe36fb934, 0x2a881853, 0xae3f02c0, 0xa9b968d5, 0x65389dbe, 0x276e11f3, 0xab88f29b, 0x0af3f002, 0xbecc23ba, 0x62da7311, 0x6a4a1a9c, 0x105e81e3, 0x17dbbc65, 0x001f29a2, 0x1f372ab6, 0xd568dca6, 0xf0d653f0, 0xcabea13a, 0x2528f7de, 0x5c5229a6, 0xb819cabb, 0x20fa3768, 0xadc5cbbb, 0x53a40c31, 0xdd684099, 0xd867b763, 0x9b60475b, 0x548d35c9, 0x36cc6c8c, 0x908e305d, 0xf2073395, 0x13fe6d4b };
//uint32_t eres[32]      = { 0x63a3163b, 0x326509f0, 0x3ab066ed, 0x733563a8, 0x83b58edf, 0x9c5f8351, 0x4ac30abc, 0x93e57653, 0xe430149b, 0xcba7fe28, 0x203ea727, 0xce314268, 0x6fc78ca8, 0x7eb0d335, 0x002fe058, 0x7393bcf4, 0xa9c9a347, 0x7c632e4b, 0xd37b7d21, 0x7be87cac, 0x0c3347f3, 0x612192af, 0x7c5d7c5d, 0xda22acb8, 0x7665aac7, 0x8ad13343, 0x9a11a1ee, 0x40c82bf8, 0x5491b00f, 0x03e400d5, 0x75f79aad, 0x9cf68933 };
//
//
////TV6
//uint32_t a[32]         = { 0x9017f4f8, 0x26170eb9, 0x6bea9b63, 0xa39603e4, 0xc4338abb, 0x82fc095e, 0x122561bc, 0x81b96162, 0x043b8a96, 0x568cdfa8, 0xbea182fd, 0xc77c1df7, 0x8ed6d33a, 0xc5181737, 0x1f5f7647, 0x2aa8bd1d, 0x7fa0c7da, 0x2e0f4e0a, 0xbd4c16b2, 0x3c3a05bb, 0x6bb96513, 0xc471820f, 0x30de4a50, 0xe80d954a, 0xca05eee9, 0x141c5226, 0x037c7c00, 0x4f517849, 0x9fbb5644, 0x57ecd55a, 0x19df463f, 0xc73ec882 };
//uint32_t b[32]         = { 0x303c6aea, 0x51abefd5, 0x01572e94, 0x00c59c6a, 0x1894bdaf, 0x3c9125de, 0x4f6205cf, 0xbca9e8f5, 0x21b483ef, 0xb42fa9ed, 0x528db3ba, 0xec0717e8, 0x17cf7cd3, 0xd0994365, 0x80fc9dd2, 0xb35f6c39, 0xf66bb915, 0x38c4fec6, 0xb67c8270, 0x8bfe60cf, 0xf7361881, 0x5c0d4987, 0x225bf7f6, 0xd9ccb821, 0xca21f83d, 0xe95c6c70, 0x9e325a19, 0xd3604a67, 0xe8046b97, 0xeac7ce14, 0xd89b37ba, 0x8cf4d8e8 };
//uint32_t n[32]         = { 0x48133e6d, 0x7986eb21, 0xf9e40b69, 0x630e7d8f, 0xebfe4572, 0xeddac50d, 0x4716701f, 0x28b8db03, 0xbedfb40f, 0x8583f0c3, 0x93ac5493, 0xdf5a494e, 0x1da9bb8b, 0x919bf8e5, 0x3ea5a2c5, 0x1b53a37a, 0xb28a92de, 0xd3bab7a6, 0xcfdfcd5f, 0x9bdfc1dd, 0x168921c4, 0x59f7bb56, 0xf4ddca8f, 0xd74a7bb4, 0x391c357d, 0x64134f39, 0x0bc3deef, 0x268acbba, 0x4cc431d2, 0x23f5ceb2, 0x3f2f4239, 0xe8f05c54 };
//uint32_t n_prime[32]   = { 0x8f8c117d, 0xaf9af13b, 0x0c404c44, 0x010c8604, 0xa6858a3f, 0xc9ad2ac2, 0x77302073, 0xecb3ab5e, 0x8ea7c5a1, 0xa1af44db, 0x01adc903, 0x1698934d, 0x25e3561b, 0x8b3bbaf5, 0xee172e03, 0x54ba5aaf, 0x162dc63d, 0x5c0a0f8d, 0xfba906cb, 0x7d371c11, 0x06c30f2e, 0x2ccbbe7b, 0x0b4408ef, 0x0dd0b579, 0x0c3baf70, 0xe846f724, 0x39efc3d0, 0xa210ffb4, 0x026d66f6, 0x5cecf478, 0x8d411ae6, 0x52339b2a };
//uint32_t eres[32]      = { 0x49fa96ec, 0x61944449, 0x8dda691a, 0x274b0070, 0xfa332361, 0xa48d648e, 0x91b9356f, 0x92b12dd9, 0x89646707, 0xb0a5683a, 0x2bb8154a, 0x1cf1ef70, 0x1348c945, 0x5649eaa2, 0x8e41d476, 0xa86eac84, 0x02566359, 0x24039e1a, 0x11526a96, 0x6d9dd718, 0x6bf54a9d, 0x0a29f38b, 0x9c4d616e, 0xd5f162b9, 0xdd7adbc6, 0x7d715c6d, 0xb8697686, 0x2f8f6621, 0xb56a9f71, 0xb1f83041, 0xf19e6790, 0xb8629d54 };
//
//
////TV7
//uint32_t a[32]         = { 0xe8433d75, 0xe1e2a78c, 0xb493497f, 0xc87c606d, 0xa9a31b4e, 0x0f67c218, 0x99bf61a9, 0x5a7c928d, 0x3fa70b1d, 0x8c472b4d, 0xef9c9367, 0x0a638742, 0x32820b79, 0x15a482a3, 0xc7d93be3, 0x69fe173e, 0xc4b929a0, 0x7c3d3155, 0x963e8d88, 0x60129c61, 0xd5a4f2c2, 0x37860068, 0x7f2544e2, 0x39f4ee3c, 0x49ede2bc, 0xfa10cf5c, 0xda57b1ad, 0x5f5e9229, 0x7457e533, 0x09f718de, 0xfff98a2f, 0xbfaafd9e };
//uint32_t b[32]         = { 0x91f3e125, 0x009011ad, 0xe27c04f2, 0x1c9e4d97, 0x0994b95c, 0xdb0d999e, 0x75b82c64, 0xca11ec6a, 0x532f1e6f, 0x8fb14e58, 0x8745f128, 0x6dd9a976, 0x9d848c42, 0xa026c0fe, 0xab815f72, 0x9dd866ec, 0x0f521747, 0x95290de2, 0xf87c43ba, 0x3358f22e, 0x1943317b, 0x12e9aa48, 0xee8c7f4a, 0xe312cc26, 0xba5af129, 0xd280e62e, 0xed2ec476, 0x36e6cf91, 0xc6f36d8f, 0x047c0aef, 0xff65e8df, 0x8196265f };
//uint32_t n[32]         = { 0x65a9dddd, 0x6a1e1fe2, 0x473a30d0, 0x6d5792bf, 0x0ac759c3, 0x245c3c4f, 0xc6bcce85, 0xdab82984, 0x6d78bce1, 0x4c9362f1, 0x43fe9ba1, 0x23547491, 0xf34b6c41, 0x898f6f55, 0xa890e246, 0xae787e68, 0x3c81f895, 0xe9a7bd5e, 0x6c8b61f2, 0xedad5ec3, 0xd83d6a0c, 0x635b295f, 0xd7b1323d, 0x3295bea7, 0xa2d4ecc0, 0x6aa0cfc1, 0xa706c512, 0x7828bb0a, 0xc0a93a98, 0xe9dfdd50, 0xa4563307, 0xc7198a81 };
//uint32_t n_prime[32]   = { 0xae34a3c7, 0x811c468b, 0xf5fce2d5, 0xaae48cff, 0x19f60e18, 0xe40b182f, 0x095a2f45, 0x5702f372, 0x8c0a000f, 0xa54e9066, 0x7db1bf65, 0x92a9c2af, 0x908c8b38, 0xc41225eb, 0x61ff1c67, 0x37591cc9, 0xef8b3d97, 0x676dfd63, 0x4ed460ac, 0xc75d98cb, 0x91d2a67a, 0x3b9bde39, 0x8a029816, 0x9b8f2159, 0xc7eb5183, 0xf379c0b0, 0x334bec08, 0xc93f118b, 0x3b58ad6b, 0xb2dc1bdf, 0x4d08f9f4, 0xaffac65e };
//uint32_t eres[32]      = { 0xa5db77df, 0x1a3fab7e, 0xdcc89788, 0x382b1756, 0xaad906b3, 0xdfa9f51c, 0x04dc5313, 0xb8e2a6b8, 0x003d24fa, 0x21f6c3b1, 0x53bb06ff, 0x6eee97e0, 0xb9043d5d, 0xab412d9f, 0x02c5614c, 0xa9a54f79, 0x6a3bf8fe, 0x754b99b5, 0xc8055fea, 0xca52f05e, 0xcea757e2, 0x353b96a0, 0x74e84e02, 0x140578a7, 0x9f35eca8, 0x671d7a79, 0x8b60ad85, 0xb9a2a3f2, 0x3b8d4258, 0xfc37d37a, 0x57c01e4b, 0xb6f4570f };
//
//
////TV8
//uint32_t a[32]         = { 0xc7b455d4, 0x3585f67e, 0x5bff8cdd, 0xa88f10c3, 0xcc5890ef, 0x65ac981d, 0x0a4181e5, 0x999715e2, 0x36326710, 0xbe5c361a, 0xa60cb50e, 0xed0bc34a, 0x33a3f97e, 0x2a6d3637, 0x2bc6ddbb, 0x9f84240d, 0xb2ffe42a, 0x5d54eeb6, 0xfaea3741, 0x4c284b79, 0x34ae3d96, 0x42994525, 0x548690b5, 0x0381db9a, 0xbe903280, 0x014db028, 0x25a01589, 0x9cd76fb9, 0xbb8d65bb, 0x297a2a76, 0x4cbf5e57, 0xa9c528b5 };
//uint32_t b[32]         = { 0xf14e6d65, 0xe5766b20, 0xa1562396, 0xad25b7e6, 0x443ef52b, 0x5242e9d0, 0x18629f57, 0xfdccfb4c, 0x1a3deafe, 0x00473873, 0xbc20b263, 0x74101f4c, 0x6a4cc553, 0x1bb673b6, 0x189555be, 0xc28d6d6a, 0x829ad4a0, 0x0e5b59ca, 0xcc60fe06, 0x6cab260d, 0xa218a732, 0xe6f587e9, 0x53a6d09e, 0xaea40c52, 0x9e53b7c0, 0xffa7a76f, 0xd4da3fa1, 0xc76fd8fc, 0x5807fc87, 0x631483b5, 0x748b3f0b, 0x96a08bab };
//uint32_t n[32]         = { 0xab36ac1f, 0x4d369111, 0x385e7094, 0xd59190cb, 0xb483919c, 0x9363c043, 0x5d6a53bb, 0x94ebcd98, 0x5b5ff8ee, 0x87b95729, 0x0dcffbd8, 0xdeec3b89, 0xabc97e72, 0x71330962, 0xcaca0718, 0x50b862ae, 0xc74dec46, 0x049807bb, 0xb0edd307, 0x04c6b024, 0x12226c40, 0xbd13d36c, 0xb6ac53c5, 0xe47d2087, 0x72bc420f, 0x1b7f2157, 0xc6c8d0b6, 0xc23be871, 0xbc174e87, 0xae10d372, 0xf1e5a47f, 0xaa810db7 };
//uint32_t n_prime[32]   = { 0x5b8c66bc, 0xd4ca1d8d, 0x29a3cd69, 0xacd5825a, 0xfca5ea93, 0x4185f2e3, 0x7b2e1643, 0x79812a33, 0xe2b8294d, 0xb4466d4b, 0xda34ed0b, 0x021142ac, 0xb2ee30b8, 0xb2e8817b, 0xb8207163, 0xe90ba7e6, 0xbd2cbb07, 0x289f1287, 0x38849cee, 0xecd57b53, 0xb45fdc38, 0x5221a110, 0x8f7903c4, 0xa4daf512, 0x64709d68, 0xb35cdde5, 0xe731712c, 0x79e16098, 0x61dcbf03, 0x1bc2a243, 0x04e85072, 0x3b046c80 };
//uint32_t eres[32]      = { 0x6a2165ef, 0x9854a3a7, 0x60d8609f, 0xc309e162, 0x86dd88a0, 0xdf05a668, 0x334ce711, 0xd29c5810, 0xcf1e7bcd, 0xc6b95b59, 0xbab99461, 0xe8f17ae4, 0xd395bed5, 0xefb5bd6b, 0x8b08973a, 0x914f9b5f, 0x778cc89f, 0x3497bf96, 0xf17cd9ce, 0xd2001ac0, 0xba5fd4fe, 0x77fdbd7f, 0x2e660c8b, 0x7facfe9c, 0xeaf6bd85, 0xfa9ce989, 0x2f98a216, 0x4cd903d9, 0x5c6800c8, 0xe212827b, 0x41313af2, 0x5b494ecd };
//
//
////TV9
//uint32_t a[32]         = { 0x6ba4c5dc, 0xb32b690b, 0xe737b411, 0x03d427b7, 0xc2899e8c, 0x3373b168, 0x56d902ae, 0xa84938b1, 0xfd9179b9, 0x4d76390e, 0xd94f1c35, 0x94cff678, 0xb7bc1f4a, 0xc314fce4, 0xaabd2716, 0x4c74c4a1, 0x39494448, 0x09727bd7, 0x758c7f06, 0x137b087d, 0xcdb53822, 0x68d9dda8, 0xba99d6b8, 0x6955a0a3, 0xaad445a1, 0x78f71975, 0x332d100e, 0xd5cd16cd, 0x81e132a6, 0x404a698d, 0x5d01ff6f, 0x9f6c5be9 };
//uint32_t b[32]         = { 0x502ec400, 0x126ce301, 0xf8b2a1f2, 0x0f636353, 0x7448a6c5, 0x4282616d, 0x02068d2f, 0x7db05f3f, 0x20ff84c9, 0x17610cd0, 0x6ba1c7fe, 0x0e0b1358, 0x9b1eb909, 0xe4a4eb27, 0x13b4f838, 0x27b38770, 0x235617a0, 0xe7af8d99, 0xea9fca66, 0x5a06b565, 0x0a1a6230, 0x44dd6513, 0x9a9e7a05, 0xe8c6bb03, 0x7558abc4, 0x5e400f57, 0xba4212a6, 0xc4c2aed3, 0x98b530c9, 0xeac8c748, 0xdcdf8689, 0x83d3c518 };
//uint32_t n[32]         = { 0xfb675c9d, 0xba466e4e, 0x1d97a7a7, 0x8862ae25, 0xc43ec237, 0x701ed04d, 0x1bb9faa2, 0x7c5b90f6, 0xe2c0da2d, 0x916c782e, 0xeb4dc050, 0x0879a0fa, 0x4b56c9f0, 0x309e826c, 0xd14a3bf2, 0x3b3a3559, 0xaf8efd45, 0x67a1c000, 0xc7e0f667, 0x206032bc, 0x21504250, 0x0bfc9db0, 0x6a749a0b, 0x9165c43a, 0x1825c52a, 0x3035dec1, 0xb8ad003a, 0x1b61c7e3, 0x3a36fff6, 0x617ebc19, 0x54e2a7cf, 0xbadb599d };
//uint32_t n_prime[32]   = { 0xf4ec0e4d, 0x86b2989f, 0xa7e8ed26, 0x3c9feeb8, 0xab8f6d32, 0x416ab443, 0xb31e8586, 0x912c96aa, 0xf3e7696c, 0xd9b8e555, 0xc97058e5, 0xbe2b014b, 0x4353fb8a, 0x10bb3133, 0x864343f3, 0x502cb243, 0x850e651d, 0x06cb17bd, 0x8842a85f, 0x94191808, 0xed057a84, 0x77394ac8, 0x76197274, 0xb6d25bb9, 0xad5bc355, 0xcc561186, 0xc5b0f0d4, 0xed827fb1, 0x1e4900f7, 0x4e0597cc, 0x7cfe5745, 0x947698c9 };
//uint32_t eres[32]      = { 0x03141bd6, 0xfda20d9e, 0x640c8110, 0x935875a0, 0x466f71d5, 0x7ce58f5a, 0x387eb0e5, 0xed53e6ed, 0x31a0fb81, 0x8c18b7b3, 0x2f3a84b5, 0xad48997e, 0x4af1b243, 0x27546e52, 0xfd291049, 0xad53c3d8, 0x450d75b3, 0xd88bd979, 0x2b85e27a, 0xf225a459, 0xe3769c0c, 0x8f7e7bb3, 0xa1986dae, 0x35d29832, 0xbb4d810a, 0xb7664cb4, 0xa724f6bc, 0x1e1393c1, 0xe35a0a24, 0x3f9ce72a, 0x1123be00, 0x6543763d };
//
////TV10
//uint32_t a[32]         = { 0xb45b2ad8, 0xf752263a, 0x8e62937e, 0x43504788, 0x486c29dc, 0x3caee68e, 0x389dc0b5, 0x0844d808, 0x5c879ca7, 0xeb34b63b, 0x4e86661d, 0x5a4e116f, 0x13a3e5b8, 0x622c604b, 0x252c0232, 0x19ba9529, 0xe390376f, 0x33cdcd36, 0x692203aa, 0xe533be49, 0xad043c6c, 0xa7def123, 0x3ed5d1cd, 0x39228c2f, 0x82dfb2e2, 0x0b973131, 0xd13c68db, 0xe9e221a1, 0xc5df1b21, 0x30fc22d1, 0x025d3b21, 0x8bcd3ddc };
//uint32_t b[32]         = { 0xc4a9b629, 0xda6de133, 0x0cc2519f, 0x556c537d, 0xb56b1ec9, 0xcddbc0da, 0xa299e72e, 0x1fd9889d, 0x50807c78, 0x8e47b172, 0xbc66e9ab, 0xe423eab2, 0xda9f39ab, 0xb851e923, 0x92ff8cec, 0x916b8b5d, 0x11aa8910, 0x4614da35, 0x0aa35e49, 0x25d641f7, 0x72a60e72, 0x54444f9f, 0x5f1ff3bb, 0xa70bb1a0, 0xf15eb197, 0xaf36f50e, 0x2d7194aa, 0xda742827, 0x3ff3e026, 0xf1dbf6d0, 0xb27a128c, 0x94fd8fef };
//uint32_t n[32]         = { 0x086122ef, 0x8d8028c3, 0x5c694629, 0x9f2939eb, 0x0f8ca6cc, 0xecb4d422, 0x53e4af26, 0xa5895ef4, 0xffdb6775, 0xae264c9a, 0x3b9a42ad, 0xefc1bddb, 0xbc973e66, 0xb90c20d1, 0x3ee87825, 0x71fba2a2, 0xb23dc8d2, 0xb9dbfa6d, 0x85550333, 0xcfe2c01f, 0xdbb4a8d2, 0xdcf49e26, 0x84d016dc, 0x17ad77f7, 0x7aee0e9a, 0xb4b24849, 0x6cc81a40, 0x7905bad8, 0x1a7e29d5, 0xf38a8c35, 0x22c549de, 0x9b5d0c61 };
//uint32_t n_prime[32]   = { 0x1c8dda, 0x5f0b1441, 0x62d9bfb5, 0x14957d79, 0x239fb29a, 0x0c0338cb, 0xa1a2549e, 0xb2d606c4, 0x24ebe61e, 0xd8214281, 0x3d98b5b0, 0x1591b0d6, 0xd4beb88d, 0x64ca8e6c, 0x142e8393, 0xc79fa53d, 0x58071954, 0xf80da5b5, 0x3f18f792, 0x9c318ab9, 0x1aad97e2, 0x9ea6754b, 0x0097d183, 0x3414078c, 0x905cc61d, 0x5be6fc4f, 0x430ddcbf, 0x772af80c, 0x0a01bc19, 0xf47e36af, 0x09d84e12, 0x0f74dc44, 0x00000009 };
//uint32_t eres[32]      = { 0x34aa4512, 0x4c2a8464, 0xe9bd215e, 0xe58526f5, 0x8491f182, 0x8a75fae7, 0x86f224dc, 0xc82632c3, 0x4dd1fa28, 0xe9cec3f0, 0xd120d1a9, 0xe4c60d6b, 0x03ac5bbe, 0x40625f42, 0x628139e6, 0xa3bf3ef1, 0x8021fd2d, 0x4ac8ecef, 0x9c7cc9e4, 0xa4ddfb4b, 0x785dc694, 0xa547bc97, 0xf86b0e78, 0x8d5795cc, 0xdea6c7ff, 0x3e486e4c, 0xe3effde8, 0xb986c607, 0x6f678bef, 0x075ba1d3, 0xecfeaa72, 0x603d69ae };


#endif /* SRC_MONT_H_ */