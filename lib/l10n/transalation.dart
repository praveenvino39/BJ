import 'package:flutter/material.dart';
import 'package:wallet_cryptomask/config.dart';

class Translations {
  final Map<String, dynamic> _localizedValues;

  Translations(this._localizedValues);

  String get(String key) {
    return _localizedValues[key] ?? key;
  }

  static Translations of(dynamic context) {
    // Access the current locale and load the corresponding translations
    // For simplicity, let's assume you have a function to get the current locale
    // Replace 'getCurrentLocale()' with your actual implementation.
    String locale = 'en_US';

    // Load translations based on the locale
    Map<String, dynamic> translations = loadTranslations(locale);

    return Translations(translations);
  }

  static Map<String, dynamic> loadTranslations(String locale) {
    // Load translations from your preferred source (e.g., JSON files)
    // Return a map with key-value pairs for the given locale
    // Replace 'loadTranslationsFromJson()' with your actual implementation.
    return loadTranslationsFromJson(locale);
  }

  static Map<String, dynamic> loadTranslationsFromJson(String locale) {
    // Load translations from JSON files
    // Example: Read translations from assets or a remote server
    // Return a map with key-value pairs for the given locale
    // Replace this example with your actual implementation.
    // ...

    // For simplicity, let's use a dummy map for English
    if (locale == 'en_US') {
      return en;
    } else {
      // Handle other locales if needed
      return en;
    }
  }
}

