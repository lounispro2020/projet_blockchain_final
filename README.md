# Guide : Déployer la dApp

Ce document couvre l'installation du smart contract et de son IHM dans le cadre d'un déploiement en local.

## Pré-requis windows

### Installer WSL 2
Dans un terminal powershell :
```powershell
wsl --install
```

Pour vérifier la version WSL installé, dans un terminal powershell :
```powershell
wsl -l -v
```

Assurez-vous que la colonne `VERSION` pour la distribution installée contienne la valeur 2.
Sinon tapez:
```powershell
wsl --set-version <distro name> 2
```

Pour ouvrir le wsl, tapez:
```powershell
wsl
```

A partir de là, tous les terminaux dont nous parlerons devront être ouvert avec le wsl dans le cadre d'un déploiement sur un système Windows.

### Installer les dépendances

#### Installer Nodejs

Pour installer nodejs:
```bash
sudo apt update
sudo apt upgrade
sudo apt-get install curl
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs
```

#### Installer les dépendances du Smart contract

Mettez-vous dans le dossier `voting-sessions` et tapez:
```bash
npm i
```

Ensuite allez dans le dossier

#### Installer les dépendances de l'IHM

Mettez-vous dans le dossier `next-voting-sessions` et tapez:
```bash
npm i
```

## Déployer votre smart contract en local

Ce tutoriel explique comment déployer un smart contract localement en utilisant [Hardhat](https://hardhat.org/) dans une configuration minimale :

### 1. Compiler le contrat

Dans le dossier `voting-sessions`, à la racine du projet, exécutez :

```bash
npx hardhat compile
```

Hardhat va compiler votre contrat et placer les artifacts dans un dossier `artifacts/.`

### 2. Démarrer un noeud local Hardhat

Dans un premier terminal :
```bash
npx hardhat node
```
- Cela lance un noeud Ethereum local sur `http://127.0.0.1:8545`
- Hardhat va aussi générer plusieurs comptes de test pré-chargés en Ether (fictif).
- Il faut laisser le terminal ouvert.

### 3. Deployer le contrat

Dans un terminal :
```bash
npx hardhat ignition deploy --network localhost ignition/modules/voting.js
```

La terminal affichera quelque chose comme: `VotingModule#VotingSessions - 0x5FbDB2315678afecb367f032d93F642f64180aa3`

Copiez la partie qui commence par `0x` dans notre cas on copiera `0x5FbDB2315678afecb367f032d93F642f64180aa3`, nous en aurons besoin par la suite.

## Déployer votre IHM en local

### Configurer l'application

Ouvrez le fichier `next-voting-sessions/src/config.js`.

Dans la variable `CONTRACT_ADDRESS`, collez l'adresse précédemment copiée.

Pour la variable `CONTRACT_ABI`, ouvrez le fichier `voting-sessions/artifacts/contracts/VotingSessions.sol/VotingSessions.json`.

Copiez le contenu de la variable `abi` et collez le dans la variable `CONTRACT_ABI` de notre fichier de configuration.

### Lancer le serveur web

Pour lancer le serveur web, mettez-vous à la racine du projet `next-voting-sessions` et tapez:
```bash
npm run dev
```

Après quelques secondes d'attentes vous pouvez vous rendre sur votre navigateure à l'adresse `http://localhost:3000`.
Veillez à avoir l'extension MetaMask d'installé et d'y avoir configuré votre réseau local ainsi que des comptes virtuels.