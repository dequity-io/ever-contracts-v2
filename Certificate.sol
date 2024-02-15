pragma ton-solidity >= 0.58.1;

import "nft.h";
import 'ICertificate.sol';
import 'IUnitSell.sol';

interface IUnitStatus {
    event ChangedStatus(UnitStatusType status);
    function getStatusType() external view responsible returns (UnitStatusType);
}
enum UnitStatusType { OK, PENDING, CERTIFIED }
abstract contract UnitStatus is IUnitStatus {
    uint16 constant STATUS_CHANGED = 1300;
    UnitStatusType private _status;
    function _setStatusType(UnitStatusType status) internal virtual {
        emit ChangedStatus(status);
        _status = status;
    }
    function getStatusType() public view override responsible returns (UnitStatusType) {
        return { value: 0, flag: 64, bounce: false } (_status);
    }
    modifier statusType(UnitStatusType status) virtual {
        require(getStatusType() == status, STATUS_CHANGED);
        _;
    }
}

interface ISupervisor {
    function getSupervisor() external view responsible returns(address);
}
abstract contract Supervisor is ISupervisor, TIP6 {
    address private _supervisor;
    constructor(address supervisor) {
        _supervisor = supervisor;
        _supportedInterfaces[bytes4(tvm.functionId(ISupervisor.getSupervisor))];
    }
    function getSupervisor() public view virtual override responsible returns(address) {
        return{value: 0, flag: 64, bounce: false} (_supervisor);
    }
}

abstract contract Certificate is ICertificate, TIP4_1Nft, UnitStatus, Supervisor {

    uint16 constant NOT_CERTIFIED = 1501;
    uint16 constant SENDER_NOT_APPROVER_OR_SUPERVISOR = 1502;
    uint16 constant CALLBACK_DATA_IS_EMPTY = 1503;
    uint16 constant SENDER_NOT_EXPECTED_OFFER = 1504;
    uint16 constant LOW_MSG_VALUE = 1505;

    uint128 constant PROCESSING_VALUE = 0.3 ever;

    address private _approvedAddress;
    string private _certificateId;
    optional(address) private _offerOpt;
    optional(address) private _newManagerOpt;
    optional(string) private _certificateIdOpt;

    constructor(address approvedAddress, address supervisor) Supervisor(supervisor) {
        _approvedAddress = approvedAddress;
        _supportedInterfaces[bytes4(tvm.functionId(ICertificate.addCertificate)) ^bytes4(tvm.functionId(ICertificate.onCancelOfferCallback)) ^bytes4(tvm.functionId(ICertificate.removeCertificate)) ^bytes4(tvm.functionId(ICertificate.getCertificateId)) ^bytes4(tvm.functionId(ICertificate.getCertificateApprovedAddress)) ^bytes4(tvm.functionId(ICertificate.getAddCertificateGasFee)) ^bytes4(tvm.functionId(ICertificate.getRemoveCertificateGasFee))] = true;
    }

    function addCertificate(string certificateId, address offer) external virtual override {
        require(msg.value >= getAddCertificateGasFee(), LOW_MSG_VALUE);
        require(msg.sender == _approvedAddress || msg.sender == Supervisor.getSupervisor(), SENDER_NOT_APPROVER_OR_SUPERVISOR);
        tvm.rawReserve(0, 4);
        if (offer.value != 0) {
            _offerOpt.set(offer);
            _newManagerOpt.set(msg.sender);
            _certificateIdOpt.set(certificateId);
            IUnitSell(offer).cancelOffer{value: 0, flag: 128, bounce: true}();
        } else {
            _certificateId = certificateId;
            emit AddCertificate(certificateId, msg.sender);
            UnitStatus._setStatusType(UnitStatusType.CERTIFIED);
            _changeManager(msg.sender);
            msg.sender.transfer({value: 0, flag: 128 + 2, bounce: false});
        }
    }

    function onCancelOfferCallback() external virtual override {
        require(_offerOpt.hasValue() && _newManagerOpt.hasValue() && _certificateIdOpt.hasValue(), CALLBACK_DATA_IS_EMPTY);
        require(_offerOpt.get() == msg.sender, SENDER_NOT_EXPECTED_OFFER);
        tvm.rawReserve(0, 4);
        string certificateId = _certificateIdOpt.get();
        address newManager = _newManagerOpt.get();
        _offerOpt = null; _newManagerOpt = null; _certificateIdOpt = null;
        _certificateId = certificateId;
        emit AddCertificate(certificateId, newManager);
        UnitStatus._setStatusType(UnitStatusType.CERTIFIED);
        _changeManager(newManager);
        newManager.transfer({value: 0, flag: 128 + 2, bounce: false});
    }

    function removeCertificate() external virtual override onlyManager {
        require(msg.value >= getRemoveCertificateGasFee(), LOW_MSG_VALUE);
        require(getStatusType() == UnitStatusType.CERTIFIED, NOT_CERTIFIED);
        tvm.rawReserve(0, 4);
        emit RemoveCertificate(_certificateId, msg.sender);
        delete _certificateId;
        UnitStatus._setStatusType(UnitStatusType.OK);
        _changeManager(_owner);
        msg.sender.transfer({value: 0, flag: 128 + 2, bounce: false});
    }

    function getCertificateId() public view virtual override responsible returns(string) {
        return{value: 0, flag: 64, bounce: false} (_certificateId);
    }

    function getCertificateApprovedAddress() public view virtual override responsible returns(address) {
        return{value: 0, flag: 64, bounce: false} (_approvedAddress);
    }

    function getAddCertificateGasFee() public view virtual override responsible returns(uint128) {
        return{value: 0, flag: 64, bounce: false} (PROCESSING_VALUE + SELL_FEE);
    }

    function getRemoveCertificateGasFee() public view virtual override responsible returns(uint128) {
        return{value: 0, flag: 64, bounce: false} (PROCESSING_VALUE);
    }
}
