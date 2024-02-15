pragma ton-solidity >= 0.58.1;

interface ICertificate {
    event AddCertificate(string certificateId, address initiator);
    event RemoveCertificate(string certificateId, address initiator);
    function addCertificate(string certificateId, address offer) external;
    function onCancelOfferCallback() external;
    function removeCertificate() external;
    function getCertificateId() external view responsible returns(string);
    function getCertificateApprovedAddress() external view responsible returns(address);
    function getAddCertificateGasFee() external view responsible returns(uint128);
    function getRemoveCertificateGasFee() external view responsible returns(uint128);
}
