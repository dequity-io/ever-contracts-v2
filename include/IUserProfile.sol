pragma ton-solidity >= 0.58.1;

uint128 constant SEND_CALLBACK_TO_ROOT_VALUE = 0.3 ever;

interface IUserProfile {
    event SetKYC(bool flag);
    function setKYC() external;
    function checkKYC() external responsible returns(bool KYCed);
}