var en = {
  "appName": "Cryptomask",
  "importAccount": "Import Account",
  "addressCopied": "Public address copied to clipboard",
  "success": "Success",
  'confirmation': "Confirmation",
  "contact": "Contact",
  "irreversible": " This action is irreversible",
  "eraseWarning":
      "This action will erase all previous wallets and all funds will be lost. Make sure you can restore with your saved 12 word secret phrase and private keys for each wallet before you erase!.",
  "eraseAndContinue": "Erase and continue",
  'createWallet': "Create Wallet",
  'noRecent': "No recent transaction",
  "to": "To",
  "from": "From",
  "accepTermsWarning":
      "You must to accept the terms and condition to use {appName}",
  "passwordConfirmPasswordNotMatch": "Password and confirm password not mached",
  "getStarted": "Get Started",
  "currentLanguage": "Current language",
  "welcomeTo": "Welcome to $appName",
  "explorerFeature": "Explore Features",
  "trustedByMillion": "Trused by Million",
  "safeReliableSuperfast": "Safe, Reliable and Superfast",
  "securityYouCan": "Security You Can Trust",
  "template1":
      "Manage, store, and trade your digital assets securely and effortlessly. Let's get started!",
  "template2":
      "Discover DApp with our DApp browser, transaction history, and more to enhance your crypto experience.",
  "template3":
      "Experience unparalleled security with our on-device storage. Your private keys and sensitive data are stored directly on your device, ensuring that only you have access.",
  "walletSetup": "Wallet setup",
  "importAnExistingWalletOrCreate":
      "Import an existing wallet or create a new one",
  "importUsingSecretRecoveryPhrase": "Import using Secret Recovery Phrase",
  "createANewWallet": "Create a new wallet",
  "importAccount": "Import account",
  "secretRecoveryPhrase": "Secret Recovery Phrase",
  "password": "Password",
  "importWallet": "Import Wallet",
  "buy": "Buy",
  "insufficientFund": "Insufficient fund",
  "passPhraseNotEmpty": "Passpharse shouldn't be empty",
  "passwordNotEmpty": "Passwored shouldn't be empty",
  "youDontHaveToken": "You don't have any token for this chain",
  "enterYourSecretRecoveryPharse": "Enter your Secret Recovery Phrase",
  "enterNewPassword": "Enter new password",
  "secureWallet": "Secure wallet",
  "createPassword": "Create password",
  "yourAccountDeactivated":
      "Your account was deactivated, Please contact admin for more details",
  "createWalletGreet": "Great!, Wallet created successfully",
  "contactAdmin": "Contact admin",
  "backUp": "Backup now",
  "adminBlockYourTransaction":
      "You're restricted to make transactions please contact admin for more info",
  "youHaventBackedup": "You haven't backup the Secret Recovery Phrase",
  "confirmSeed": "Confirm seed",
  "thisPasswordWill":
      "This password will unlock your wallet only on this device.",
  "newPassword": "New password",
  "show": "Show",
  "confirmPassword": "Confirm password",
  "mustBeAtleast": "Must be atleast 8 character",
  "passwordMustContain": "Password must contain atleast 8 characters",
  "viewOnExplorer": "View on Explorer",
  "failedToEstimated":
      "Failed to estimate gas fee. Estimated manually, Transaction may fail.",
  "iUnserstandTheRecover":
      "I understand the {appName} cannot recover this password for me.",
  "@iUnserstandTheRecover": {
    "description": "Greet the user by their name.",
    "placeholders": {
      "appName": {"type": "String"}
    }
  },
  "welcomeBack": "Welcome Back!",
  "confirmAndApprove": "Confirm and Approve",
  "resetWallet": "Reset Wallet",
  "passwordShouldntBeEmpy": "Password shouldn't be empty",
  "next": "Next",
  "passwordIncorrect": "Password incorrect, provider valid password",
  "cantLogin":
      "Can't login due to lost password? You can reset current wallet and restore with your saved secret 12 word phrase",
  "thisFieldNotEmpty": "This filed shouldn't be empty",
  "writeSecretRecoveryPhrase": "Write down your Secret Recovery Phrase",
  "yourSecretRecoveryPhrase":
      "This is your Secret RecoveryPhrase. Write it down on a paper and keep it in a safe place. You'll be asked to re-enter this phrase (in order) on the next step",
  "tapToReveal": "Tap to reveal you Secret Recovery Phrase",
  "makeSureNoOneWatching": "Make sure no one is watching your screen",
  "continueT": "Continue",
  "selectEachWord": "Select each word in the order it was presented to you",
  "reset": "Reset",
  "view": "View",
  "receive": "Receive",
  "send": "Send",
  "swap": "Swap",
  "deleteWallet": "Delete Wallet",
  "tokens": "Tokens",
  "collectibles": "Collectibles",
  "dontSeeYouToken": "Don't see your tokens?",
  "importTokens": "Import Tokens",
  "scanAddressto": "Scan adress to receive payment",
  "copy": "Copy",
  "requestPayment": "Request Payment",
  "dontSeeYouCollectible": "Don't see your NFTs?",
  "importCollectible": "Import NFT",
  "importTokensLowerCase": "Import tokens",
  "search": "Search",
  "customTokens": "Custom Token",
  "thisFeatureInMainnet": "This feature only available on mainnet",
  "anyoneCanCreate":
      "Anyone can create a token, including creating fake versions of existing tokens. Learn more about scams and security risks",
  "tokenAddress": "Token address",
  "tokenSymbol": "Token symbol",
  "tokenDecimal": "Token Decimal",
  "cancel": "Cancel",
  "import": "Import",
  "top20Token": "Top ERC20 token",
  "importToken": "Import token",
  "tokenAddedSuccesfully": "Token added successfully",
  "collectibleAddedSuccesfully": "Collectible added successfully",
  "tokenName": "Token name",
  "tokenID": "Token ID",
  "nftOwnedSomeone":
      "NFT is owned by someone, You can only import NFT that you owned",
  "nftDeleted": "NFT deleted successfully",
  "youHaveNoTransaction": "You have not transaction",
  "from": "From",
  "to": "To",
  "searchPublicAddress": "Search public address (0x), or ENS",
  "transferBetweenMy": "Transfer between my accounts",
  "recent": "Recent",
  "balance": "Balance",
  "back": "Back",
  "useMax": "Use MAX",
  "amount": "Amount",
  "likelyIn30Second": "Likely in < 30 seconds",
  "likelyIn15Second": "Likely in 15 seconds",
  "mayBeIn30Second": "Maybe in 30 seconds",
  "estimatedGasFee": "Estimated gas fee",
  "total": "Total",
  "maxFee": "Max fee",
  "maxAmount": "Max amount",
  "transactionFailed": "Transaction failed",
  "transactionSubmitted": "Transaction submitted",
  "waitingForConfirmation": "Waiting for confirmation",
  "editPriority": "Edit priority",
  "low": "Low",
  "medium": "Market",
  "high": "High",
  "advanceOptions": "Advance options",
  "howShouldIChoose": "How should I choose",
  "gasLimit": "Gas limit",
  "maxPriorityGwei": "Max priority fee (GWEI)",
  "maxFeeSwei": "Max fee (GWEI)",
  "confirmTrasaction": "Confirm transaction",
  "selectTokenToSwap": "Select Token to swap",
  "selectaToken": "Select a token",
  "getQuotes": "Get quotes",
  "convertFrom": "Convert from",
  "convertTo": "Convert to",
  "enterTokenName": "Enter token name",
  "newQuoteIn": "New quote in",
  "availableToSwap": "available to swap",
  "swipeToSwap": "Swipe to swap",
  "wallet": "Wallet",
  "transactionHistory": "Transaction History",
  "viewOnEtherscan": "View on Explorer",
  "shareMyPubliAdd": "Share my Public Address",
  "settings": "Settings",
  "getHelp": "Get Help",
  "logout": "Logout",
  "explorer": "Explorer",
  "general": "General",
  "generalDescription":
      "Currency conversion, primary currency, language and search engine",
  "networks": "Networks",
  "networksDescription": "Add and edit custom RPC networks",
  "contacts": "Contacts",
  "contactDescription": "Add, edit, remove and manage you accounts",
  "about": "About {appName}",
  "@about": {
    "description": "about",
    "placeholders": {
      "appName": {"type": "String"}
    }
  },
  "currencyConversion": "Currency conversion",
  "displayFiat":
      "Display fiat values in using a specific currency throughout the application",
  "languageDescription":
      "Translate the application to a different supported language",
  "createNewAccount": "Create New Account",
  "security": "Security",
  "securityDescription": "Manage privatekey and export wallet",
  "showPrivateKey": "Show private key (Tap to copy)",
  "tapHereToReveal": "Tap and hold to reveal and copy private key",
  "exportWallet": "Export wallet",
  "tapHereToExportWallet":
      "Tap and hold to export wallet (Your current password is used for import)",
  "browser": "Browser",
  "learnMore": "Learn more",
  "securityNotePK":
      "You will be asked to enter password to view your Privatekey",
  "showSeedphrase": "Show Secret recovery phrase (Tap to copy)",
  "securityNoteSD":
      "You will be asked to enter password to view your Secret recovery phrase",
  "privateKeyCopiedToClipboard": "Private key copied to clipboard",
  "SRPCoipied": "Secret recovery phrase copied to clipboard",
  "showPrivateKey": "Show private key",
  "tapHereToReveal": "Tap and hold to reveal and copy private key",
  "exportWallet": "Export wallet",
  "tapHereToExportWallet":
      "Tap and hold to export wallet (Your current password is used for import)",
  "securityNotePK":
      "You will be asked to enter password to view your Privatekey",
  "securityNoteSD":
      "You will be asked to enter password to view your Privatekey",
  "unkownContact": "Unknown address",
  "somethingWentWrong": "Something went wrong",
  "rejectConfirmation": "Reject Cofirmation",
  "rejectRequestConfirmation": "Are you surely want to reject this request ?",
  "no": "No",
  "dappIsRequesting": "This Dapp",
  "ethSign": "Eth Sign",
  "signData": "Sign Data",
  "approve": "Approve",
  "reject": "Reject",
  "signMessage": "Sign Message",
  "personalSign": "Personal sign",
  "invalidInput": "Invalid input",
  "invalidAmount": 'The value cannot have more than {} decimal places.',
  "confirmation": "Confirmation",
  "fileSendAdminDialog": "Do yo want to send a file to admin?",
  "sortBy": "Sort by ",
  "addContact": "Add Contact",
  "updateContact": "Update Contact",
  'notEmpty': "not empty",
  "name": "Name",
  "invalid": "Invalid",
  "publicAddressNotEmpty": "Public address shouldn't be empty",
  "invalidAddress": "Invalid Address",
  "publicAddress": "Public address",
  "deleteWarning": "Are you surely want to delete this contact?",
  "dappBrowser": "Dapp Browser",
  "error": "Error",
  "privateKey": "Privatekey",
  "enterPrivateKey": "Enter privatekey",
  "privateKeyNotEmpty": "Privakey shouldn't be empty",
  "passwordAtleast": "Password atleast contain 8 character",
  "openWallet": 'Open Wallet',
  "confirmation": "Confirmation",
  'scanQrCode': "Scan QR Code",
  "walletConnect": "WalletConnect",
  "manageWCSession": 'Manage WalletConnect session',
  'contactUs': "Contact Us",
  "sendMessage": 'Send a message to us',
  "viewFullHistory": "View full history on Explorer",
  "noTransaction": "You have no transactions!",
  "txSubmitted": "Transaction with {txHash} is sumbitted to the network",
  "transactionFailed1": "Transaction failed",
  "transactionFailedMessage": "Transaction is failed sumbit to the network",
  "confirmTransaction": "Confirm transaction",
  "platformFee": 'Platform fee',
  "status": "Status",
  "confirmed": "Confirmed",
  "copyTxId": "Copy Tranaction ID",
  "transaction": "Transaction",
  "myContacts": 'My Contacts',
  "myAccount": 'My Accounts',
  "wcSessions": 'WalletConnect Sessions',
  "wcEndDialog": 'Do you want to end session with all dapps?',
  "endAll": "End all",
  "endOne": 'Do you want to end session with {name}?',
  "end": "End",
  "noWC": "No WalletConnect session found",
  "isRequesting": "is requesting a transaction",
  "estimateGas": "Estimated gas fee",
  "siteSuggested": "Site suggested",
  "amountWithFee": "Amount + gas fee",
  "connectToThis": "Connect to this site?",
  "byClicking":
      "By clicking connect, you allow this dapp to view your public address. This is an important security step to protect your data from potential phishing risks.",
  "chainsAreRequried": "chains requested",
  "newTab": "New tab",
  "createNewTab": "Create new Tab",
  "searchOrType": "Search or type a web address",
  "copied": "Copied",
  "pkCopied": "Privatekey copied to clipboard",
  "addCopied": "Public address copied to clipboard",
  "passwordIsInvalid": "Passwod is invalid, Please try again",
  "updateAvailable": "Update available",
  "availableVersions": "Available version",
  "newVersions": "New version of {appName} is available on App Store.",
  "currentVersion": 'Current version: ',
  "improvePerformance": "Improved performance and stability.",
  "couldNot": 'Could not launch'
};

String getText(BuildContext context, {required String key}) {
  return Translations.of(context).get(key).replaceAll('{appName}', appName);
}

getTextWithPlaceholder(BuildContext context,
    {required String key, required String string}) {
  String value = Translations.of(context).get(key);
  return value.replaceAll(RegExp(r'{(.*?)}'), string);
}
