import 'package:flutter/material.dart';

class Translations {
  Map<String, dynamic> _localizedValues;

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
      return es;
    }
  }
}

var en = {
  "appName": "Phimask",
  'createWallet': "Create Wallet",
  "accepTermsWarning":
      "You must to accept the terms and condition to use {appName}",
  "passwordConfirmPasswordNotMatch": "Password and confirm password not mached",
  "getStarted": "Get Started",
  "currentLanguage": "Current language",
  "trustedByMillion": "Trused by Million",
  "safeReliableSuperfast": "Safe, Reliable and Superfast",
  "youKeyToExploreWeb3": "Your key to explore Web3",
  "template1":
      "Here you can write the description of the page,  to explain something...",
  "template2":
      "Here you can write the description of the page,  to explain something...",
  "template3":
      "Here you can write the description of the page,  to explain something...",
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
  "enterYourSecretRecoveryPharse": "Enter your Secret Recovery Phrase",
  "enterNewPassword": "Enter new password",
  "secureWallet": "Secure wallet",
  "createPassword": "Create password",
  "confirmSeed": "Confirm seed",
  "thisPasswordWill":
      "This password will unlock your wallet only on this device.",
  "newPassword": "New password",
  "show": "Show",
  "confirmPassword": "Confirm password",
  "mustBeAtleast": "Must be atleast 8 character",
  "passwordMustContain": "Password must contain atleast 8 characters",
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
  "confirmAndApprove": "Confirm and Approve",
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
  "showPrivateKey": "Show private key",
  "tapHereToReveal": "Tap and hold to reveal and copy private key",
  "exportWallet": "Export wallet",
  "tapHereToExportWallet":
      "Tap and hold to export wallet (Your current password is used for import)",
  "browser": "Browser",
  "learnMore": "Learn more"
};

