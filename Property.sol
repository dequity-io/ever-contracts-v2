pragma ton-solidity >= 0.58.1;

import 'nft.h';
import 'IProperty.sol';
import 'DistributionsWallet.sol';
import 'UnitRoot.sol';

uint128 constant DEPLOY_UNIT_ROOT_INDEX_BASIS_VALUE = 0.15 ever;

contract Property is IProperty, TIP4_1Nft, TIP4_2Nft, TIP4_3Nft {

    uint16 constant VALUE_IS_LESS_THAN_REQUIRED = 1001;

    uint128 _deployUnitRootValue;
    address _distrWallet;
    address _unitRoot;

    constructor(address owner,address sendGasTo,address userProfileCollection,address tip3TokenRoot,address bulkWorkerRoot,address royaltyReceiver,address approvedAddress,address supervisor,uint128 remainOnNft,string json,string unitRootJson,string unitJson,uint128 indexDeployValue,uint128 indexDestroyValue,uint8 royalty,TvmCell codeIndex,TvmCell codeDistrWallet,TvmCell codeUnitRoot,TvmCell codeUnit,TvmCell codeIndexBasis,TvmCell codeUserProfile,TvmCell codeBulkWorker,uint32 numOfUnits) TIP4_1Nft(owner,sendGasTo,remainOnNft) TIP4_2Nft (json) TIP4_3Nft (indexDeployValue,indexDestroyValue,codeIndex) {
        _deployUnitRootValue = REMAIN_ON_UNIT_ROOT + (REMAIN_ON_NFT + _indexDeployValue * 2 + UNIT_FEE * 2) * numOfUnits + DEPLOY_UNIT_ROOT_INDEX_BASIS_VALUE + UNIT_FEE;
        require(msg.value >= _deployUnitRootValue + REMAIN_ON_WALLET + DEPLOY_FEE + UNIT_FEE + indexDeployValue * 2 +remainOnNft, VALUE_IS_LESS_THAN_REQUIRED);
        _distrWallet = _distrWalletAddress(codeDistrWallet);
        _unitRoot = _unitRootAddress(codeUnitRoot);
        _supportedInterfaces[bytes4(tvm.functionId(IProperty.getDistrWallet)) ^bytes4(tvm.functionId(IProperty.getUnitRoot))] = true;
        _deployDistrWallet(codeDistrWallet,_unitRoot,tip3TokenRoot,numOfUnits,codeUnit);
        _deployUnitRoot(owner,codeUnitRoot,codeUnit,codeIndexBasis,codeUserProfile,codeBulkWorker,unitRootJson,unitJson,numOfUnits,_distrWallet,userProfileCollection,bulkWorkerRoot,sendGasTo,royaltyReceiver,approvedAddress,supervisor,royalty);
    }

    function getDistrWallet() external override view virtual responsible returns(address distrWallet) {
        return {value: 0, flag: 64, bounce: false} _distrWallet;
    }

    function getUnitRoot() external override view virtual responsible returns(address unitRoot) {
        return {value: 0, flag: 64, bounce: false} _unitRoot;
    }

    function _deployDistrWallet(TvmCell codeDistrWallet,address unitRoot,address tip3TokenRoot,uint128 numOfUnits,TvmCell unitCode) internal virtual pure {
        TvmCell stateDistrWallet = _buildDistrWalletState(codeDistrWallet);
        new DistributionsWallet{stateInit: stateDistrWallet,value: REMAIN_ON_WALLET + DEPLOY_FEE + UNIT_FEE,flag: 0 + 1}(unitRoot,tip3TokenRoot,numOfUnits,unitCode);
    }

    function _deployUnitRoot(address owner,TvmCell codeUnitRoot,TvmCell codeUnit,TvmCell codeIndexBasis,TvmCell codeUserProfile,TvmCell codeBulkWorker,string unitRootJson,string unitJson,uint32 numOfUnits,address distrWallet,address userProfileCollection,address bulkWorkerRoot,address sendGasTo,address royaltyReceiver,address approvedAddress,address supervisor,uint8 royalty) internal virtual view {
        TvmCell stateUnitRoot = _buildUnitRootState(codeUnitRoot);
        new UnitRoot{ stateInit: stateUnitRoot, value: _deployUnitRootValue, flag: 0 + 1 }(codeUnit, _codeIndex, codeIndexBasis, codeUserProfile, codeBulkWorker, owner, unitRootJson, unitJson, numOfUnits, distrWallet, userProfileCollection, bulkWorkerRoot, sendGasTo, royaltyReceiver, approvedAddress, supervisor, royalty); 
    }

    function _distrWalletAddress(TvmCell codeDistrWallet) internal pure returns(address) {
        TvmCell state = _buildDistrWalletState(codeDistrWallet);
        uint256 hashState = tvm.hash(state);
        return address.makeAddrStd(address(this).wid, hashState);
    }

    function _buildDistrWalletState(TvmCell codeDistrWallet) internal virtual pure returns (TvmCell) {
        return tvm.buildStateInit({contr: DistributionsWallet,varInit: {_property: address(this)},code: codeDistrWallet});
    }

    function _unitRootAddress(TvmCell codeUnitRoot) internal pure returns(address) {
        TvmCell state = _buildUnitRootState(codeUnitRoot);
        uint256 hashState = tvm.hash(state);
        return address.makeAddrStd(address(this).wid, hashState);
    }

    function _buildUnitRootState(TvmCell codeUnitRoot) internal virtual pure returns (TvmCell) {
        return tvm.buildStateInit({contr: UnitRoot,varInit: {_property: address(this)},code: codeUnitRoot});
    }

    function _beforeTransfer(address to, address sendGasTo, mapping(address => CallbackParams) callbacks) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
        TIP4_3Nft._beforeTransfer(to, sendGasTo, callbacks);
    }

    function _afterTransfer(address to, address sendGasTo, mapping(address => CallbackParams) callbacks) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
        TIP4_3Nft._afterTransfer(to, sendGasTo, callbacks);
    }

    function _beforeChangeOwner(address oldOwner, address newOwner,address sendGasTo, mapping(address => CallbackParams) callbacks) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
        TIP4_3Nft._beforeChangeOwner(oldOwner, newOwner, sendGasTo, callbacks);
    }

    function _afterChangeOwner(address oldOwner, address newOwner,address sendGasTo, mapping(address => CallbackParams) callbacks) internal virtual override(TIP4_1Nft, TIP4_3Nft) {
        TIP4_3Nft._afterChangeOwner(oldOwner, newOwner, sendGasTo, callbacks);
    }
}