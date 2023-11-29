// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IERC721Custom is IERC721 {
	function renderByTokenId(
		uint256 _tokenId
	) external view returns (string memory);
}
