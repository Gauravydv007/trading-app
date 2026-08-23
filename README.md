# CryptoTrader

A full-featured cryptocurrency trading simulator built with Flutter. Track live prices, manage a portfolio, buy/sell crypto, and deposit funds — all in a sleek dark-themed mobile UI.

---

## Screenshots

| Chart | Wallet | Trade |
|:-----:|:------:|:-----:|
| ![Chart](assets/scrennshots/Simulator%20Screenshot%20-%20iPhone%2016%20-%202026-03-17%20at%2012.24.05.png) | ![Wallet](assets/scrennshots/Simulator%20Screenshot%20-%20iPhone%2016%20-%202026-03-17%20at%2012.33.47.png) | ![Trade](assets/scrennshots/Simulator%20Screenshot%20-%20iPhone%2016%20-%202026-03-17%20at%2012.34.02.png) |

| Trade History | Deposit Funds |
|:-------------:|:-------------:|
| ![History](assets/scrennshots/Simulator%20Screenshot%20-%20iPhone%2016%20-%202026-03-17%20at%2012.34.17.png) | ![Deposit](assets/scrennshots/Simulator%20Screenshot%20-%20iPhone%2016%20-%202026-03-17%20at%2012.34.36.png) |

---

## Features

- **Live Price Chart** — Real-time BTC/USDT price with candlestick intervals (1M, 5M, 15M, 1H, 1D)
- **Portfolio Wallet** — View total portfolio value, USD balance, and individual coin holdings (BTC, ETH, SOL, DOGE, BNB)
- **Buy & Sell** — Trade any supported coin instantly using your USD balance
- **Trade History** — Full log of every buy and sell transaction with timestamps and prices
- **Deposit Funds** — Top up your account via Stripe with preset amounts ($25, $50, $100, $250) or a custom amount
- **Dark Theme** — Clean dark UI with green accent colors throughout

---

## Screens

| Screen | Description |
|--------|-------------|
| **Chart** | Home screen showing live Bitcoin price, a real-time price chart, and your current USD balance |
| **Wallet** | Overview of total portfolio value, P&L, USD balance, and all coin holdings |
| **Trade** | Buy or sell any supported cryptocurrency using your available USD balance |
| **Trade History** | Chronological list of all past buy/sell trades with amounts, quantities, and price at execution |
| **Deposit Funds** | Add funds to your account using Stripe payment integration |

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK
- iOS Simulator / Android Emulator or a physical device

### Installation

```bash
# Clone the repository
git clone https://github.com/SagorSamadder/crypto_trader.git
cd crypto_trader

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **Payments:** Stripe
- **State Management:** Flutter built-in state management
- **Charts:** Real-time price charting

---

## License

This project is for educational and portfolio purposes.
