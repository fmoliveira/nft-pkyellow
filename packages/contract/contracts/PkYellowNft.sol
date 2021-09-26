// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract PkYellowNft is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("PkYellowNft", "PKYELLOW") {
        console.log("This is my NFT contract. Woah!");
    }

    function mintPokemon() public {
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        _setTokenURI(
            newItemId,
            "data:application/json;base64,ewogICAgIm5hbWUiOiAiUGlrYWNodSIsCiAgICAiZGVzY3JpcHRpb24iOiAiUGlrYWNodSB0aGF0IGNhbiBnZW5lcmF0ZSBwb3dlcmZ1bCBlbGVjdHJpY2l0eSBoYXZlIGNoZWVrIHNhY3MgdGhhdCBhcmUgZXh0cmEgc29mdCBhbmQgc3VwZXIgc3RyZXRjaHkuIiwKICAgICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSEJ5WlhObGNuWmxRWE53WldOMFVtRjBhVzg5SW5oTmFXNVpUV2x1SUcxbFpYUWlJSFpwWlhkQ2IzZzlJakFnTUNBek5UQWdNelV3SWo0S0lDQWdJRHh6ZEhsc1pUNHVZbUZ6WlNCN0lHWnBiR3c2SUdKc1lXTnJPeUJtYjI1MExXWmhiV2xzZVRvZ2MyVnlhV1k3SUdadmJuUXRjMmw2WlRvZ01UUndlRHNnZlR3dmMzUjViR1UrQ2lBZ0lDQThjbVZqZENCM2FXUjBhRDBpTVRBd0pTSWdhR1ZwWjJoMFBTSXhNREFsSWlCbWFXeHNQU0ozYUdsMFpTSWdMejRLSUNBZ0lEeDBaWGgwSUhnOUlqVXdKU0lnZVQwaU56VWxJaUJqYkdGemN6MGlZbUZ6WlNJZ1pHOXRhVzVoYm5RdFltRnpaV3hwYm1VOUltMXBaR1JzWlNJZ2RHVjRkQzFoYm1Ob2IzSTlJbTFwWkdSc1pTSStVR2xyWVdOb2RUd3ZkR1Y0ZEQ0S0lDQWdJRHhwYldGblpTQm9jbVZtUFNKa1lYUmhPbWx0WVdkbEwzQnVaenRpWVhObE5qUXNhVlpDVDFKM01FdEhaMjlCUVVGQlRsTlZhRVZWWjBGQlFVTm5RVUZCUVc5QlowMUJRVUZFZUd0R1JDdEJRVUZCUkVaQ1RWWkZXRzFqZDBRdkx5ODRXa2RTYmk4dmQwSkNUalZNWWtGQlFVSklSV3hGVVZaUldVZFJXRUpKVjNSWFZWSm5RVFJNWTNOdFEzYzNkMkpvWjFWTVF6Vklla1JqU0ZOdldWQjFPVFY2ZERJNWJpdEJWazlSVFc1TGRIRXdSRWxTUmpRNVJYTkxla3Q2VG5GUVowZzNhamRCWTBzMlFuTkZhVGd6Ym1sR2IwTTBiWGRDYVN0bloxRTVPVGhEVWtkclRqaHRiVXN6UTNKNWVWcHpWWFIyWkdadVpEUTRPRlZRTkU1cFV6bFpWWFEwYzJORVVuTmlSR1Y0ZEVabVVXdzNVVWg0VFV0R1NFeEpSVEZPYlVOMk1VSmpMMEZvWlZJM1IzY3JZWGRPVmk5RVlXMUxVM2xzYmxsVVUxaGFObVJaYkhwQ2RVa3JjWGxGWlZkT2VsVTVVWFpLWlhsdFVqTm1jemRETUd4cVQwTjZSVzV2V1dKeloyaFJLelp6VVhVdmFGQTRUVlpPV1hsSFVEZDZXSGR4YUhCVmNYUm9iRnBMVlRsMFZGRjBVelZ5VkRaU1VYb3ljM0I1SzAxNmIxZzJka3BUT1ZCbWQzWXhaRnBtV0RWdVQyaFFiV3BsYlZNNFNraGFhWFpEYVhaM2MzZHJhblZGV1c5TlJGTkRUbXgzYzBKalJ6bFlNMGcxU2xsTE1qVllXa0pqUkROS2JpOUJabXA0WlZJMFpTdHFTelZOUVVGQlFVRlRWVlpQVWtzMVExbEpTVDBpSUdobGFXZG9kRDBpTVRBd0lpQjNhV1IwYUQwaU1UQXdJaUIwY21GdWMyWnZjbTA5SW5SeVlXNXpiR0YwWlNneE1qVXNNVEkxS1NJdlBnbzhMM04yWno0PSIKfQ=="
        );
        _tokenIds.increment();
        console.log("Minted a Pikachu NFT %s to %s", newItemId, msg.sender);
    }
}