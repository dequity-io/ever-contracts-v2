pragma ton-solidity >= 0.58.1;

interface IUserProfileRoot {
    function mint(string json) external;
    function onMint(uint256 id, address owner, address manager) external;
    function setKYC(uint256 id) external;
    function withdraw(address dest, uint128 value) external;
    function setRemainOnNft(uint128 remainOnNft) external;
    function setKYCValue(uint128 setKYCValue) external;
    function setMintingFee(uint128 mintingFee) external;
    function getRemainOnNft() external responsible view returns(uint128 remainOnNft);
    function getKYCValue() external responsible view returns(uint128 setKYCValue);
    function getGasFee() external responsible view returns(uint128 mintGasFee);
    function mintingFee() external view responsible returns(uint128);
}
