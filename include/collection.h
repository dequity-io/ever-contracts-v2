pragma ton-solidity >= 0.72.0;

import "nft.h";
import "IndexBasis.sol";

interface ITIP4_1Collection {
    event NftCreated(uint256 id, address nft, address owner, address manager, address creator);
    event NftBurned(uint256 id, address nft, address owner, address manager);
    function totalSupply() external view responsible returns (uint128 count);
    function nftCode() external view responsible returns (TvmCell code);
    function nftCodeHash() external view responsible returns (uint256 codeHash);
    function nftAddress(uint256 id) external view responsible returns (address nft);
}

interface ITIP4_3Collection {
    function indexBasisCode() external view responsible returns (TvmCell code);
    function indexBasisCodeHash() external view responsible returns (uint256 hash);
    function indexCode() external view responsible returns (TvmCell code);
    function indexCodeHash() external view responsible returns (uint256 hash);
    function resolveIndexBasis() external view responsible returns (address indexBasis);
}

contract TIP4_1Collection is ITIP4_1Collection, TIP6 {
    TvmCell _codeNft;
    uint128 _totalSupply;

    constructor(TvmCell codeNft) {
        tvm.accept();
        _codeNft = codeNft;
        _supportedInterfaces[ bytes4(tvm.functionId(ITIP6.supportsInterface)) ] = true;
        _supportedInterfaces[ bytes4(tvm.functionId(ITIP4_1Collection.totalSupply)) ^ bytes4(tvm.functionId(ITIP4_1Collection.nftCode)) ^ bytes4(tvm.functionId(ITIP4_1Collection.nftCodeHash)) ^ bytes4(tvm.functionId(ITIP4_1Collection.nftAddress))] = true;
    }

    function totalSupply() external view virtual override responsible returns (uint128 count) {
        return {value: 0, flag: 64, bounce: false} (_totalSupply);
    }

    function nftCode() external view virtual override responsible returns (TvmCell code) {
        return {value: 0, flag: 64, bounce: false} (_buildNftCode(address(this)));
    }

    function nftCodeHash() external view virtual override responsible returns (uint256 codeHash) {
        return {value: 0, flag: 64, bounce: false} (tvm.hash(_buildNftCode(address(this))));
    }

    function nftAddress(uint256 id) external view virtual override responsible returns (address nft) {
        return {value: 0, flag: 64, bounce: false} (_resolveNft(id));
    }

    function _resolveNft(uint256 id) internal virtual view returns (address nft) {
        TvmCell code = _buildNftCode(address(this));
        TvmCell state = _buildNftState(code, id);
        uint256 hashState = tvm.hash(state);
        nft = address.makeAddrStd(address(this).wid, hashState);
    }

    function _buildNftCode(address collection) internal virtual view returns (TvmCell) {
        TvmBuilder salt;
        salt.store(collection);
        return tvm.setCodeSalt(_codeNft, salt.toCell());
    }

    function _buildNftState(TvmCell code, uint256 id) internal virtual pure returns (TvmCell) {
        return tvm.buildStateInit({contr: TIP4_1Nft, varInit: {_id: id}, code: code});
    }

    function _isOwner() internal virtual returns (bool) {
        return true;
    }

}

abstract contract TIP4_2Collection is TIP4_1Collection, ITIP4_2JSON_Metadata {
    string _json;
    constructor(string json) {
        tvm.accept();
        _json = json;
        _supportedInterfaces[bytes4(tvm.functionId(ITIP4_2JSON_Metadata.getJson))] = true;
    }

    function getJson() external virtual view override responsible returns (string json) {
        return {value: 0, flag: 64, bounce: false} (_json);
    }

     function _buildNftState(TvmCell code,uint256 id) internal virtual override pure returns (TvmCell) {
        return tvm.buildStateInit({contr: TIP4_2Nft,varInit: {_id: id},code: code});
    }

}

abstract contract TIP4_3Collection is TIP4_1Collection, ITIP4_3Collection {
    uint8 constant value_is_empty = 103;
    TvmCell _codeIndex;
    TvmCell _codeIndexBasis;
    uint128 _indexDeployValue = 0.15 ton;
    uint128 _indexDestroyValue = 0.1 ton;
    uint128 _deployIndexBasisValue = 0.15 ton;

    constructor(TvmCell codeIndex,TvmCell codeIndexBasis) {
        TvmCell empty;
        require(codeIndex != empty, value_is_empty);
        tvm.accept();
        _codeIndex = codeIndex;
        _codeIndexBasis = codeIndexBasis;
        _supportedInterfaces[bytes4(tvm.functionId(ITIP4_3Collection.indexBasisCode)) ^bytes4(tvm.functionId(ITIP4_3Collection.indexBasisCodeHash)) ^bytes4(tvm.functionId(ITIP4_3Collection.indexCode)) ^bytes4(tvm.functionId(ITIP4_3Collection.indexCodeHash)) ^bytes4(tvm.functionId(ITIP4_3Collection.resolveIndexBasis))] = true;
        _deployIndexBasis();
    }

    function _deployIndexBasis() internal virtual {
        TvmCell empty;
        require(_codeIndexBasis != empty, value_is_empty);
        require(address(this).balance > _deployIndexBasisValue);
        TvmCell code = _buildIndexBasisCode();
        TvmCell state = _buildIndexBasisState(code, address(this));
        address indexBasis = new IndexBasis{stateInit: state, value: _deployIndexBasisValue}();
        indexBasis;
    }

    function indexBasisCode() external view override responsible returns (TvmCell code) {
        return {value: 0, flag: 64, bounce: false} (_codeIndexBasis);
    }

    function indexBasisCodeHash() external view override responsible returns (uint256 hash) {
        return {value: 0, flag: 64, bounce: false} tvm.hash(_buildIndexBasisCode());
    }

    function resolveIndexBasis() external view override responsible returns (address indexBasis) {
        TvmCell code = _buildIndexBasisCode();
        TvmCell state = _buildIndexBasisState(code, address(this));
        uint256 hashState = tvm.hash(state);
        indexBasis = address.makeAddrStd(address(this).wid, hashState);
        return {value: 0, flag: 64, bounce: false} indexBasis;
    }

    function _buildIndexBasisCode() internal virtual view returns (TvmCell) {
        string stamp = "nft";
        TvmBuilder salt;
        salt.store(stamp);
        return tvm.setCodeSalt(_codeIndexBasis, salt.toCell());
    }

    function _buildIndexBasisState(TvmCell code,address collection) internal virtual pure returns (TvmCell) {
        return tvm.buildStateInit({contr: IndexBasis,varInit: {_collection: collection},code: code});
    }

    function indexCode() external view override responsible returns (TvmCell code) {
        return {value: 0, flag: 64, bounce: false} (_codeIndex);
    }

    function indexCodeHash() external view override responsible returns (uint256 hash) {
        return {value: 0, flag: 64, bounce: false} tvm.hash(_codeIndex);
    }

    function _buildNftState(TvmCell code,uint256 id) internal virtual override pure returns (TvmCell) {
        return tvm.buildStateInit({contr: TIP4_3Nft,varInit: {_id: id},code: code});
    }
}
