import React from "react";

import twitterLogo from "./assets/twitter-logo.svg";
import useWallet from "./hooks/useWallet";
import "./styles/App.css";

// Constants
const OPENSEA_LINK = "";
const TOTAL_MINT_COUNT = 50;

export default function App() {
  const { walletAccount, connectWallet } = useWallet();

  return (
    <div className="App">
      <div className="container">
        <div className="header-container">
          <div>
            <img src="/android-chrome-192x192.png" alt="" />
          </div>
          <p className="header gradient-text">PK Yellow NFT</p>
          <p className="sub-text">Grab your starter Pokemon today.</p>
          <Wallet account={walletAccount} connect={connectWallet} />
        </div>
        <div className="footer-container footer-text">
          <img alt="Twitter Logo" className="twitter-logo" src={twitterLogo} />
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
  );
}

const Wallet = ({ account, connect }) => {
  if (!account) {
    return (
      <button className="cta-button connect-wallet-button" onClick={connect}>
        Connect to Wallet
      </button>
    );
  }

  return (
    <div className="wallet-connected">
      <div>
        <span className="green-dot" />
        <span>Wallet Connected</span>
      </div>
      <div>{account}</div>
    </div>
  );
};
