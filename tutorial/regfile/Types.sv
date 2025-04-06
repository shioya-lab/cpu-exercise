
package Types;

// データ幅は16bit
parameter DATA_WIDTH = 16;

// データパス
typedef logic [ DATA_WIDTH-1:0 ] DataPath;


// レジスタ番号を表すために必要なビット数
// 3: 2^3 で 8 個のレジスタを表す
parameter REG_NUM_WIDTH = 3;

// レジスタ・ファイルのサイズ
// 上に合わせて8個に
parameter REG_FILE_SIZE = 1 << REG_NUM_WIDTH;

// レジスタ番号
typedef logic [ REG_NUM_WIDTH-1:0 ] RegNumPath;

endpackage
