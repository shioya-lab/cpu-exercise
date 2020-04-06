
// データ幅は16bit
`define DATA_WIDTH 16

// データパス
`define DataPath logic [ `DATA_WIDTH-1:0 ]


// レジスタ番号を表すために必要なビット数
// 3: 2^3 で 8 個のレジスタを表す
`define REG_NUM_WIDTH 3

// レジスタ・ファイルのサイズ
// 上に合わせて8個に
`define REG_FILE_SIZE 8

// レジスタ番号
`define RegNumPath logic [ `REG_NUM_WIDTH-1:0 ]

