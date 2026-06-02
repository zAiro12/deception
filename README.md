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

La configurazione Vite usa `base: '/deception/'` per pubblicazione su GitHub Pages.
