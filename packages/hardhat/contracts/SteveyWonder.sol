//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { ERC721Burnable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";
import { IERC6551Registry } from "erc6551/interfaces/IERC6551Registry.sol";
import { IERC4906 } from "./interfaces/IERC4906.sol";
import { IERC721Custom } from "./interfaces/IERC721Custom.sol";

/**
 * @title SteveyWonder
 * @author Keshav
 * @notice A simple ERC721 contract that mints Stevey NFTs that are converted to
 * ERC6551 tokens.
 * @dev This contract is designed to be used with the ERC6551Registry and Account Proxy contract.
 */
contract SteveyWonder is ERC721, ERC721Burnable, Ownable, IERC4906 {
	/* ----------------------------- State Variables ---------------------------- */
	address public immutable _erc6551Registry;
	address public immutable _accImplementation;
	bytes32 public immutable salt = bytes32(0);

	uint256 private _nextTokenId = 1;
	uint256 private price;
	address[] public nftAccessoryAddrs;
	mapping(address => bool) public hasNftAccessoryAddrs;

	mapping(address => mapping(uint256 => uint256)) public activeAccessories;

	/* ------------------------------- Constructor ------------------------------ */
	constructor(
		address _initialOwner
	) ERC721("Stevey", "STEV") Ownable(_initialOwner) {}

	/* -------------------------------- Functions ------------------------------- */
	function safeMint() public payable {
		uint256 tokenId = _nextTokenId++;
		_safeMint(msg.sender, tokenId);
	}

	function tokenURI(
		uint256 tokenId
	) public view override returns (string memory) {
		return _steveyWonderTokenURI(tokenId);
	}

	function _steveyWonderTokenURI(
		uint256 tokenId
	) internal view returns (string memory) {
		string memory svg = _generateBase64(tokenId);
		return
			string(
				abi.encodePacked(
					"data:application/json;base64,",
					Base64.encode(
						bytes(
							abi.encodePacked(
								'{"name": "SteveyWonder", "image": "',
								svg,
								'", "description": "This is a Character NFT',
								" based on the implementation of ERC6551 and its application.",
								' This NFT account contains other accessories as NFTs."}'
							)
						)
					)
				)
			);
	}

	function _generateBase64(
		uint256 _tokenId
	) internal view returns (string memory) {
		return Base64.encode(bytes(_generateSVG(_tokenId)));
	}

	function _generateSVG(
		uint256 _tokenId
	) internal view returns (string memory) {
		return
			string.concat(
				'<svg width="300" height="300" viewBox="0 0 196 331" fill="none" xmlns="http://www.w3.org/2000/svg">',
				renderByTokenId(_tokenId),
				"</svg>"
			);
	}

	function renderByTokenId(
		uint256 _tokenId
	) internal view returns (string memory) {
		string memory render = SteveyWonderSvg();

		for (uint256 i = 0; i < nftAccessoryAddrs.length; i++) {
			if (activeAccessories[nftAccessoryAddrs[i]][_tokenId] > 0) {
				render = string.concat(
					render,
					renderAccessory(nftAccessoryAddrs[i], _tokenId)
				);
			}
		}

		return render;
	}

	function renderAccessory(
		address nftAccessory,
		uint256 _tokenId
	) internal view returns (string memory) {
		return IERC721Custom(nftAccessory).renderByTokenId(_tokenId);
	}

	function SteveyWonderSvg() internal pure returns (string memory) {
		return
			string.concat(
				'<rect width="48.9777" height="149.382" transform="matrix(1 0 0 -1 262.912 465.208)" fill="#EFA78C"/>',
				'<path d="M184.547 465.208H233.525V315.826H184.547V465.208Z" fill="#EFA78C"/>',
				'<rect width="48.9777" height="161.627" transform="matrix(1 0 0 -1 319.236 309.705)" fill="#EFA78C"/>',
				'<rect width="48.9777" height="161.627" transform="matrix(1 0 0 -1 128.223 309.705)" fill="#EFA78C"/>',
				'<rect x="177.199" y="148.078" width="142.035" height="168.973" fill="#E89B7F"/>',
				'<rect x="199.24" y="59.9175" width="97.9563" height="88.1607" fill="#EFA78C"/>',
				'<rect x="215.156" y="79.5088" width="19.5916" height="19.5916" fill="white"/>',
				'<rect x="222.502" y="83.1821" width="12.2447" height="12.2447" fill="black"/>',
				'<rect x="233.525" y="121.14" width="29.3874" height="12.2447" fill="#BB7156"/>',
				'<rect x="261.686" y="79.5088" width="19.5916" height="19.5916" fill="white"/>',
				'<rect x="261.686" y="83.1821" width="12.2447" height="12.2447" fill="black"/>',
				'<path d="M319.237 317.051H177.201V378.273H244.546V364.804H251.892V378.273H319.237V317.051Z" fill="white"/>'
			);
	}

	function supportsInterface(
		bytes4 interfaceId
	) public view override(IERC165, ERC721) returns (bool) {
		return super.supportsInterface(interfaceId);
	}

	function addNftAccessoryAddr(address _nftAccessory) public onlyOwner {
		if (!hasNftAccessoryAddrs[_nftAccessory]) {
			nftAccessoryAddrs.push(_nftAccessory);
			hasNftAccessoryAddrs[_nftAccessory] = true;
		}
	}

	function setActiveAccessories(
		address _nftAccessory,
		uint256 _SteveyWondertokenId,
		uint256 _accessoryTokenId
	) public {
		require(
			ownerOf(_SteveyWondertokenId) == msg.sender,
			"only token owner can set accessory"
		);
		require(
			hasNftAccessoryAddrs[_nftAccessory],
			"Not a valid NFT Accessory Address"
		);

		IERC721 nftAccessory = IERC721(_nftAccessory);

		require(
			nftAccessory.ownerOf(_accessoryTokenId) ==
				getTBAAddress(_SteveyWondertokenId),
			"only accessories that belong to the Token Bound Account can be set."
		);

		activeAccessories[_nftAccessory][
			_SteveyWondertokenId
		] = _accessoryTokenId;
	}

	function setActiveAccessoriesOnUpdate(
		address _nftAccessory,
		uint256 _SteveyWondertokenId,
		uint256 _accessoryTokenId
	) internal {
		require(
			_nftAccessory == msg.sender,
			"Only NFT accessory contract can set accessory."
		);

		require(
			hasNftAccessoryAddrs[_nftAccessory],
			"Not a valid NFT Accessory Address"
		);

		activeAccessories[_nftAccessory][
			_SteveyWondertokenId
		] = _accessoryTokenId;
	}

	function getActiveAccessory(
		address _nftAccessory,
		uint256 _SteveyWondertokenId
	) public view returns (uint256) {
		require(
			hasNftAccessoryAddrs[_nftAccessory],
			"invalid NFT Accessory address"
		);
		return activeAccessories[_nftAccessory][_SteveyWondertokenId];
	}

	function getTBAAddress(uint256 tokenId) public view returns (address) {
		return
			IERC6551Registry(_erc6551Registry).account(
				_accImplementation,
				salt,
				block.chainid,
				address(this),
				tokenId
			);
	}

	/* --------------------------------- receive -------------------------------- */
	receive() external payable {}
}
