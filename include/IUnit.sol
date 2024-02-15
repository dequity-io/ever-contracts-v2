pragma ton-solidity >= 0.58.1;

interface IUnit {
    function withdraw(uint128 amount) external;
    function onKYCReceived(bool exists) external;
    function userProfileAddress() external view responsible returns (address userProfile);
    function getWithdrawnAmt() external view responsible returns(uint128 withdrawnAmt);
    function getGasFee() external view responsible returns(uint128 withdrawGasFee);
}
