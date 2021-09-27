import React from "react";
import classNames from "classnames";

import openSeaLogo from "./assets/opensea-logo.svg";
import twitterLogo from "./assets/twitter-logo.svg";
import useWallet from "./hooks/useWallet";
import "./styles/spinner.css";
import "./styles/App.css";

const OPENSEA_LINK = "https://testnets.opensea.io/collection/pk-yellow-nft";

export default function App() {
	const {
		walletAccount,
		networkName,
		isRinkeby,
		writeLoading,
		connectWallet,
		mintLimit,
		mintedToken,
		mintNft,
	} = useWallet();

	return (
		<div className="App">
			<div className="container">
				<div className="header-container">
					<div>
						<img src="/android-chrome-192x192.png" alt="" />
					</div>
					<p className="header gradient-text">PK Yellow NFT</p>
					<p className="sub-text">
						Grab your starter Pokémon™ today.
						<br />
						Mint your NFTs on Rinkeby testnet for free,
						<br />
						all original images from Pokémon™ Yellow.
					</p>
					<div className="opensea-container">
						<a
							className="opensea-link"
							href={OPENSEA_LINK}
							target="_blank"
							rel="noopener noreferrer"
						>
							<img
								alt="OpenSea Logo"
								className="twitter-logo"
								src={openSeaLogo}
							/>
							<span>View collection on OpenSea</span>
						</a>
					</div>
					<Wallet
						account={walletAccount}
						networkName={networkName}
						isRinkeby={isRinkeby}
						connect={connectWallet}
					/>
					<MintLimit value={mintLimit} />
					<MintButton
						account={walletAccount}
						mint={mintNft}
						loading={writeLoading}
						disabled={!isRinkeby}
					/>
					<MintStatus token={mintedToken} />
				</div>
				<div className="footer-container footer-text">
					<div className="footer-row">
						All Pokémon™ character names and images are property of Nintendo
						<sup>&copy;</sup>.
					</div>
					<div className="footer-row">
						<img
							alt="Twitter Logo"
							className="twitter-logo"
							src={twitterLogo}
						/>
						built by&nbsp;
						<a
							className="footer-text"
							href=" https://twitter.com/tfmoliveira"
							target="_blank"
							rel="noopener noreferrer"
						>
							@tfmoliveira
						</a>
						&nbsp;with&nbsp;
						<a
							className="footer-text"
							href=" https://twitter.com/_buildspace"
							target="_blank"
							rel="noopener noreferrer"
						>
							@_buildspace
						</a>
					</div>
				</div>
			</div>
		</div>
	);
}

const Wallet = ({ account, networkName, isRinkeby, connect }) => {
	if (!account) {
		return (
			<button className="cta-button connect-wallet-button" onClick={connect}>
				Connect Wallet
			</button>
		);
	}

	return (
		<div className="wallet-connected">
			<div>
				<span className="green-dot" />
				<span>Wallet Connected</span>
			</div>
			<div>Account: {account}</div>
			<div
				className={classNames(
					"network",
					isRinkeby ? "networkValid" : "networkInvalid",
				)}
			>
				Network: <span className="networkName">{networkName}</span>
			</div>
			{!isRinkeby && (
				<div className="network networkInvalid">Please switch to Rinkeby</div>
			)}
		</div>
	);
};

const MintLimit = ({ value }) => {
	if (!value) {
		return null;
	}

	return (
		<div className="mint-limit">
			<div className="limit-header">Minted:</div>
			<div className="limit-value gradient-text">
				{value.issued}/{value.max}
			</div>
		</div>
	);
};

const MintButton = ({ account, mint, loading, disabled }) => {
	if (!account) {
		return null;
	}

	if (loading) {
		return (
			<div className="gradient-text">
				<Spinner />
				<div>Minting...</div>
			</div>
		);
	}

	return (
		<button
			className="cta-button connect-wallet-button"
			onClick={mint}
			disabled={disabled}
		>
			Mint NFT
		</button>
	);
};

function MintStatus({ token }) {
	if (!token) {
		return null;
	}

	return (
		<div>
			<p className="congrats">
				Congrats! You've minted the token #{token.tokenId}.
			</p>
			<p>
				<a
					className="nft-link"
					href={token.tokenUrl}
					target="_blank"
					rel="noopener noreferrer"
				>
					Click here to view it on OpenSea. It takes around to 5-10 minutes for
					it to show up.
				</a>
			</p>
		</div>
	);
}

function Spinner() {
	return (
		<div className="lds-ellipsis">
			<div></div>
			<div></div>
			<div></div>
			<div></div>
		</div>
	);
}
