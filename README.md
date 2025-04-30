# Decentralized Identity and Knowledge Management Contract

A Clarity smart contract for decentralized identity registration, verification, content submission, and peer attestation on the Stacks blockchain.

## 📋 Overview

This smart contract provides a comprehensive solution for managing digital identities, building reputation, submitting knowledge content, and facilitating peer reviews—all in a decentralized manner on the Stacks blockchain.

## 🌟 Key Features

### 🔐 Identity Management

- **Register Identity**: Users can create their digital identity with name and email
- **Verify Identity**: Contract admin can verify user identities
- **Revoke Identity**: Admin can revoke verification status when necessary
- **Identity Attributes**: Extensible key-value store for additional identity metadata
- **Verification Status**: Public verification status checking

### 🏅 Reputation System

- **Reputation Scores**: Track user reputation through numerical scores
- **Admin-Controlled Updates**: Reputation adjustments managed by contract admin
- **Public Reputation Query**: Anyone can check a user's reputation

### 📚 Knowledge Submission

- **Content Creation**: Verified users can submit knowledge entries
- **Metadata Tracking**: Each entry includes author, timestamp, and status information
- **Status Management**: Content progresses through defined states (pending, approved, etc.)

### ✅ Peer Review System

- **Attestations**: Verified users can review and score content
- **Feedback Mechanism**: Reviews include numerical scores and text feedback
- **Timestamp Tracking**: All attestations are timestamped for accountability

## 🛠️ Technical Implementation

### Data Structures

The contract uses several map data structures to store information:

- `identities`: Stores user identity information
- `identity-attributes`: Flexible attribute storage for identities
- `content-entries`: Knowledge content submitted by users
- `attestations`: Peer reviews of content

### Error Codes

| Code | Description               |
|------|---------------------------|
| 100  | Access Denied             |
| 101  | Already Registered        |
| 102  | Item Not Found            |
| 104  | Identity Not Verified     |
| 105  | Not Owner                 |
| 106  | Invalid Score             |

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://docs.stacks.co/docs/clarity/clarinet/) - Local Clarity development environment
- Basic knowledge of [Clarity language](https://docs.stacks.co/docs/clarity/) and [Stacks blockchain](https://www.stacks.co/)

### Installation

1. Clone this repository
2. Navigate to the project directory
3. Use Clarinet to work with the contract:

```bash
# Check contract syntax
clarinet check

# Run contract tests
clarinet test

# Launch console for interactive testing
clarinet console
```

## 📖 Usage Examples

### Register a New Identity

```clarity
(contract-call? .decentralized-identity register-identity "Alice" "alice@example.com")
```

### Verify an Identity (Admin Only)

```clarity
(contract-call? .decentralized-identity verify-identity 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

### Submit Content

```clarity
(contract-call? .decentralized-identity submit-content "Understanding Blockchain" "Blockchain is a distributed ledger technology...")
```

### Make an Attestation

```clarity
(contract-call? .decentralized-identity make-attestation u1 u85 "Excellent content with good technical depth")
```

### Query Content Details

```clarity
(contract-call? .decentralized-identity get-content u1)
```

## 🔒 Security Considerations

- The contract uses principal-based authentication for all operations
- Admin functions are protected by tx-sender validation
- All critical operations require identity verification
- Input validation is performed for all public functions

## 🧪 Testing

The contract includes comprehensive test coverage. You can run the tests using Clarinet:

```bash
clarinet test
```

## 📄 License

[MIT License](LICENSE)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📬 Contact

For questions or support, please open an issue in the GitHub repository.
