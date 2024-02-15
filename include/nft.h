pragma ton-solidity >= 0.72.0;

import "tip6.h";
import 'Index.sol';

struct CallbackParams {
    uint128 value;      // ever value will send to address
    TvmCell payload;    // custom payload will proxying to address
}

interface ITIP4_1NFT {
    event NftCreated(uint256 id, address owner, address manager, address collection);
    event OwnerChanged(address oldOwner, address newOwner);
    event ManagerChanged(address oldManager, address newManager);
    event NftBurned(uint256 id, address owner, address manager, address collection);
    function getInfo() external view responsible returns(uint256 id, address owner, address manager,  address collection);
    function changeOwner(address newOwner, address sendGasTo, mapping(address => CallbackParams) callbacks) external;
    function changeManager(address newManager, address sendGasTo, mapping(address => CallbackParams)  callbacks) external;
    function transfer(address to, address sendGasTo, mapping(address => CallbackParams) callbacks) external;
}

interface ITIP4_2JSON_Metadata {
    function getJson() external view responsible returns (string json);
}

interface ITIP4_3NFT {
    function indexCode() external view responsible returns (TvmCell code);
    function indexCodeHash() external view responsible returns (uint256 hash);
    function resolveIndex(address collection, address owner) external view responsible returns (address index);
}

interface INftChangeManager {
    function onNftChangeManager(uint256 id, address owner, address oldManager, address newManager, address collection, address sendGasTo, TvmCell payload) external;
}
interface INftChangeOwner {
    function onNftChangeOwner(uint256 id, address manager, address oldOwner, address newOwner, address collection, address sendGasTo, TvmCell payload) external;
}
interface INftTransfer {
    function onNftTransfer(uint256 id, address oldOwner, address newOwner, address oldManager, address newManager, address collection, address gasReceiver, TvmCell payload) external;
}

