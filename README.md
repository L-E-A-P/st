# ST — Sferico Tetraedrico

Sito-satellite di [`leap/giuseppe`](https://github.com/l-e-a-p/giuseppe) dedicato
agli **strumenti d'invenzione del lavoro tetraedrico**: STONE, ston3s, tetrarec,
plugin e prototipi sviluppati nel contesto di **LEAP** (_Laboratorio
ElettroAcustico Permanente_).

Online: <https://www.leaphz.net/st/>

---

## Struttura del repo

```
st/
├── _grezzo/        archivio sorgente (raw originali, fuori dalla build Jekyll)
│   └── img/        foto eventi, cartella per evento (es. 2023-09-10-CASA-ARGILLA-PELANDA/)
├── docs/           sito Jekyll (deploy GitHub Pages da /docs)
├── src/            script e codice di gestione del repo
└── ref/            riferimenti, bibliografia, materiale di studio
```

`_grezzo/` è la **quarantena**: contiene le sorgenti originali (HEIC pesanti,
documenti, ecc.). Niente di quanto sta lì dentro viene servito dal sito; le
versioni web-ready vivono in `docs/assets/`.

---

## Sito Jekyll (`docs/`)

```
docs/
├── _config.yml
├── _includes/
│   └── gallery.html        include riusabile per gallerie con lightbox
├── _data/
│   ├── authors.yml         anagrafica autori (chiave → metadata)
│   └── navigation.yml      voci della navbar
├── _posts/                 post (gallerie, note, articoli)
├── _stone/ _stoned/ _tetrarec/   collection una per progetto-strumento
├── assets/img/eventi/      gallerie pubblicate, una sottocartella per evento
└── index.md                home (layout: blog, lista post in coda)
```

### Sviluppo locale

```bash
cd docs
bundle install       # solo la prima volta
bundle exec jekyll serve
# → http://localhost:4000/st/
```

### Deploy

GitHub Pages è configurato su **branch `master`, folder `/docs`**.
Ogni `git push` ribuilda automaticamente. Il `baseurl` è `/st`.

---

## Gestione foto e gallerie

### Convenzione

Una **cartella per evento** in `_grezzo/img/`, nominata
`AAAA-MM-GG-NOME-EVENTO/`. Dentro, foto sorgente di qualsiasi tipo
(HEIC, JPG, JPEG, PNG).

### Pipeline automatica

Lo script `src/build-gallery.sh` converte una cartella di `_grezzo/img/` in
una galleria pubblicata:

```bash
./src/build-gallery.sh <folder_name> <YYYY-MM-DD> <slug> "<Titolo>"
```

Esempio:

```bash
./src/build-gallery.sh 2023-09-10-CASA-ARGILLA-PELANDA \
                       2023-09-10 \
                       casa-argilla-pelanda \
                       "Casa Argilla — Pelanda"
```

Effetti:

- Converte HEIC → JPG (`sips`), copia JPG/JPEG/PNG, normalizza i nomi in
  lowercase e l'estensione a `.jpg`.
- Resize a max **1600 px** lato lungo, qualità 85 → `docs/assets/img/eventi/<data-slug>/full/`
- Genera thumb a max **400 px**, qualità 80 → `docs/assets/img/eventi/<data-slug>/thumb/`
- Crea il post `docs/_posts/<data>-<slug>.md` (non sovrascrive se esiste).

Lo script è **idempotente**: rilanciato sulla stessa cartella, riprocessa
solo i file mancanti. Per aggiungere foto a una galleria esistente, copiale
in `_grezzo/img/<cartella>/` e rilancia lo stesso comando.

### Galleria nel post

Il post generato è minimale:

```markdown
---
title: "Casa Argilla — Pelanda"
date: 2023-09-10
categories: [gallery]
gallery_path: /assets/img/eventi/2023-09-10-casa-argilla-pelanda/
---

{% include gallery.html path=page.gallery_path %}
```

L'include `gallery.html`:
- scopre automaticamente le immagini in `<path>thumb/` via `site.static_files`,
- ricostruisce l'URL del full sostituendo `/thumb/` con `/full/`,
- rende una griglia quadrata via CSS (`aspect-ratio:1; object-fit:cover`),
- aggancia [GLightbox](https://github.com/biati-digital/glightbox) via CDN
  per la navigazione fullscreen (frecce, swipe, ESC).

Per cambiare aspetto della griglia (rettangolare, masonry, dimensioni tile)
basta modificare il CSS dentro l'include — **nessuna immagine va rigenerata**.

### Dipendenze locali

Lo script richiede:

- `sips` (incluso in macOS, conversione HEIC)
- `magick` ([ImageMagick](https://imagemagick.org/), resize)

Su macOS:

```bash
brew install imagemagick
```

---

## Convenzioni autori

Gli autori dei post sono definiti una sola volta in `docs/_data/authors.yml`:

```yaml
Giuseppe:
  name: Giuseppe Silvi
  picture: /images/gs.jpg
  bio: "..."
```

Nel front matter dei post: `author: Giuseppe` (l'id, non il nome). Il default
globale in `_config.yml` è `Giuseppe`, quindi non serve scriverlo nei post a
meno che l'autore non sia diverso.

---

## Continuità con `leap/giuseppe`

ST è formalmente sotto `leap/`, ma concettualmente è un **figlio di
giuseppe**: stesso tema (`L-E-A-P/so-leap-theme`), stesso skin, stesso logo
(`gs.jpg`), navbar che cita LEAP e Giuseppe come prime voci. L'utente
attraversa i due siti senza percepire un confine.

---

## TODO / Roadmap

- [ ] Sistemare le date approssimate dei post `ston3s` e `pax-pelanda`.
- [ ] Recuperare la cartella `2018-28-29-30-venezia` (manca il mese nel nome).
- [ ] Documentare e popolare `src/` con i codici sorgenti dei plugin/strumenti.
- [ ] Documentare e popolare `ref/` con il materiale di riferimento.
- [ ] Allineare la navbar tra `giuseppe` e `st` per continuità visiva.
