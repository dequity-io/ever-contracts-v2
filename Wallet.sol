pragma ton-solidity >= 0.72.0;

contract Wallet {

    uint16 constant BULK_WORKER          = 1;
    uint16 constant BULK_WORKER_ROOT     = 2;
    uint16 constant DISTRIBUTIONS_WALLET = 3;
    uint16 constant INDEX                = 4;
    uint16 constant INDEX_BASIS          = 5;
    uint16 constant PROPERTY             = 6;
    uint16 constant PROPERTY_ROOT        = 7;
    uint16 constant TOKEN_ROOT           = 8;
    uint16 constant TOKEN_WALLET         = 9;
    uint16 constant UNIT                 = 10;
    uint16 constant UNIT_ROOT            = 11;
    uint16 constant UNIT_SELL            = 12;
    uint16 constant UNIT_SELL_ROOT       = 13;
    uint16 constant USER_PROFILE         = 14;
    uint16 constant USER_PROFILE_ROOT    = 15;
    uint16 constant WALLET               = 16;
    uint16 constant CODE_START = 256;
    uint16 constant ADDR_START = 512;

    mapping (uint32 => TvmCell) _ram;
    uint256 owner;
    uint static  _randomNonce;

    function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload) external pure {
        tvm.accept();
        dest.transfer(value, bounce, flags, payload);
    }

    function send(address dest, uint32 value, TvmCell payload) external pure {
        tvm.accept();
        dest.transfer(uint128(value) * 1e8, true, 0, payload);
    }

    function uc(TvmCell c) external {
        tvm.accept();
        tvm.commit();
        tvm.setcode(c);
        tvm.setCurrentCode(c);
    }
    modifier accept {
        tvm.accept();
        _;
    }
    function st(uint32 a, TvmCell c) external accept {
        _ram[a] = c;
    }
    function ld(uint32 a) external view returns (TvmCell c) {
        c = _ram[a];
    }
    function setOwner(uint n) external accept {
        owner = n;
    }
    function setNonce(uint n) external accept {
        _randomNonce = n;
    }
}
