# StaticBase - Modern Website Generator

StaticBase is a bash script that generates a clean, modern website with index, about, contact pages, and a full blog system powered by:

- **Tailwind CSS** - Utility-first styling
- **Alpine.js** - Lightweight interactivity
- **Vite** - Lightning-fast builds
- **Markdown** - Easy content management

## Why StaticBase?

- **Simple** - No complex frameworks
- **Modern** - Latest tools (Vite, Tailwind, Alpine)
- **Fast** - Lightning-fast development and builds
- **Flexible** - Easy to customize and extend
- **Production-Ready** - Optimized builds
- **AI-Friendly** - Includes AGENTS.md for AI assistants

## Quick Start

### Create a new website

```bash
./create-staticbase.sh mywebsite
cd mywebsite
npm install
npm run dev
```

Your site is now running at **http://localhost:5173**

## What You Get

### Pages
- **Homepage** - Hero section with gradient background
- **About** - Company/personal information
- **Contact** - Interactive form with Alpine.js
- **Blog** - Markdown-based blog system

### Features
- Mobile-responsive navigation with hamburger menu
- Tailwind CSS styling throughout
- Alpine.js for interactivity
- 2 sample blog posts
- Production-ready build system
- SEO-friendly structure

### Project Structure

```
my-website/
├── content/blog/      # Blog posts (markdown)
├── templates/         # Page templates
├── lib/              # Helper functions
├── src/
│   ├── main.js       # Alpine.js initialization
│   └── style.css     # Tailwind CSS
├── public/images/    # Static assets
├── index.html        # Homepage
├── about.html        # About page
├── contact.html      # Contact form
├── base.html         # Layout template
├── vite.config.js    # Build config
├── README.md         # Project docs
└── AGENTS.md         # AI agent guidelines
```

### Add a Page

1. Create `newpage.html`
2. Add to `base.html` navigation
3. Add to `vite.config.js` pages array

## Deployment

Build your site:

```bash
npm run build
```

Deploy the `dist/` folder to:
- **Netlify** - Drag & drop
- **Vercel** - Git integration
- **GitHub Pages** - Free hosting
- **Cloudflare Pages** - Global CDN

## AI Agent Support

staticbase includes **AGENTS.md** - comprehensive guidelines for AI coding assistants. This file helps AI agents like Claude, ChatGPT, and others:

- Understand project structure
- Follow Tailwind/Alpine.js conventions
- Make appropriate architectural decisions
- Maintain code quality
- Avoid common mistakes

**Using AI assistants?** Point them to the `AGENTS.md` file in your generated project!

## Requirements

- Node.js v18+
- npm

## Technology Stack

- **Vite 7** - Next-generation build tool
- **Tailwind CSS 4** - Utility-first CSS
- **Alpine.js 3** - Minimal JavaScript framework
- **Marked** - Markdown to HTML
- **Gray Matter** - Frontmatter parser

## Resources

- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Alpine.js Documentation](https://alpinejs.dev/)
- [Vite Guide](https://vitejs.dev/guide/)
- [Markdown Guide](https://www.markdownguide.org/)

## Files Created

### Configuration
- `vite.config.js` - Build configuration
- `package.json` - Dependencies
- `.gitignore` - Git exclusions

### Content
- `content/blog/*.md` - Blog posts
- `templates/*.html` - Page templates

### Source
- `src/main.js` - JavaScript entry
- `src/style.css` - Tailwind CSS

### Pages
- `index.html` - Homepage
- `about.html` - About page
- `contact.html` - Contact form
- `base.html` - Layout template

### Documentation
- `README.md` - Project documentation
- `AGENTS.md` - AI agent guidelines

## License

MIT

---

**Made with love by Fathur Rahman**

*Create beautiful websites in seconds*