contract TIP4_1Nft is ITIP4_1NFT, TIP6 {
    uint8 constant value_is_empty = 101;
    uint8 constant sender_is_not_collection = 102;
    uint8 constant sender_is_not_manager = 103;
    uint8 constant value_is_less_than_required = 104;

    uint256 static _id;
    address _collection;
    address _owner;
    address _manager;
    constructor(address owner,address sendGasTo,uint128 remainOnNft) {
        optional(TvmCell) optSalt = tvm.codeSalt(tvm.code());
        require(optSalt.hasValue(), value_is_empty);
        (address collection) = optSalt.get().toSlice().load(address);
        require(msg.sender == collection, sender_is_not_collection);
        require(remainOnNft != 0, value_is_empty);
        require(msg.value > remainOnNft, value_is_less_than_required);
        tvm.rawReserve(remainOnNft, 0);
        _collection = collection;
        _owner = owner;
        _manager = owner;
        _supportedInterfaces[ bytes4(tvm.functionId(ITIP6.supportsInterface)) ] = true;
        _supportedInterfaces[bytes4(tvm.functionId(ITIP4_1NFT.getInfo)) ^ bytes4(tvm.functionId(ITIP4_1NFT.changeOwner)) ^ bytes4(tvm.functionId(ITIP4_1NFT.changeManager)) ^  bytes4(tvm.functionId(ITIP4_1NFT.transfer)) ] = true;
        emit NftCreated(_id, _owner, _manager, _collection);
        sendGasTo.transfer({value: 0, flag: 128 + 2});
    }

    function transfer(address to, address sendGasTo, mapping(address => CallbackParams) callbacks) public virtual override onlyManager {
        tvm.rawReserve(0, 4);
        _beforeTransfer(to, sendGasTo, callbacks);
        address oldOwner = _owner;
        _changeOwner(to);
        _changeManager(to);
        _afterTransfer(to, sendGasTo, callbacks);
        for ((address dest, CallbackParams p) : callbacks)
            INftTransfer(dest).onNftTransfer{value: p.value, flag: 0 + 1,bounce: false}(_id, oldOwner, to, _manager, to, _collection, sendGasTo, p.payload);
        if (sendGasTo.value != 0)
            sendGasTo.transfer({value: 0,flag: 128 + 2,bounce: false});
    }

    function changeOwner(address newOwner, address sendGasTo, mapping(address => CallbackParams) callbacks) public virtual override onlyManager {
        tvm.rawReserve(0, 4);
        _beforeChangeOwner(_owner, newOwner, sendGasTo, callbacks);
        address oldOwner = _owner;
        _changeOwner(newOwner);
        _afterChangeOwner(oldOwner, newOwner, sendGasTo, callbacks);
        for ((address dest, CallbackParams p) : callbacks)
            INftChangeOwner(dest).onNftChangeOwner{value: p.value,flag: 0 + 1,bounce: false}(_id, _manager, oldOwner, newOwner, _collection, sendGasTo, p.payload);
        if (sendGasTo.value != 0)
            sendGasTo.transfer({value: 0,flag: 128 + 2,bounce: false});
    }

    function _changeOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        if (oldOwner != newOwner)
            emit OwnerChanged(oldOwner, newOwner);
    }


    function changeManager(address newManager, address sendGasTo, mapping(address => CallbackParams) callbacks) external virtual override onlyManager {
        tvm.rawReserve(0, 4);
        _beforeChangeManager(_manager, newManager, sendGasTo, callbacks);
        address oldManager = _manager;
        _changeManager(newManager);
        _afterChangeManager(oldManager, newManager, sendGasTo, callbacks);
        for ((address dest, CallbackParams p) : callbacks)
            INftChangeManager(dest).onNftChangeManager{value: p.value,flag: 0 + 1,bounce: true}(_id, _owner, oldManager, newManager, _collection, sendGasTo, p.payload);
        if (sendGasTo.value != 0)
            sendGasTo.transfer({value: 0,flag: 128 + 2,bounce: false});
    }

    function _changeManager(address newManager) internal {
        address oldManager = _manager;
        _manager = newManager;
        if (oldManager != newManager)
            emit ManagerChanged(oldManager, newManager);
    }

    function getInfo() external view virtual override responsible returns(uint256 id, address owner, address manager, address collection){
        return {value: 0, flag: 64, bounce: false} (_id,_owner,_manager,_collection);
    }

    function _beforeTransfer(address to, address sendGasTo, mapping(address => CallbackParams) callbacks) internal virtual {
        to; sendGasTo; callbacks; //disable warnings
    }

    function _afterTransfer(address to, address sendGasTo, mapping(address => CallbackParams) callbacks) internal virtual {
        to; sendGasTo; callbacks; //disable warnings
    }

    function _beforeChangeOwner(address oldOwner, address newOwner,address sendGasTo, mapping(address => CallbackParams) callbacks) internal virtual {
        oldOwner; newOwner; sendGasTo; callbacks; //disable warnings
    }

    function _afterChangeOwner(address oldOwner, address newOwner,address sendGasTo, mapping(address => CallbackParams) callbacks) internal virtual {
        oldOwner; newOwner; sendGasTo; callbacks; //disable warnings
    }

    function _beforeChangeManager(address oldManager, address newManager,address sendGasTo, mapping(address => CallbackParams) callbacks) internal virtual {
        oldManager; newManager; sendGasTo; callbacks; //disable warnings
    }

    function _afterChangeManager(address oldManager, address newManager,address sendGasTo, mapping(address => CallbackParams) callbacks) internal virtual {
        oldManager; newManager; sendGasTo; callbacks; //disable warnings
    }

    modifier onlyManager virtual {
        require(msg.sender == _manager, sender_is_not_manager);
        _;
    }

    onBounce(TvmSlice body) external virtual {
        tvm.rawReserve(0, 4);
        uint32 functionId = body.load(uint32);
        if (functionId == tvm.functionId(INftChangeManager.onNftChangeManager)) {
            if (msg.sender == _manager)
                _manager = _owner;
            _owner.transfer({value: 0, flag: 128});
        }
    }
}

