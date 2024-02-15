pragma ton-solidity >= 0.58.1;

import 'IUnit.sol';
import 'IDistributionsWallet.sol';
import 'UserProfile.sol';
import 'Royalty.sol';
import 'Certificate.sol';

import 'IBulkWorkerAgent.sol';
import 'BulkWorkerResolver.sol';
abstract contract BulkWorkerAgent is IBulkWorkerAgent, TIP4_1Nft, BulkWorkerResolver  {
    uint16 constant SENDER_IS_NOT_EXPECTED_BULK_WORKER = 1100;
    uint16 constant SET_ANOTHER_MANAGER = 1101;
    constructor(TvmCell codeBulkWorker, address bulkWorkerRoot) BulkWorkerResolver(codeBulkWorker, bulkWorkerRoot) {
        _supportedInterfaces[bytes4(tvm.functionId(IBulkWorkerAgent.changeManagerByBulkWorker))] = true;
    }
    function changeManagerByBulkWorker(address newManager, address sendGasTo, mapping(address => CallbackParams) callbacks) external virtual override onlyBulkWorker() {
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
    modifier onlyBulkWorker() {
        require(msg.sender == BulkWorkerResolver.bulkWorkerAddress(_manager.value), SENDER_IS_NOT_EXPECTED_BULK_WORKER);
        _;
    }
}

contract Unit is IUnit, TIP4_1Nft, TIP4_2Nft, TIP4_3Nft, Certificate, BulkWorkerAgent, Royalty {

    uint16 constant VALUE_MUST_BE_GREATER_THAN_0 = 1001;
    uint16 constant WRONG_SENDER = 1002;
    uint16 constant NOT_ENOUGH_VALUE = 1003;

    TvmCell _codeUserProfile;
    address _userProfileCollection;
    address _distrWallet;
    uint128 _withdrawnAmt;
    uint128 _pendingAmt;

    constructor(address owner,address sendGasTo,uint128 remainOnNft,string json,uint128 indexDeployValue,uint128 indexDestroyValue,TvmCell codeIndex,TvmCell codeUserProfile,TvmCell codeBulkWorker,address distrWallet, address userProfileCollection,address bulkWorkerRoot,address royaltyReceiver,address approvedAddress,address supervisor,uint8 royalty) TIP4_1Nft(owner,sendGasTo,remainOnNft) TIP4_2Nft (json) TIP4_3Nft (indexDeployValue,indexDestroyValue,codeIndex) BulkWorkerAgent (codeBulkWorker, bulkWorkerRoot) Royalty (royalty,royaltyReceiver) Certificate (approvedAddress,supervisor) {
        _codeUserProfile = codeUserProfile;
        _userProfileCollection = userProfileCollection;
        _distrWallet = distrWallet;
        _setStatusType(UnitStatusType.OK);
        _supportedInterfaces[bytes4(tvm.functionId(IUnit.withdraw)) ^bytes4(tvm.functionId(IUnit.onKYCReceived)) ^bytes4(tvm.functionId(IUnit.userProfileAddress)) ^bytes4(tvm.functionId(IUnit.getWithdrawnAmt)) ^bytes4(tvm.functionId(IUnit.getGasFee))] = true;
        _supportedInterfaces[bytes4(tvm.functionId(IUnitStatus.getStatusType))] = true;
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

    function withdraw(uint128 amount) external override statusType(UnitStatusType.OK) {
        tvm.rawReserve(0, 4);
        require(msg.sender == _owner || msg.sender == BulkWorkerResolver.bulkWorkerAddress(_owner.value), WRONG_SENDER);
        require(msg.value >= getGasFee(), NOT_ENOUGH_VALUE);
        require(amount > 0, VALUE_MUST_BE_GREATER_THAN_0);
        _setStatusType(UnitStatusType.PENDING);
        _pendingAmt = amount;
        address userProfile = _userProfileAddress();
        IUserProfile(userProfile).checkKYC{value: 0,flag: 128,bounce: true,callback: Unit.onKYCReceived}();
    }

    function onKYCReceived(bool exists) external override statusType(UnitStatusType.PENDING) {
        tvm.rawReserve(0, 4);
        require(_pendingAmt > 0, VALUE_MUST_BE_GREATER_THAN_0);
        require(_userProfileAddress() == msg.sender, WRONG_SENDER);

        _setStatusType(UnitStatusType.OK);
        if (exists) {
            uint128 withdrawnAmt = _withdrawnAmt;
            _withdrawnAmt += _pendingAmt;
            IDistributionsWallet(_distrWallet).transfer{value: 0, flag: 128, bounce: true}(_id, withdrawnAmt, _pendingAmt, _manager, _manager);
        } else {
            delete _pendingAmt;
            _manager.transfer({value: 0, flag: 128 + 2, bounce: false});
        }
    }

    function userProfileAddress() external view virtual override responsible returns (address userProfile) {
        return{value: 0, flag: 64, bounce: false} _userProfileAddress();
    }

    function getJson() external virtual view override responsible returns (string json) {
        json = _json;
        string separatorValue = "{id}";
        optional(uint32) separatorStartIndex = json.find(separatorValue);
        while(separatorStartIndex.hasValue()) {
            string head = json.substr(0, separatorStartIndex.get());
            string tail = json.substr(separatorStartIndex.get() + (separatorValue.byteLength()));
            json = head + format("{}", _id) + tail;
            separatorStartIndex = json.find(separatorValue);
        }
        separatorValue = "{root}";
        separatorStartIndex = json.find(separatorValue);
        while(separatorStartIndex.hasValue()) {
            string head = json.substr(0, separatorStartIndex.get());
            string tail = json.substr(separatorStartIndex.get() + (separatorValue.byteLength()));
            json = head + format("{}", _collection) + tail;
            separatorStartIndex = json.find(separatorValue);
        }
        return {value: 0, flag: 64, bounce: false} (json);
    }

    function getWithdrawnAmt() public view virtual override responsible returns(uint128 withdrawnAmt) {
        return{value: 0, flag: 64, bounce: false} (_withdrawnAmt);
    }

    function getGasFee() public view virtual override responsible returns(uint128 withdrawGasFee) {
        return{value: 0, flag: 64, bounce: false} (UNIT_FEE * 2);
    }

    function _userProfileAddress() internal view returns(address userProfile) {
        TvmCell code = _buildUserProfileCode();
        TvmCell state = _buildUserProfileState(code, _owner.value);
        uint256 hashState = tvm.hash(state);
        return address.makeAddrStd(address(this).wid, hashState);
    }

    function _buildUserProfileCode() internal virtual view returns (TvmCell) {
        TvmBuilder salt;
        salt.store(_userProfileCollection);
        return tvm.setCodeSalt(_codeUserProfile, salt.toCell());
    }

    function _buildUserProfileState(TvmCell code,uint256 id) internal virtual pure returns (TvmCell) {
        return tvm.buildStateInit({contr: UserProfile,varInit: {_id: id},code: code});
    }

    onBounce(TvmSlice slice) override external {
        tvm.rawReserve(0, 4);
        uint32 functionId = slice.load(uint32);
		if (functionId == tvm.functionId(IDistributionsWallet.transfer) &&msg.sender == _distrWallet) {
		    _withdrawnAmt -= _pendingAmt;
            delete _pendingAmt;
            _manager.transfer({value: 0, flag: 128 + 2, bounce: false});
		}
        else if (functionId == tvm.functionId(IUserProfile.checkKYC)) {
            if (msg.sender == _userProfileAddress()) {
                _setStatusType(UnitStatusType.OK);
                delete _pendingAmt;
            }
            _owner.transfer({value: 0, flag: 128 + 2});
        }
	}
}