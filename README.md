# 🏅 SmartFlow

**Rewards Hub** is a decentralized application (dApp) that allows users to claim periodic token rewards based on real-time market conditions. Users can claim **FLW tokens every 24 hours**, only if the **ETH/USD price is below a configurable threshold**, fetched on-chain via Chainlink oracles.

The project demonstrates a full end-to-end Web3 architecture: smart contracts deployed on **Arbitrum One**, oracle integration, secure reward distribution, and a modern frontend built with **Next.js, wagmi, viem, and RainbowKit**.

This dApp was built as a production-oriented project, focusing on real mainnet deployment, UX considerations, and best practices across both smart contracts and frontend development.

## ✨ Features

- 🎁 **Daily Reward Claims**: users can claim **FLW tokens every 24 hours**.
- 📉 **Price-Gated Rewards**: rewards are only claimable when the **ETH/USD price is below a configurable threshold**.
- 🔗 **Chainlink Oracles**: real-time ETH/USD price fetched on-chain using Chainlink data feeds.
- ⏱️ **Cooldown Enforcement**: per-user cooldown tracked on-chain to prevent multiple claims within the same period.
- 🪙 **Custom ERC20 Token (FLW)**: reward token fully controlled by the protocol.
- 🛡️ **Reentrancy & Pausable Protection**: critical functions protected using OpenZeppelin security patterns.
- 👑 **Owner Controls**: owner can update threshold, reward amount, and cooldown parameters.
- 📊 **Membership Levels**: user tier (Basic, Silver, Gold, Elite) derived from accumulated FLW balance.
- 🔄 **Live UI Updates**: frontend reflects claim availability, countdowns, and balances in real time.
- 🌐 **Mainnet Deployment**: contracts deployed and tested on **Arbitrum One** mainnet.

## 🔥 Live Demo

👉 [https://smartflow.vercel.app/](https://smartflow.vercel.app/)

## 🏗️ Design and Architecture Patterns

- **Clear Separation of Concerns**: reward logic, oracle checks, cooldown tracking, and admin configuration are cleanly separated.
- **Oracle-driven Architecture**: reward eligibility is dynamically gated by on-chain ETH/USD price data.
- **CEI Pattern**: all external functions follow the Checks-Effects-Interactions pattern to reduce attack surface.
- **Gas-efficient mappings**: per-user state (last claim timestamp) stored using direct mappings.
- **Composable Frontend Architecture**: clear separation between hooks, UI components, and layout.
- **Hydration-safe UI**: client-only logic carefully guarded to avoid SSR hydration mismatches in Next.js.
- **Contract-first design**: frontend strictly reflects on-chain state without off-chain assumptions.

## 🔐 Security Measures

- 🔮 **Hardened Oracle Design**: dual Chainlink price feeds with staleness checks and automatic fallback to mitigate oracle failures, downtime, and manipulation risks.
- 🔑 **Access Control**: critical configuration functions (`setThreshold`, `setRewardAmount`, `setCooldown`) are restricted using `onlyOwner`.
- 🪙 **SafeERC20 Transfers**: all ERC20 operations use OpenZeppelin’s `SafeERC20` to safely handle non-standard tokens.
- 🛡️ **Reentrancy Protection**: reward claiming is protected with `ReentrancyGuard`.
- ⏸️ **Emergency Pause**: contract can be paused by the owner to mitigate unexpected situations.
- 📢 **Event Emission**: all relevant state changes emit events (`RewardClaimed`, `Paused`, `Unpaused`) for transparency and monitoring.
- 🧪 **Testing with Foundry**: core contract logic validated using unit tests and fork-based testing.

## 🧪 Tests

Complete test suite written in **Foundry**, achieving **100% line and function coverage** on the core contract logic, with **67% branch coverage**.
The remaining uncovered branches correspond to the secondary oracle fallback path, which mirrors the primary price feed logic and is functionally equivalent.

### Coverage Results:

```bash

Ran 1 test suite in 281.19ms (4.38ms CPU time): 21 tests passed, 0 failed, 0 skipped (21 total tests)

╭------------------------+-----------------+-----------------+----------------+----------------╮
| File                   | % Lines         | % Statements    | % Branches     | % Funcs        |
+==============================================================================================+
| src/SmartFlow.sol      | 100.00% (44/44) | 100.00% (37/37) | 67.86% (19/28) | 100.00% (8/8)  |
╰------------------------+-----------------+-----------------+----------------+----------------╯

# Run all tests
forge test

# Run specific test
forge test -vvvv --match-test test_claimMyReward

# Check coverage
forge coverage
```

## 🧠 Technologies Used

### Smart Contracts & Blockchain

- ⚙️ **Solidity** (`^0.8.24`) – core smart contract development
- 🧪 **Foundry** – development framework for testing, scripting, fuzzing and deployment
- 📚 **OpenZeppelin Contracts** – `ERC20`, `Ownable`, `ReentrancyGuard`, `SafeERC20`, `Pausable`
- 🔗 **Chainlink Oracles** – ETH/USD price feeds with primary + secondary fallback
- ⛓️ **Arbitrum One** – low-cost, production-grade L2 deployment

### Frontend & Web3

- ⚛️ **Next.js (App Router)** – modern React framework with server/client separation
- ⚛️ **React** + **TypeScript** – typed component-based UI
- 🔌 **wagmi** + **viem** – Ethereum hooks and low-level EVM interaction
- 🦄 **RainbowKit** – wallet connection UX
- 🔄 **TanStack Query** – on-chain data fetching, caching and refetching
- 🎨 **Tailwind CSS** – utility-first styling
- 🧩 **shadcn/ui** – accessible, composable UI components
- 🔔 **Sonner** – toast notifications for transaction feedback

### Tooling & Infra

- 🌐 **Infura RPC** – mainnet blockchain access
- 🔸 **Vercel** – frontend deployment and hosting
- 💅 **Lovable** – UI/UX design inspiration and layout system

## 🚀 Future Improvements

- 🛠️ **Admin Panel**: dedicated owner-only interface to manage protocol parameters (`threshold`, `rewardAmount`, `cooldown`) directly from the frontend.
- ✍️ **Delegated Claims (EIP-712)**: support for gasless or delegated reward claims using typed structured data signatures, preventing replay attacks and enabling secure off-chain authorizations.
- 🏆 **Public User Ranking**: on-chain leaderboard showcasing the most rewarded users based on accumulated FLOW tokens.
- 👑 **Elite Members Showcase**: dedicated section highlighting top-tier users who reached the highest membership level.
- 📊 **Advanced Analytics**: historical claim data, reward distribution statistics, and oracle price tracking.

## 📜 License

This project is licensed under the MIT License.
