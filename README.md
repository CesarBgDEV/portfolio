# César Balderas Guillén — Portfolio

Portfolio personal bilingüe (ES/EN) construido con Astro 4, desplegado con Docker + Nginx.

## Stack

- **Framework**: [Astro 4](https://astro.build) — SSG (Static Site Generator)
- **Estilos**: Bootstrap 5 + CSS custom properties
- **i18n**: Rutas manuales `/es/` y `/en/` sin dependencias externas
- **Deploy**: Docker multi-stage + Nginx Alpine
- **Dark/Light mode**: Toggle con `data-theme` en `<html>` y CSS custom properties

## Estructura

```
src/
├── components/
│   ├── Hero.astro
│   ├── About.astro
│   ├── Skills.astro
│   ├── Projects.astro
│   ├── Experience.astro
│   ├── Contact.astro
│   ├── Nav.astro
│   └── LangSwitcher.astro
├── layouts/
│   └── BaseLayout.astro
├── pages/
│   ├── index.astro       # Redirect por Accept-Language
│   ├── es/index.astro
│   └── en/index.astro
└── styles/
    └── global.css
scripts/
├── deploy.sh             # Primer deploy en servidor
└── update.sh             # Pull + rebuild
```

## Desarrollo local

```bash
npm install
npm run dev
# http://localhost:4321/es/
```

## Deploy en servidor (Digital Ocean)

### Primera vez

```bash
git clone https://github.com/CesarBgDEV/portfolio.git
cd portfolio
bash scripts/deploy.sh
```

### Actualizar

```bash
bash scripts/update.sh
```

## Variables de entorno

No se requieren variables de entorno. El sitio es completamente estático.

## Licencia

© 2026 César Balderas Guillén. Todos los derechos reservados.
