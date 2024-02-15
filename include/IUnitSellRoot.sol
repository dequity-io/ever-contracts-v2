pragma ton-solidity >= 0.58.1;

interface IUnitSellRoot {
    event SellCreated(address sell, address unit, uint128 price);
    function onUnitSellDeploy(address seller,address unit,uint128 price) external;
    function burnUnitSell(address unit) external;
    function withdraw(address dest, uint128 value) external;
    function getDeployUnitSellGasFee() external view responsible returns(uint128);
    function getBurnUnitSellGasFee() external view responsible returns(uint128);
    function sellCode() external view responsible returns (TvmCell);
    function sellCodeHash() external view responsible returns (uint256);
    function sellAddress(address unit) external view responsible returns (address);
}
