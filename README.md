# deception

Web app Vue per configurare una partita di **Deception**:

- prompt iniziale con numero giocatori, nomi e numero armi per giocatore
- distribuzione casuale di armi **univoche** tra tutti i giocatori
- ogni arma mostra categoria e colore categoria
- clic su arma per segnarla come disabilitata
- stato partita salvato in `localStorage` (cache browser)

## Avvio locale

```bash
npm install
npm run dev
```

## Build produzione

```bash
npm run build
```

## Verifiche anti-pubblicazione rotta

Esegui questo script prima di pubblicare:

```bash
npm run publish:guard
```

In CI/GitHub Actions viene usato:

```bash
npm run ci:check
```

La pubblicazione su GitHub Pages avviene solo se i controlli passano.

La configurazione Vite usa `base: '/deception/'` per pubblicazione su GitHub Pages.
