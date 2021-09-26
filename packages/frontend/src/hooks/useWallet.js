import { useCallback, useEffect, useMemo, useState } from "react";
import { ethers } from "ethers";

import wavePortalAbi from "@pkyellow/contract/rinkeby/abi.json";
import contractAddress from "@pkyellow/contract/rinkeby/address.json";
import useWindowFocus from "./useWindowFocus";

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
				updateValues();
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
	console.log({ accountList });
	return accountList.length !== 0;
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
		wavePortalAbi.abi,
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
		wavePortalAbi.abi,
		signer,
	);

	return contract.mintPokemon();
}
