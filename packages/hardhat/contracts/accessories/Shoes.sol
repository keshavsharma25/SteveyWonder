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

contract Shoes is ERC721, ERC721Burnable, Ownable, ERC721Enumerable {
	uint256 private _nextTokenId = 1;

	address private _steveyWonderAddr;
	address private _erc6551RegistryAddr;
	address private _accImplementationAddr;
	bytes32 private immutable _salt = bytes32(0);

	struct Shoe {
		uint256 top;
		uint256 bottom;
	}

	mapping(uint256 => Shoe) private _shoes;
	string[10] private _colors = [
		"#000000",
		"#FFFFFF",
		"#C6444C",
		"#C1582A",
		"#D77808",
		"#C03388",
		"#257671",
		"#3A8B9D",
		"#2A82C1",
		"#3D4FF2"
	];

	constructor(
		address _initialOwner,
		address _steveyWonder,
		address _erc6551Registry,
		address _accImplementation
	) ERC721("Shoes", "SHOE") Ownable(_initialOwner) {
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

		uint256 indexTop = uint256(predictableRandom) % 17;
		uint256 indexBottom = uint256(predictableRandom) % 23;

		uint256 top = uint256(uint8(predictableRandom[indexTop])) %
			_colors.length;
		uint256 bottom = uint256(uint8(predictableRandom[indexBottom])) %
			_colors.length;

		uint256 i = 2;

		while (top == bottom) {
			bottom = uint256(uint8(predictableRandom[i++])) % 3;
		}

		_shoes[tokenId] = Shoe(top, bottom);
	}

	function _ShoesURI(uint256 _tokenId) internal view returns (string memory) {
		return
			string(
				abi.encodePacked(
					"data:application/json;base64,",
					Base64.encode(
						bytes(
							abi.encodePacked(
								'{"name": "SteveyWonder Shoes #',
								Strings.toString(_tokenId),
								'", "image": "',
								_generateBase64(_tokenId),
								'", "description": "This is an Inventory NFT item that can be traded or bought to make your SteveyWonder look awesome!",',
								'"attributes": [{"trait_type": "type", "value": "shoes"}]}'
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
				'<g transform="translate(-272.5,-650) scale(2, 2)">',
				renderByTokenId(_tokenId),
				"</g>",
				"</svg>"
			);
	}

	function renderByTokenId(
		uint256 _tokenId
	) public view returns (string memory) {
		return _ShoesSVG(_tokenId);
	}

	function _ShoesSVG(uint256 _tokenId) public view returns (string memory) {
		uint256 salt = uint256(uint(_salt));

		return
			string.concat(
				'<path id="',
				Strings.toString(salt + _tokenId),
				'" d="M178.291 428.726H225.511V430.999C225.511 432.656 224.167 433.999 222.511 433.999H181.291C179.634 433.999 178.291 432.656 178.291 430.999V428.726Z" fill="',
				_colors[uint256(_shoes[_tokenId].bottom)],
				'"/>',
				'<path d="M178.291 428.727C178.291 421.736 183.958 416.069 190.948 416.069H212.853C219.844 416.069 225.511 421.736 225.511 428.727H178.291Z" fill="',
				_colors[uint256(_shoes[_tokenId].top)],
				'"/>',
				'<path d="M246.973 428.726H294.192V430.999C294.192 432.656 292.849 433.999 291.192 433.999H249.973C248.316 433.999 246.973 432.656 246.973 430.999V428.726Z" fill="',
				_colors[uint256(_shoes[_tokenId].bottom)],
				'"/>',
				'<path d="M246.973 428.727C246.973 421.736 252.64 416.069 259.63 416.069H281.535C288.525 416.069 294.192 421.736 294.192 428.727H246.973Z" fill="',
				_colors[uint256(_shoes[_tokenId].top)],
				'"/>'
			);
	}

	function contractURI() public pure returns (string memory) {
		string memory json = string.concat(
			'{"name": "SteveyWonder\'s Shoes Collection", "description": "This is a collection of SteveyWonder\'s Shoes NFTs.", "image": "',
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
		return _ShoesURI(tokenId);
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