abstract contract TIP4_2Nft is TIP4_1Nft, ITIP4_2JSON_Metadata {
    string _json;
    constructor(string json) {
        _json = json;
        _supportedInterfaces[bytes4(tvm.functionId(ITIP4_2JSON_Metadata.getJson))] = true;
    }
    function getJson() external virtual view override responsible returns (string json) {
        return {value: 0, flag: 64, bounce: false} (_json);
    }
}

abstract contract TIP4_3Nft is TIP4_1Nft, ITIP4_3NFT {
    uint128 _indexDeployValue;
    uint128 _indexDestroyValue;
    TvmCell _codeIndex;
    constructor(uint128 indexDeployValue,uint128 indexDestroyValue,TvmCell codeIndex) {
        _indexDeployValue = indexDeployValue;
        _indexDestroyValue = indexDestroyValue;
        _codeIndex = codeIndex;
        _supportedInterfaces[bytes4(tvm.functionId(ITIP4_3NFT.indexCode)) ^bytes4(tvm.functionId(ITIP4_3NFT.indexCodeHash)) ^bytes4(tvm.functionId(ITIP4_3NFT.resolveIndex)) ] = true;
        _deployIndex();
    }

    function _beforeTransfer(address to, address sendGasTo, mapping(address => CallbackParams) callbacks) internal virtual override {
        to;callbacks;
        _destructIndex(sendGasTo);
    }

    function _afterTransfer(address to, address sendGasTo, mapping(address => CallbackParams) callbacks) internal virtual override {
        to;
        sendGasTo;callbacks;
        _deployIndex();
    }

    function _beforeChangeOwner(address oldOwner, address newOwner,address sendGasTo, mapping(address => CallbackParams) callbacks) internal virtual override {
        oldOwner;newOwner;callbacks;
        _destructIndex(sendGasTo);
    }

    function _afterChangeOwner(address oldOwner, address newOwner,address sendGasTo, mapping(address => CallbackParams) callbacks) internal virtual override {
        oldOwner; newOwner; sendGasTo;callbacks;
        _deployIndex();
    }

    function _deployIndex() internal virtual view {
        TvmCell codeIndexOwner = _buildIndexCode(address(0), _owner);
        TvmCell stateIndexOwner = _buildIndexState(codeIndexOwner, address(this));
        new Index{stateInit: stateIndexOwner, value: _indexDeployValue}(_collection);

        TvmCell codeIndexOwnerRoot = _buildIndexCode(_collection, _owner);
        TvmCell stateIndexOwnerRoot = _buildIndexState(codeIndexOwnerRoot, address(this));
        new Index{stateInit: stateIndexOwnerRoot, value: _indexDeployValue}(_collection);
    }

    function _destructIndex(address sendGasTo) internal virtual view {
        address oldIndexOwner = resolveIndex(address(0), _owner);
        IIndex(oldIndexOwner).destruct{value: _indexDestroyValue}(sendGasTo);
        address oldIndexOwnerRoot = resolveIndex(_collection, _owner);
        IIndex(oldIndexOwnerRoot).destruct{value: _indexDestroyValue}(sendGasTo);
    }

    function indexCode() external view override responsible returns (TvmCell code) {
        return {value: 0, flag: 64, bounce: false} (_codeIndex);
    }

    function indexCodeHash() public view override responsible returns (uint256 hash) {
        return {value: 0, flag: 64, bounce: false} tvm.hash(_codeIndex);
    }

    function resolveIndex(address collection, address owner) public view override responsible returns (address index) {
        TvmCell code = _buildIndexCode(collection, owner);
        TvmCell state = _buildIndexState(code, address(this));
        uint256 hashState = tvm.hash(state);
        index = address.makeAddrStd(address(this).wid, hashState);
        return {value: 0, flag: 64, bounce: false} index;
    }

    function _buildIndexCode(address collection,address owner) internal virtual view returns (TvmCell) {
        TvmBuilder salt;
        salt.store("nft");
        salt.store(collection);
        salt.store(owner);
        return tvm.setCodeSalt(_codeIndex, salt.toCell());
    }

    function _buildIndexState(TvmCell code,address nft) internal virtual pure returns (TvmCell) {
        return tvm.buildStateInit({contr: Index,varInit: {_nft: nft},code: code});
    }
}