var es = {
  "appName": "Phimask",
  "getStarted": "Comenzar",
  "currentLanguage": "Idioma actual",
  "trusedByMillion": "Trused por millones",
  "safeReliableSuperfast": "Seguro, fiable y superrápido",
  "youKeyToExploreWeb3": "Su clave para explorar Web3",
  "template1":
      "Aquí puedes escribir la descripción de la página, para explicar algo...",
  "template2":
      "Aquí puedes escribir la descripción de la página, para explicar algo...",
  "template3":
      "Aquí puedes escribir la descripción de la página, para explicar algo...",
  "walletSetup": "Configuración de la cartera",
  "importAnExistingWalletOrCreate":
      "Importar un monedero existente o crear uno nuevo",
  "importUsingSecretRecoveryPhrase":
      "Importar usando frase de recuperación secreta",
  "createANewWallet": "Crear un nuevo monedero",
  "importAccount": "Importar cuenta",
  "buy": "comprar",
  "secretRecoveryPhrase": "Frase de recuperación secreta",
  "password": "Contraseña",
  "importWallet": "Importar monedero",
  "passPhraseNotEmpty": "Passpharse no debe estar vacío",
  "passwordNotEmpty": "Passwored no debe estar vacío",
  "enterYourSecretRecoveryPharse": "Ingrese su frase de recuperación secreta",
  "enterNewPassword": "Introduzca una nueva contraseña",
  "secureWallet": "Monedero seguro",
  "createPassword": "Crear contraseña",
  "confirmSeed": "Confirmar semilla",
  "thisPasswordWill":
      "Esta contraseña desbloqueará su billetera solo en este dispositivo.",
  "newPassword": "Nueva contraseña",
  "show": "Mostrar",
  "confirmPassword": "Confirmar contraseña",
  "mustBeAtleast": "Debe tener al menos 8 caracteres",
  "passwordMustContain": "La contraseña debe contener al menos 8 caracteres",
  "iUnserstandTheRecover":
      "Entiendo que {appName} no puede recuperar esta contraseña por mí.",
  "@iUnserstandTheRecover": {
    "description": "Entiendo que",
    "placeholders": {
      "appName": {"type": "String"}
    }
  },
  "thisFieldNotEmpty": "Este archivo no debe estar vacío",
  "writeSecretRecoveryPhrase": "Escriba su frase secreta de recuperación",
  "yourSecretRecoveryPhrase":
      "Esta es tu frase secreta de recuperación. Escríbelo en un papel y guárdalo en un lugar seguro. Se te pedirá que vuelvas a introducir esta frase (en orden) en el siguiente paso",
  "tapToReveal": "Toque para revelar su frase de recuperación secreta",
  "makeSureNoOneWatching": "Asegúrate de que nadie esté mirando tu pantalla",
  "continueT": "Continuar",
  "selectEachWord": "Seleccione cada palabra en el orden en que se le presentó",
  "reset": "Restablecimiento",
  "view": "Vista",
  "receive": "Recibir",
  "send": "Enviar",
  "swap": "Intercambio",
  "tokens": "Fichas",
  "collectibles": "Coleccionables",
  "dontSeeYouToken": "¿No ves tus tokens?",
  "importTokens": "Importar tokens",
  "scanAddressto": "Scan adress para recibir el pago",
  "copy": "Copiar",
  "requestPayment": "Solicitar pago",
  "dontSeeYouCollectible": "¿No ves tus NFT?",
  "importCollectible": "Importar NFT",
  "importTokensLowerCase": "Importar tokens",
  "search": "Buscar",
  "customTokens": "Token personalizado",
  "thisFeatureInMainnet":
      "Esta función solo está disponible en la red principal",
  "anyoneCanCreate":
      "Cualquiera puede crear un token, incluida la creación de versiones falsas de tokens existentes. Más información sobre estafas y riesgos de seguridad",
  "tokenAddress": "Dirección del token",
  "tokenSymbol": "Símbolo de token",
  "tokenDecimal": "Token Decimal",
  "cancel": "Cancelar",
  "import": "Importación",
  "top20Token": "Mejor token ERC20",
  "importToken": "Importar token",
  "tokenAddedSuccesfully": "Token agregado correctamente",
  "collectibleAddedSuccesfully": "Coleccionable agregado correctamente",
  "tokenName": "Nombre del token",
  "tokenID": "Token ID",
  "nftOwnedSomeone":
      "NFT es propiedad de alguien, solo puede importar NFT que usted poseía",
  "nftDeleted": "NFT eliminado correctamente",
  "youHaveNoTransaction": "No ha realizado ninguna transacción",
  "from": "De",
  "to": "Para",
  "searchPublicAddress": "Buscar dirección pública (0x) o ENS",
  "transferBetweenMy": "Transferencia entre mis cuentas",
  "recent": "Reciente",
  "balance": "Equilibrar",
  "back": "Atrás",
  "useMax": "Usar MAX",
  "amount": "Importe",
  "likelyIn30Second": "Probablemente en < 30 segundos",
  "likelyIn15Second": "Probable en 15 segundos",
  "mayBeIn30Second": "Tal vez en 30 segundos",
  "estimatedGasFee": "Tarifa de gas estimada",
  "total": "Total",
  "maxFee": "Tarifa máxima",
  "maxAmount": "Cantidad máxima",
  "transactionFailed": "Error en la transacción",
  "transactionSubmitted": "Transacción enviada",
  "confirmAndApprove": "Confirmar y aprobar",
  "waitingForConfirmation": "A la espera de confirmación",
  "editPriority": "Editar prioridad",
  "low": "Bajo",
  "medium": "Mercado",
  "high": "Alto",
  "advanceOptions": "Opciones anticipadas",
  "howShouldIChoose": "¿Cómo debo elegir?",
  "gasLimit": "Límite de gas",
  "maxPriorityGwei": "Tarifa de prioridad máxima (GWEI)",
  "maxFeeSwei": "Tarifa máxima (GWEI)",
  "confirmTrasaction": "Confirmar transacción",
  "selectTokenToSwap": "Seleccione Token para intercambiar",
  "SelectAToken": "Seleccionar un token",
  "getQuotes": "Obtener cotizaciones",
  "convertFrom": "Convertir desde",
  "convertTo": "Convertir a",
  "enterTokenName": "Introduzca el nombre del token",
  "newQuoteIn": "Nueva cotización en",
  "availableToSwap": "disponible para intercambiar",
  "swipeToSwap": "Deslizar para intercambiar",
  "wallet": "Billetera",
  "transactionHistory": "Historial de transacciones",
  "viewOnEtherscan": "Ver en Explorer",
  "shareMyPubliAdd": "Compartir mi megafonía",
  "settings": "Configuración",
  "getHelp": "Obtener ayuda",
  "logout": "Cerrar sesión",
  "explorer": "Explorador",
  "general": "General",
  "generalDescription":
      "Conversión de moneda, moneda principal, idioma y motor de búsqueda",
  "networks": "Redes",
  "networksDescription": "Agregar y editar redes RPC personalizadas",
  "contacts": "Contactos",
  "contactDescription": "Agregue, edite, elimine y administre sus cuentas",
  "about": "cerca de {appName}",
  "@about": {
    "description": "cerca de",
    "placeholders": {
      "appName": {"type": "String"}
    }
  },
  "currencyConversion": "Conversión de moneda",
  "displayFiat":
      "Mostrar valores fiduciarios en el uso de una moneda específica en toda la aplicación",
  "languageDescription":
      "Traducir la aplicación a un idioma compatible diferente",
  "createNewAccount": "Crear nueva cuenta",
  "securityDescription": "Gestionar clave privada y exportar billetera",
  "security": "seguridad",
  "showPrivateKey": "Show private key",
  "tapHereToReveal": "Tap and hold to reveal and copy private key",
  "exportWallet": "Export wallet",
  "tapHereToExportWallet":
      "Tap and hold to export wallet (Your current password is used for import)"
};

String getText(BuildContext context, {required String key}) {
  return Translations.of(context).get(key);
}

getTextWithPlaceholder(BuildContext context,
    {required String key, required String string}) {
  String value = Translations.of(context).get(key);
  return value.replaceAll(RegExp(r'{(.*?)}'), string);
}
