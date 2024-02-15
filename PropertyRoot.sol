pragma ton-solidity >= 0.58.1;

import 'collection.h';
import 'IPropertyRoot.sol';
import 'Property.sol';

contract PropertyRoot is IPropertyRoot, TIP4_2Collection, TIP4_3Collection, OwnableInternal {

    uint16 constant SENDER_IS_NOT_OWNER = 101;
    uint16 constant SENDER_IS_NOT_MINTER = 102;
    uint16 constant VALUE_IS_LESS_THAN_REQUIRED = 103;
    uint16 constant MINIMUM_CONTRACT_BALANCE = 104;
    uint16 constant WRONG_ROYALTY_PERCENT = 1200;
    uint16 constant WRONG_ROYALTY_RECEIVER_ADDRESS = 1201;

    uint128 constant REMAIN_ON_ROOT = 0.5 ever;

    uint128 _remainOnProperty = 0.2 ever;
    address _minter;
    address _userProfileCollection;
    address _tip3TokenRoot;
    address _bulkWorkerRoot;
    TvmCell _codeDistrWallet;
    TvmCell _codeUnitRoot;
    TvmCell _codeUnit;
    TvmCell _codeUserProfile;
    TvmCell _codeBulkWorker;
    uint128 _mintingFee;

    constructor(TvmCell codeNft, TvmCell codeIndex, TvmCell codeIndexBasis, TvmCell codeDistrWallet, TvmCell codeUnitRoot, TvmCell codeUnit, TvmCell codeUserProfile, TvmCell codeBulkWorker, address owner, address minter, address userProfileCollection, address tip3TokenRoot, address bulkWorkerRoot, uint128 mintFee, string json) OwnableInternal(owner) TIP4_1Collection (codeNft) TIP4_2Collection (json) TIP4_3Collection (codeIndex, codeIndexBasis) {
        tvm.accept();
        _minter = minter;
        _userProfileCollection = userProfileCollection;
        _tip3TokenRoot = tip3TokenRoot;
        _codeDistrWallet = codeDistrWallet;
        _codeUnitRoot = codeUnitRoot;
        _bulkWorkerRoot = bulkWorkerRoot;
        _codeUnit = codeUnit;
        _codeUserProfile = codeUserProfile;
        _codeBulkWorker = codeBulkWorker;
        _mintingFee = mintFee;
        _supportedInterfaces[bytes4(tvm.functionId(IPropertyRoot.mint)) ^bytes4(tvm.functionId(IPropertyRoot.withdraw)) ^bytes4(tvm.functionId(IPropertyRoot.setMinter)) ^bytes4(tvm.functionId(IPropertyRoot.setRemainOnNft)) ^bytes4(tvm.functionId(IPropertyRoot.setMintingFee)) ^bytes4(tvm.functionId(IPropertyRoot.getMinter)) ^bytes4(tvm.functionId(IPropertyRoot.getRemainOnProperty)) ^bytes4(tvm.functionId(IPropertyRoot.getUserProfileCollection)) ^bytes4(tvm.functionId(IPropertyRoot.getTip3TokenRoot)) ^bytes4(tvm.functionId(IPropertyRoot.mintingFee)) ^bytes4(tvm.functionId(IPropertyRoot.getGasFee))] = true;
    }

    function mint( address owner, address approvedAddress, address supervisor, string propertyJson, string unitRootJson, string unitJson, uint8 royalty, uint32 numOfUnits ) external override virtual {
        tvm.rawReserve(_mintingFee, 4);
        require(msg.sender == _minter, SENDER_IS_NOT_MINTER);
        require(msg.value >= getGasFee(numOfUnits),VALUE_IS_LESS_THAN_REQUIRED);
        require(royalty >= 0 && royalty <= 100, WRONG_ROYALTY_PERCENT);

        uint256 id = _totalSupply;
        _totalSupply++;
        TvmCell codeNft = _buildNftCode(address(this));
        TvmCell stateNft = _buildNftState(codeNft, id);
        new Property {stateInit: stateNft, value: 0, flag: 128 }( owner, msg.sender, _userProfileCollection, _tip3TokenRoot, _bulkWorkerRoot, owner, approvedAddress, supervisor, _remainOnProperty, propertyJson, unitRootJson, unitJson, _indexDeployValue, _indexDestroyValue, royalty, _codeIndex, _codeDistrWallet, _codeUnitRoot, _codeUnit, _codeIndexBasis, _codeUserProfile, _codeBulkWorker, numOfUnits );
//        emit NftCreated(id, nftAddr,msg.sender,msg.sender, msg.sender);
    }

    function withdraw(address dest, uint128 value) external override onlyOwner {
        require(address(this).balance - value > REMAIN_ON_ROOT, MINIMUM_CONTRACT_BALANCE );
        tvm.rawReserve(value + msg.value, 12);
        dest.transfer({value: value, bounce: false, flag: 0 + 1});
        msg.sender.transfer({value: 0, bounce: false, flag: 128 + 2});
    }

    function setMinter(address minter) external override virtual onlyOwner {
        tvm.rawReserve(0, 4);
        _minter = minter;
        msg.sender.transfer({value: 0, bounce: false, flag: 128 + 2});
    }

    function setRemainOnNft(uint128 remainOnNft) external override virtual onlyOwner {
        tvm.rawReserve(0, 4);
        _remainOnProperty = remainOnNft;
        msg.sender.transfer({value: 0, bounce: false, flag: 128 + 2});
    }

    function setMintingFee(uint128 fee) external override virtual onlyOwner {
        tvm.rawReserve(0, 4);
        _mintingFee = fee;
        msg.sender.transfer({value: 0, bounce: false, flag: 128 + 2});
    }

    function getMinter() external override virtual view responsible returns(address minter) {
        return {value: 0, flag: 64, bounce: false}(_minter);
    }

    function getRemainOnProperty() external override virtual view responsible returns(uint128 remainOnProperty) {
        return {value: 0, flag: 64, bounce: false}(_remainOnProperty);
    }

    function getUserProfileCollection() external override virtual view responsible returns(address userProfileCollection) {
        return {value: 0, flag: 64, bounce: false}(_userProfileCollection);
    }

    function getTip3TokenRoot() external override virtual view responsible returns(address tip3TokenRoot) {
        return {value: 0, flag: 64, bounce: false}(_tip3TokenRoot);
    }

    function mintingFee() external override virtual view responsible returns(uint128) {
        return {value: 0, flag: 64, bounce: false}(_mintingFee);
    }

    function getGasFee(uint128 numOfUnits) public override virtual view responsible returns(uint128 mintGasFee) {
        return{ value: 0, flag: 64, bounce: false }(REMAIN_ON_UNIT_ROOT + (REMAIN_ON_NFT + _indexDeployValue * 2 + UNIT_FEE * 2) * numOfUnits + DEPLOY_UNIT_ROOT_INDEX_BASIS_VALUE + UNIT_FEE * 2 + REMAIN_ON_WALLET + DEPLOY_FEE + _indexDeployValue * 2 + _remainOnProperty + SELL_FEE * 2);
    }

    function _isOwner() internal virtual override onlyOwner returns(bool) {
        return true;
    }

    function _buildNftState(TvmCell code,uint256 id) internal virtual override(TIP4_2Collection, TIP4_3Collection) pure returns (TvmCell) {
        return tvm.buildStateInit({contr: Property,varInit: {_id: id},code: code});
    }
}
