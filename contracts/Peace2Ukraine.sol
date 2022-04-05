/******************************
 * @Auth: Geniusdev0813
 * @Date: 2022.3.22
 * @Desc: Peace2Ukraine NFT Smart Contract
 */

//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract PEACE2UKRAINE is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    using Strings for uint256;
    
    // Optional mapping for token URIs (meta data)
    mapping(uint256 => string) private _tokenURIs;
        
    string[] public _collections;

    // Count of Total NFT (Token)
    Counters.Counter private _tokenIds;

    // Total NFT Supply
    uint public constant MAX_SUPPLY = 1000;

    // NFT Price 
    uint public price = 0.05 ether;

    // Limit per Mint
    uint public constant MAX_PER_MINT = 10;
    
    // Percent of Donate for Ukraine
    uint public donateRate = 20;

    // Donate Address
    address donateAddress;

    /***************************** Functions *********************************/

    constructor () ERC721("Peace 2 Ukraine", "PEACE2UKRAINE") {
    }

    // SetPrice
    function setPrice(uint _price) public onlyOwner {
        require( _price > 0);
        price = _price;
    }

    // Set Donate Rate
    function setDonateRate(uint _rate) public onlyOwner {
        require( _rate > 0 );
        donateRate = _rate;
    }

    // set Donate address
    function setDonateAddress(address _address) public onlyOwner {
        require(_address != address(0) && _address != address(this));
        donateAddress = _address;
    }
  
    // Get total NFT count
    function _lastTokenID() external view virtual returns (uint) {
        return _tokenIds.current();
    }

    // Multi Mint only Onwer
    function mintNFTs(uint _count,  string[] memory tokenURIs) public onlyOwner {
        uint totalMinted = _tokenIds.current();

        require(totalMinted.add(_count) <= MAX_SUPPLY, "Not enough NFTs left!");
        require(_count >0 && _count <= MAX_PER_MINT, "Cannot mint specified number of NFTs. You can mint at most 10 NFT at once");
        for (uint i = 0; i < _count; i++) {
            _mintSingleNFT(tokenURIs[i]);
        }
    }

    function _mintSingleNFT(string memory _tokenURI) private {
        uint newTokenID = _tokenIds.current();
        _safeMint(msg.sender, newTokenID);
        _setTokenURI(newTokenID, _tokenURI);
        _tokenIds.increment();
        setApprovalForAll(address(this), true);
    }

    // Single Mint only Onwer
    function mintSingleNFT(string memory _tokenURI) public onlyOwner {
        uint totalMinted = _tokenIds.current();
        require(totalMinted.add(1) <= MAX_SUPPLY, "Not enough NFTs left!");
        _mintSingleNFT(_tokenURI);
    }

    // Burn NFT
    function burnNFT(uint256 _tokenID) public onlyOwner {
        _burn(_tokenID);
    }
    
    function tokensOfOwner(address _owner) external view returns (uint[] memory) {

        uint tokenCount = balanceOf(_owner);
        uint[] memory tokensId = new uint256[](tokenCount);

        for (uint i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    function tokenURIsOfOwner(address _owner) external view returns (string[] memory) {

        uint tokenCount = balanceOf(_owner);
        string[] memory tokensURIs = new string[](tokenCount);

        for (uint i = 0; i < tokenCount; i++) {
            uint256 tokenID = tokenOfOwnerByIndex(_owner, i);
            tokensURIs[i] = tokenURI(tokenID);
        }
        return tokensURIs;
    }


    
    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");
        require(donateAddress != address(0) && donateAddress != address(this), "Invalid donate address!");
        uint donateBalance = donate();
        uint minAmount = balance - donateBalance;
        (bool minSuccess, ) = (msg.sender).call{value: minAmount}("");
        (bool donateSuccess, ) = (donateAddress).call{value: donateBalance}("");
        require(minSuccess, "Transfer failed.");
        require(donateSuccess, "Transfer failed.");
    }

    function donate() internal view returns (uint) {
        uint balance = address(this).balance;
        uint donateAmount = balance.mul(donateRate).div(100);
        return donateAmount;
    }

    function totalBalance() external view returns (uint) {
        return address(this).balance;
    }
    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

  
    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
    function getCollectionByIndex(uint index) public view returns ( string memory) {
        require(index < _collections.length, "No exist collection for this index!");
        return _collections[index];
    }

    function getAllCollections() public view returns (string[] memory) {
        return _collections;
    }


    // Add Collection
    function addCollection(string memory _collectionURI) public {
        _collections.push(_collectionURI);
    }


    /**
     * @dev Sets `_collections` as the _collectionURI of `collectionID`.
     *
     * Requirements:
     *
     * - `tokcollectionID` must exist.
     */
    function setCollection(uint256 collectionID, string memory _collectionURI) public {
        _collections[collectionID] = _collectionURI;
    }

    /**
     * @dev Destroys `collectionID`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `collectionID` must exist.
     *
     * Emits a {Transfer} event.    
     */
    function burnCollection(uint256 collectionID) public payable onlyOwner  {
        if (bytes(_collections[collectionID]).length != 0) {
            delete _collections[collectionID];
        }
    }
    

    /**
    * @dev Purchase NFT
    * @param _tokenId uint256 token ID (painting number)
    */
    function purchaseToken(uint256 _tokenId) public payable {
        require(msg.sender != address(0) && msg.sender != address(this));
        require(msg.value >= price, "Not enough ether!");
        require(_tokenId < _tokenIds.current());
        ERC721(address(this)).transferFrom( ownerOf(_tokenId), msg.sender, _tokenId);
    }
}