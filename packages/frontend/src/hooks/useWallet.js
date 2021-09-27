import { useCallback, useEffect, useMemo, useState } from "react";
import { ethers } from "ethers";

import contractAbi from "@pkyellow/contract/rinkeby/abi.json";
import contractAddress from "@pkyellow/contract/rinkeby/address.json";
import useWindowFocus from "./useWindowFocus";

const OPENSEA_ASSETS_URL = " https://testnets.opensea.io/assets";

export const WriteStatus = {
	None: 0,
	Connect: 1,
	Request: 2,
	Pending: 3,
};

const EvmName = {
	1: "Mainnet",
};

const EvmChain = {
	Rinkeby: 4,
};

export default function useWallet() {
	const { ethereum } = window;

	const [loading, setLoading] = useState(true);
	const [writeLoading, setWriteLoading] = useState(WriteStatus.None);
	const [walletInstalled, setInstalled] = useState(false);
	const [walletConnected, setConnected] = useState(false);
	const [walletNetwork, setNetwork] = useState(null);
	const [walletAccount, setAccount] = useState("");
	const [walletError, setWalletError] = useState(null);
	const [mintLimit, setMintLimit] = useState(null);
	const [mintedToken, setMintedToken] = useState(null);

	const networkName = useMemo(() => {
		if (!walletNetwork) {
			return "";
		}
		return EvmName[walletNetwork?.chainId] || walletNetwork.name;
	}, [walletNetwork]);
	const isRinkeby = walletNetwork?.chainId === EvmChain.Rinkeby;

	const isWindowFocused = useWindowFocus();

	const updateValues = useCallback(async () => {
		setMintLimit(await getMintLimit());
	}, [setMintLimit]);

	useEffect(() => {
		subscribeToMintEvents(async (from, tokenId) => {
			updateValues();
			const connectedAccount = await getAccount();
			if (from.toUpperCase() === connectedAccount.toUpperCase()) {
				const tokenUrl = `${OPENSEA_ASSETS_URL}/${contractAddress}/${tokenId}`;
				setMintedToken({ tokenId, tokenUrl });
			}
		});
	}, [updateValues]);

	useEffect(() => {
		if (isWindowFocused) {
			// check status whenever the window focus status changes
		}
		const runUpdates = async () => {
			setInstalled(getWalletInstalled());
			setConnected(await getWalletConnected());
			setNetwork(await getNetwork());
			updateValues();
			setLoading(false);
		};
		runUpdates();
	}, [isWindowFocused, setInstalled, setConnected, updateValues, setLoading]);

	const connectWallet = () => {
		return ethereum
			.request({ method: "eth_requestAccounts" })
			.then((accountList) => {
				const [firstAccount] = accountList;
				setAccount(firstAccount);
			})
			.catch((error) => {
				setWalletError(error);
			});
	};

	const mintNft = async () => {
		setMintedToken(null);

		if (!walletInstalled) {
			return;
		}

		if (!walletConnected) {
			setWriteLoading(WriteStatus.Connect);
			await connectWallet();
			setConnected(await getWalletConnected());
		}
		setWriteLoading(WriteStatus.Request);

		mintPokemonNft()
			.then(async (transaction) => {
				setWriteLoading(WriteStatus.Pending);

				await transaction.wait();
				setWriteLoading(WriteStatus.None);
			})
			.catch((error) => {
				window.alert("Failed to mint NFT!");
				console.error(error);
				setWriteLoading(WriteStatus.None);
			});
	};

	return {
		loading,
		writeLoading: writeLoading !== WriteStatus.None,
		walletInstalled,
		walletConnected,
		walletAccount,
		walletError,
		mintLimit,
		mintedToken,
		connectWallet,
		networkName,
		isRinkeby,
		mintNft,
	};
}

function getWalletInstalled() {
	return typeof window.ethereum !== "undefined";
}

async function getWalletConnected() {
	if (!window.ethereum) {
		return false;
	}

	const accountList = await window.ethereum.request({ method: "eth_accounts" });
	return accountList.length !== 0;
}

async function getAccount() {
	if (!window.ethereum) {
		return null;
	}

	return window.ethereum
		.request({ method: "eth_requestAccounts" })
		.then((accountList) => {
			const [firstAccount] = accountList;
			return firstAccount;
		});
}

function getNetwork() {
	if (!window.ethereum) {
		return false;
	}

	const provider = new ethers.providers.Web3Provider(window.ethereum);
	return provider.getNetwork();
}

async function getMintLimit() {
	const provider = new ethers.providers.Web3Provider(window.ethereum);
	const contract = new ethers.Contract(
		contractAddress,
		contractAbi.abi,
		provider,
	);

	const issued = await contract.publicIssued();
	const max = await contract.MAX_MINT();

	return { issued: issued.toString(), max: max.toString() };
}

function mintPokemonNft() {
	const provider = new ethers.providers.Web3Provider(window.ethereum);
	const signer = provider.getSigner();
	const contract = new ethers.Contract(
		contractAddress,
		contractAbi.abi,
		signer,
	);

	return contract.mintPokemon();
}

function subscribeToMintEvents(callback) {
	if (!window.ethereum) {
		return;
	}

	const provider = new ethers.providers.Web3Provider(window.ethereum);
	const wavePortalContract = new ethers.Contract(
		contractAddress,
		contractAbi.abi,
		provider,
	);

	wavePortalContract.on("NewMint", (from, tokenId) => {
		callback(from, tokenId.toString());
	});
}
