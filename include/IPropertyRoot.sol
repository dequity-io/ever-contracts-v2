pragma ton-solidity >= 0.58.1;

interface IPropertyRoot  {
    function mint(address owner,address approvedAddress,address supervisor,string propertyJson,string unitRootJson,string unitJson,uint8 royalty,uint32 numOfUnits) external;
    function withdraw(address dest, uint128 value) external;
    function setMinter(address minter) external;
    function setRemainOnNft(uint128 remainOnNft) external;
    function setMintingFee(uint128 mintingFee) external;
    function getMinter() external view responsible returns(address minter);
    function getRemainOnProperty() external view responsible returns(uint128 remainOnProperty);
    function getUserProfileCollection() external view responsible returns(address userProfileCollection);
    function getTip3TokenRoot() external view responsible returns(address tip3TokenRoot);
    function mintingFee() external view responsible returns(uint128);
    function getGasFee(uint128 numOfUnits) external view responsible returns(uint128 mintGasFee);
}
