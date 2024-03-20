// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC721Burnable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IERC6551Registry } from "erc6551/interfaces/IERC6551Registry.sol";
import { IERC6551Account } from "erc6551/interfaces/IERC6551Account.sol";
import { ERC6551AccountLib } from "erc6551/lib/ERC6551AccountLib.sol";
import { SteveyWonder } from "../SteveyWonder.sol";

contract TShirt is ERC721, ERC721Burnable, Ownable, ERC721Enumerable {
	uint256 private _nextTokenId = 1;
	string[10] private colors = [
		"#FFFFFF",
		"#000000",
		"#5E5D7F",
		"#8D2D44",
		"#AE4E4E",
		"#D07C4C",
		"#548F27",
		"#1D5D59",
		"#4C69D0",
		"#663DBC"
	];

	address private _steveyWonderAddr;
	address private _erc6551RegistryAddr;
	address private _accImplementationAddr;
	bytes32 private immutable _salt = bytes32(0);

	struct TShirtColor {
		uint256 primaryIndex;
		uint256 secondaryIndex;
	}

	mapping(uint256 => TShirtColor) private _tshirtColor;

	constructor(
		address _initialOwner,
		address _steveyWonder,
		address _erc6551Registry,
		address _accImplementation
	) ERC721("TShirt", "TST") Ownable(_initialOwner) {
		_steveyWonderAddr = _steveyWonder;
		_erc6551RegistryAddr = _erc6551Registry;
		_accImplementationAddr = _accImplementation;
	}

	function safeMint(uint256 _toTokenId) public payable {
		uint256 tokenId = _nextTokenId++;

		address to = IERC6551Registry(_erc6551RegistryAddr).account(
			_accImplementationAddr,
			_salt,
			block.chainid,
			_steveyWonderAddr,
			_toTokenId
		);

		_safeMint(to, tokenId);

		bytes32 predictableRandom = keccak256(
			abi.encodePacked(
				tokenId,
				blockhash(block.number - 1),
				block.timestamp,
				msg.sender,
				address(this)
			)
		);

		uint256 index1 = uint256(predictableRandom) % 17;
		uint256 index2 = uint256(predictableRandom) % 23;

		uint256 primary = uint256(uint8(predictableRandom[index1])) % colors.length;
		uint256 secondary = uint256(uint8(predictableRandom[index2])) % colors.length;

		_tshirtColor[tokenId].primaryIndex = primary;
		_tshirtColor[tokenId].secondaryIndex = secondary;
	}

	function _tshirtURI(
		uint256 _tokenId
	) internal view returns (string memory) {
		return
			string(
				abi.encodePacked(
					"data:application/json;base64,",
					Base64.encode(
						bytes(
							abi.encodePacked(
								'{"name": "SteveyWonder Tshirt #',
								Strings.toString(_tokenId),
								'", "image": "',
								_generateBase64(_tokenId),
								'", "description": "This is an Inventory NFT item that can be traded or bought to make your SteveyWonder look awesome!",',
								'"attributes": [{"trait_type": "type", "value": "tshirt"}, {"trait_type": "primary", "value": "',
								colors[_tshirtColor[_tokenId].primaryIndex],
								'"}, {"trait_type": "secondary", "value": "',
								colors[_tshirtColor[_tokenId].secondaryIndex],
								'"}]}'
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
				'<svg xmlns="http://www.w3.org/2000/svg"  width="400" height="400" viewBox="0 0 400 400" fill="none">',
				'<rect id="',
				Strings.toString(_tokenId),
				'" width="400" height="400" fill="black" fill-opacity="0.05"/>',
				'<g transform="translate(-154.5,-140) scale(1.5, 1.5)">',
				renderByTokenId(_tokenId),
				"</g>",
				"</svg>"
			);
	}

	function renderByTokenId(
		uint256 _tokenId
	) public view returns (string memory) {
		return _tshirtSVG(_tokenId);
	}

	function _tshirtSVG(uint256 _tokenId) public view returns (string memory) {
		return
			string.concat(
				'<rect id="',
				Strings.toString(_tokenId),
				'" x="174" y="154.484" width="124.488" height="145.559" fill="',
				colors[_tshirtColor[_tokenId].primaryIndex],
				'"/>',
				'<mask id="path-129-inside-1_0_1" fill="white">',
				'<path d="M130 154.484H174V217.771H130V154.484Z"/>',
				"</mask>",
				'<path d="M130 154.484H174V217.771H130V154.484Z" fill="',
				colors[_tshirtColor[_tokenId].secondaryIndex],
				'"/>',
				'<path d="M173.5 154.484V217.771H174.5V154.484H173.5Z" fill="white" fill-opacity="0.24" mask="url(#path-129-inside-1_0_1)"/>',
				'<mask id="path-131-inside-2_0_1" fill="white">',
				'<path d="M342.486 154.484H298.486V217.771H342.486V154.484Z"/>',
				"</mask>",
				'<path d="M342.486 154.484H298.486V217.771H342.486V154.484Z" fill="',
				colors[_tshirtColor[_tokenId].secondaryIndex],
				'"/>',
				'<path d="M298.986 154.484V217.771H297.986V154.484H298.986Z" fill="white" fill-opacity="0.24" mask="url(#path-131-inside-2_0_1)"/>'
			);
	}

	function contractURI() public pure returns (string memory) {
		string memory json = string.concat(
			'{"name": "SteveyWonder\'s Tshirt Collection", "description": "This is a collection of SteveyWonder\'s Tshirt NFTs.", "image": "',
			'", "external_link": "https://steveywonder.vercel.app/",',
			'"collaborators": [""]'
			'"}'
		);

		return
			string(
				abi.encodePacked(
					"data:application/json;base64,",
					Base64.encode(bytes(json))
				)
			);
	}

	/* --------------------------- override functions --------------------------- */

	function tokenURI(
		uint256 tokenId
	) public view override returns (string memory) {
		return _tshirtURI(tokenId);
	}

	function _update(
		address to,
		uint256 tokenId,
		address auth
	) internal override(ERC721, ERC721Enumerable) returns (address) {
		address previousOwner = super._update(to, tokenId, auth);

		bool isErc6551Acc = ERC6551AccountLib.isERC6551Account(
			previousOwner,
			_accImplementationAddr,
			_erc6551RegistryAddr
		);

		if (isErc6551Acc) {
			(, , uint256 steveyWonderTokenId) = IERC6551Account(
				payable(previousOwner)
			).token();

			SteveyWonder steveyWonder = SteveyWonder(
				payable(_steveyWonderAddr)
			);

			if (
				tokenId ==
				steveyWonder.getActiveAccessory(
					address(this),
					steveyWonderTokenId
				)
			) {
				if (balanceOf(previousOwner) > 0) {
					steveyWonder.setActiveAccessories(
						address(this),
						steveyWonderTokenId,
						tokenOfOwnerByIndex(previousOwner, 0)
					);
				} else {
					steveyWonder.setActiveAccessories(
						address(this),
						steveyWonderTokenId,
						0
					);
				}
			}
		}
		return previousOwner;
	}

	function _increaseBalance(
		address account,
		uint128 value
	) internal override(ERC721, ERC721Enumerable) {
		super._increaseBalance(account, value);
	}

	function supportsInterface(
		bytes4 interfaceId
	) public view override(ERC721, ERC721Enumerable) returns (bool) {
		return super.supportsInterface(interfaceId);
	}
}
