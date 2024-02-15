pragma ton-solidity >= 0.58.1;

import 'collection.h';
import 'OwnableInternal.sol';
import 'Unit.sol';
import 'IUnitRoot.sol';

uint128 constant REMAIN_ON_UNIT_ROOT = 0.5 ever;
uint128 constant REMAIN_ON_NFT = 0.13 ever;

uint16 constant BATCH_SIZE = 6;
uint16 constant FALLBACK_THRESHOLD = 11;

contract UnitRoot is IUnitRoot, TIP4_2Collection, TIP4_3Collection, OwnableInternal {

    uint16 constant NOT_PROPERTY = 1001;
    uint16 constant VALUE_IS_EMPTY = 1002;
    uint16 constant VALUE_IS_LESS_THAN_REQUIRED = 1003;
    uint16 constant MINIMUM_CONTRACT_BALANCE = 1004;
    uint16 constant SENDER_IS_NOT_UNIT_ROOT = 1005;

    address static _property;
    address _distrWallet;
    address _bulkWorkerRoot;
    TvmCell _codeUserProfile;
    TvmCell _codeBulkWorker;

    constructor(TvmCell codeNft, TvmCell codeIndex,TvmCell codeIndexBasis,TvmCell codeUserProfile,TvmCell codeBulkWorker,address owner,string json,string unitJson,uint32 numOfUnits,address distrWallet,address userProfileCollection,address bulkWorkerRoot,address sendGasTo,address royaltyReceiver,address approvedAddress,address supervisor,uint8 royalty) OwnableInternal (owner) TIP4_1Collection (codeNft) TIP4_2Collection (json) TIP4_3Collection (codeIndex,codeIndexBasis) {
        require(_property.value != 0, VALUE_IS_EMPTY);
        require(msg.sender == _property, NOT_PROPERTY);
        require(msg.value >= (REMAIN_ON_UNIT_ROOT + (REMAIN_ON_NFT + _indexDeployValue * 2 + UNIT_FEE * 2) * numOfUnits +_deployIndexBasisValue), VALUE_IS_LESS_THAN_REQUIRED);
        tvm.rawReserve(REMAIN_ON_UNIT_ROOT, 0);
        _codeUserProfile = codeUserProfile;
        _codeBulkWorker = codeBulkWorker;
        _bulkWorkerRoot = bulkWorkerRoot;
        _distrWallet = distrWallet;
        _supportedInterfaces[bytes4(tvm.functionId(IUnitRoot.getInfo))] = true;
        if (numOfUnits > FALLBACK_THRESHOLD)
            _invokeMint(owner, unitJson,userProfileCollection,bulkWorkerRoot,sendGasTo,royaltyReceiver,approvedAddress,supervisor,royalty,numOfUnits,0);
        else {
            tvm.rawReserve(0, 4);
            TvmBuilder salt;
            salt.store(address(this));
            TvmCell cs = tvm.setCodeSalt(_codeNft, salt.toCell());
            for (uint i = 0; i < numOfUnits; i++)
                new Unit {code: cs, varInit: {_id: i}, value: REMAIN_ON_NFT + _indexDeployValue * 2 + UNIT_FEE, flag: 1} (owner, sendGasTo, REMAIN_ON_NFT, json, _indexDeployValue, _indexDestroyValue, _codeIndex, _codeUserProfile, _codeBulkWorker, _distrWallet, userProfileCollection, bulkWorkerRoot, royaltyReceiver, approvedAddress, supervisor, royalty);
            _totalSupply = numOfUnits;
            sendGasTo.transfer({value: 0, flag: 128 + 2, bounce: false});
        }
    }

    function _invokeMint(address owner,string json,address userProfileCollection,address bulkWorkerRoot,address sendGasTo,address royaltyReceiver,address approvedAddress,address supervisor,uint8 royalty,uint32 amount,uint32 currentIteration) internal pure virtual {
        if(currentIteration < amount)
            UnitRoot(address(this)).mint{value: 0, bounce: false, flag: 128}(owner,json,userProfileCollection,bulkWorkerRoot,sendGasTo,royaltyReceiver,approvedAddress,supervisor,royalty,amount,currentIteration);
        else
            sendGasTo.transfer({value: 0, flag: 128 + 2, bounce: false});
    }

    function mint( address owner, string json, address userProfileCollection, address bulkWorkerRoot, address sendGasTo, address royaltyReceiver, address approvedAddress, address supervisor, uint8 royalty, uint32 numOfUnits, uint32 currentIteration ) external virtual {
        require(msg.sender == address(this), SENDER_IS_NOT_UNIT_ROOT);
        tvm.rawReserve(0, 4);
        uint256 id = _totalSupply;
        _totalSupply++;
        TvmCell codeNft = _buildNftCode(address(this));
        TvmCell stateNft = _buildNftState(codeNft, id);
        address nftAddr = new Unit{ stateInit: stateNft, value: REMAIN_ON_NFT + _indexDeployValue * 2 + UNIT_FEE, flag: 0 + 1 }(owner,sendGasTo, REMAIN_ON_NFT,json,_indexDeployValue,_indexDestroyValue,_codeIndex,_codeUserProfile,_codeBulkWorker,_distrWallet,userProfileCollection,bulkWorkerRoot,royaltyReceiver,approvedAddress,supervisor,royalty);
        emit NftCreated(id, nftAddr,owner,owner, owner);
        currentIteration++;
        _invokeMint(owner, json,userProfileCollection,bulkWorkerRoot,sendGasTo,royaltyReceiver,approvedAddress,supervisor,royalty,numOfUnits, currentIteration);
    }

    function getInfo() external responsible override returns(address property,address distrWallet) {
        return {value: 0, flag: 64, bounce: false} (_property,_distrWallet);
    }

    function _isOwner() internal virtual override onlyOwner returns(bool){
        return true;
    }

    function _buildNftState(TvmCell code,uint256 id) internal virtual override(TIP4_2Collection, TIP4_3Collection) pure returns (TvmCell) {
        return tvm.buildStateInit({contr: Unit,varInit: {_id: id},code: code});
    }
}
