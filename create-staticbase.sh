#!/bin/bash

# staticbase - Simple Website Generator
# Creates a basic website with index, about, contact, and blog pages
# Powered by Vite, Tailwind CSS, and Alpine.js

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get project name from argument or use default
PROJECT_NAME="${1:-mystaticbase}"
PROJECT_PATH="./$PROJECT_NAME"

echo -e "${BLUE}🚀 Creating staticbase project: ${PROJECT_NAME}${NC}"

# Check if directory exists
if [ -d "$PROJECT_PATH" ]; then
  echo -e "${RED}❌ Error: Directory already exists: ${PROJECT_NAME}${NC}"
  exit 1
fi

# Create project structure
echo -e "${GREEN}📁 Creating directories...${NC}"
mkdir -p "$PROJECT_PATH"/{src,public/images,content/blog,templates,lib}

# Create package.json
cat > "$PROJECT_PATH/package.json" << 'EOF'
{
  "name": "PROJECT_NAME_PLACEHOLDER",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "alpinejs": "^3.15.3",
    "vite": "^7.3.1"
  },
  "devDependencies": {
    "@tailwindcss/vite": "^4.1.18",
    "@tailwindcss/typography": "^0.5.13",
    "gray-matter": "^4.0.3",
    "marked": "^17.0.1",
    "tailwindcss": "^4.1.18",
    "vite-plugin-virtual-mpa": "^1.12.1"
  }
}
EOF
sed -i.bak "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/" "$PROJECT_PATH/package.json" && rm "$PROJECT_PATH/package.json.bak"

# Create .gitignore
cat > "$PROJECT_PATH/.gitignore" << 'EOF'
node_modules/
dist/
.DS_Store
.env
.env.local
*.log
EOF

# Create vite.config.js
cat > "$PROJECT_PATH/vite.config.js" << 'EOFVITE'
import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";
import { createMpaPlugin } from "vite-plugin-virtual-mpa";
import { resolve } from "path";
import { readFileSync } from "fs";
import { getContentFromDirectory, formatDate } from "./lib/content.js";
import { generateBlogCard } from "./lib/templates.js";

const __dirname = resolve();

const blogDir = resolve(__dirname, "content/blog");
const blogPosts = getContentFromDirectory(blogDir, {
  sortBy: "date",
  order: "desc",
});

const recentBlogPosts = blogPosts.slice(0, 3);

const blogListTemplate = readFileSync(
  resolve(__dirname, "templates/blog-list.html"),
  "utf-8"
);
const blogPostTemplate = readFileSync(
  resolve(__dirname, "templates/blog-post.html"),
  "utf-8"
);

const indexContent = readFileSync(resolve(__dirname, "index.html"), "utf-8");
const aboutContent = readFileSync(resolve(__dirname, "about.html"), "utf-8");
const contactContent = readFileSync(resolve(__dirname, "contact.html"), "utf-8");

function generateBlogListContent() {
  const cardsHtml = blogPosts
    .map((post) => generateBlogCard(post))
    .join("\n");
  return blogListTemplate.replace("<%- blogCards %>", cardsHtml);
}

function generateBlogPostContent(post) {
  const { frontmatter, content } = post;
  const dateFormatted = formatDate(frontmatter.date);

  return blogPostTemplate
    .replace(/<%=\s*title\s*%>/g, frontmatter.title)
    .replace(/<%=\s*date\s*%>/g, dateFormatted)
    .replace(/<%-\s*content\s*%>/g, content);
}

function generateHomepageContent() {
  const recentBlogHtml = recentBlogPosts
    .map((post) => generateBlogCard(post))
    .join("\n");

  return indexContent.replace("<%- recentBlogPosts %>", recentBlogHtml);
}

const pages = [
  {
    name: "index",
    entry: "/src/main.js",
    data: {
      title: "Home - PROJECT_NAME_PLACEHOLDER",
      description: "Welcome to my website",
      activePage: "home",
      content: generateHomepageContent(),
    },
  },
  {
    name: "about",
    entry: "/src/main.js",
    data: {
      title: "About - PROJECT_NAME_PLACEHOLDER",
      description: "Learn more about us",
      activePage: "about",
      content: aboutContent,
    },
  },
  {
    name: "contact",
    entry: "/src/main.js",
    data: {
      title: "Contact - PROJECT_NAME_PLACEHOLDER",
      description: "Get in touch",
      activePage: "contact",
      content: contactContent,
    },
  },
  {
    name: "blog",
    entry: "/src/main.js",
    data: {
      title: "Blog - PROJECT_NAME_PLACEHOLDER",
      description: "Read our latest posts",
      activePage: "blog",
      content: generateBlogListContent(),
    },
  },
  ...blogPosts.map((post) => ({
    name: `blog-${post.slug}`,
    filename: `blog/${post.slug}.html`,
    entry: "/src/main.js",
    data: {
      title: `${post.frontmatter.title} - PROJECT_NAME_PLACEHOLDER`,
      description: post.frontmatter.description,
      activePage: "blog",
      content: generateBlogPostContent(post),
    },
  })),
];

const rewrites = [
  ...blogPosts.map((post) => ({
    from: new RegExp(`^/blog/${post.slug}(\\.html)?$`),
    to: `/blog/${post.slug}.html`,
  })),
];

export default defineConfig({
  plugins: [
    tailwindcss(),
    createMpaPlugin({
      template: "base.html",
      pages,
      rewrites,
    }),
  ],
});
EOFVITE
sed -i.bak "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g" "$PROJECT_PATH/vite.config.js" && rm "$PROJECT_PATH/vite.config.js.bak"

# Create base.html
cat > "$PROJECT_PATH/base.html" << 'EOFBASE'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><%= title %></title>
    <meta name="description" content="<%= description %>" />
    <script type="module" src="/src/main.js"></script>
  </head>
  <body class="min-h-screen bg-gray-50 text-gray-900 antialiased" x-data="{ mobileMenuOpen: false }">
    <!-- Navigation -->
    <nav class="bg-white border-b border-gray-200 sticky top-0 z-50 shadow-sm">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <!-- Logo -->
          <a href="/" class="text-2xl font-bold text-blue-600 hover:text-blue-700 transition-colors">
            PROJECT_NAME_PLACEHOLDER
          </a>

          <!-- Desktop Navigation -->
          <ul class="hidden md:flex space-x-8">
            <li>
              <a
                href="/"
                class="<%= activePage === 'home' ? 'text-blue-600 font-semibold' : 'text-gray-700 hover:text-blue-600' %> transition-colors"
              >
                Home
              </a>
            </li>
            <li>
              <a
                href="/about.html"
                class="<%= activePage === 'about' ? 'text-blue-600 font-semibold' : 'text-gray-700 hover:text-blue-600' %> transition-colors"
              >
                About
              </a>
            </li>
            <li>
              <a
                href="/blog.html"
                class="<%= activePage === 'blog' ? 'text-blue-600 font-semibold' : 'text-gray-700 hover:text-blue-600' %> transition-colors"
              >
                Blog
              </a>
            </li>
            <li>
              <a
                href="/contact.html"
                class="<%= activePage === 'contact' ? 'text-blue-600 font-semibold' : 'text-gray-700 hover:text-blue-600' %> transition-colors"
              >
                Contact
              </a>
            </li>
          </ul>

          <!-- Mobile Menu Button -->
          <button
            @click="mobileMenuOpen = !mobileMenuOpen"
            class="md:hidden p-2 rounded-lg hover:bg-gray-100 transition-colors"
          >
            <svg x-show="!mobileMenuOpen" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
            </svg>
            <svg x-show="mobileMenuOpen" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <!-- Mobile Menu -->
        <div
          x-show="mobileMenuOpen"
          x-transition:enter="transition ease-out duration-200"
          x-transition:enter-start="opacity-0 -translate-y-1"
          x-transition:enter-end="opacity-100 translate-y-0"
          x-transition:leave="transition ease-in duration-150"
          x-transition:leave-start="opacity-100 translate-y-0"
          x-transition:leave-end="opacity-0 -translate-y-1"
          class="md:hidden pb-4"
        >
          <ul class="space-y-2">
            <li>
              <a href="/" class="block px-4 py-2 rounded-lg <%= activePage === 'home' ? 'bg-blue-50 text-blue-600 font-semibold' : 'text-gray-700 hover:bg-gray-50' %>">
                Home
              </a>
            </li>
            <li>
              <a href="/about.html" class="block px-4 py-2 rounded-lg <%= activePage === 'about' ? 'bg-blue-50 text-blue-600 font-semibold' : 'text-gray-700 hover:bg-gray-50' %>">
                About
              </a>
            </li>
            <li>
              <a href="/blog.html" class="block px-4 py-2 rounded-lg <%= activePage === 'blog' ? 'bg-blue-50 text-blue-600 font-semibold' : 'text-gray-700 hover:bg-gray-50' %>">
                Blog
              </a>
            </li>
            <li>
              <a href="/contact.html" class="block px-4 py-2 rounded-lg <%= activePage === 'contact' ? 'bg-blue-50 text-blue-600 font-semibold' : 'text-gray-700 hover:bg-gray-50' %>">
                Contact
              </a>
            </li>
          </ul>
        </div>
      </div>
    </nav>

    <!-- Main Content -->
    <main class="min-h-[calc(100vh-16rem)]">
      <%- content %>
    </main>

    <!-- Footer -->
    <footer class="bg-white border-t border-gray-200 mt-16">
      <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <p class="text-center text-gray-600">
          &copy; 2026 PROJECT_NAME_PLACEHOLDER. All rights reserved.
        </p>
      </div>
    </footer>
  </body>
</html>
EOFBASE
sed -i.bak "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g" "$PROJECT_PATH/base.html" && rm "$PROJECT_PATH/base.html.bak"

# Create index.html
cat > "$PROJECT_PATH/index.html" << 'EOFINDEX'
<!-- Hero Section -->
<section class="bg-gradient-to-br from-blue-600 to-blue-800 text-white py-20">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
    <h1 class="text-4xl md:text-6xl font-bold mb-6">
      Welcome to PROJECT_NAME_PLACEHOLDER
    </h1>
    <p class="text-xl md:text-2xl text-blue-100 mb-8">
      A simple, clean website built with staticbase
    </p>
    <a
      href="/blog.html"
      class="inline-block bg-white text-blue-600 px-8 py-3 rounded-lg font-semibold hover:bg-blue-50 transition-colors shadow-lg hover:shadow-xl"
    >
      Read Our Blog
    </a>
  </div>
</section>

<!-- Recent Blog Posts -->
<section class="py-16">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <h2 class="text-3xl font-bold text-gray-900 mb-8">Recent Blog Posts</h2>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
      <%- recentBlogPosts %>
    </div>
    <div class="text-center mt-12">
      <a
        href="/blog.html"
        class="inline-block bg-blue-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors"
      >
        View All Posts
      </a>
    </div>
  </div>
</section>
EOFINDEX
sed -i.bak "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g" "$PROJECT_PATH/index.html" && rm "$PROJECT_PATH/index.html.bak"

# Create about.html
cat > "$PROJECT_PATH/about.html" << 'EOF'
<section class="py-16">
  <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
    <h1 class="text-4xl font-bold text-gray-900 mb-6">About Us</h1>

    <div class="prose prose-lg max-w-none">
      <p class="text-xl text-gray-600 mb-6">
        Welcome to our website! We're passionate about creating great content and sharing our knowledge with the world.
      </p>

      <h2 class="text-2xl font-bold text-gray-900 mt-8 mb-4">Our Mission</h2>
      <p class="text-gray-600 mb-6">
        Our mission is to provide valuable content and resources to our readers. We believe in simplicity, clarity, and user-friendly design.
      </p>

      <h2 class="text-2xl font-bold text-gray-900 mt-8 mb-4">What We Do</h2>
      <p class="text-gray-600 mb-6">
        We write about various topics including technology, design, and development. Our blog features tutorials, insights, and tips to help you grow.
      </p>

      <div class="bg-blue-50 border border-blue-200 rounded-lg p-6 mt-8">
        <h3 class="text-xl font-semibold text-blue-900 mb-2">Get in Touch</h3>
        <p class="text-blue-700">
          Interested in working together? <a href="/contact.html" class="underline hover:text-blue-900">Contact us</a> to learn more.
        </p>
      </div>
    </div>
  </div>
</section>
EOF

# Create contact.html
cat > "$PROJECT_PATH/contact.html" << 'EOF'
<section class="py-16">
  <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
    <h1 class="text-4xl font-bold text-gray-900 mb-6">Contact Us</h1>
    <p class="text-xl text-gray-600 mb-8">
      We'd love to hear from you! Get in touch using the form below.
    </p>

    <div id="successMessage" class="hidden bg-green-50 border border-green-200 text-green-800 px-4 py-3 rounded-lg mb-4">
      Thank you for your message! We'll get back to you soon.
    </div>

    <div id="errorMessage" class="hidden bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded-lg mb-4">
      Something went wrong. Please try again.
    </div>

    <form id="contactForm" class="space-y-6">
      <div>
        <label for="name" class="block text-sm font-medium text-gray-700 mb-2">
          Name
        </label>
        <input
          type="text"
          id="name"
          name="name"
          required
          class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
        />
        <span id="nameError" class="hidden text-sm text-red-600 mt-1">Please enter your name</span>
      </div>

      <div>
        <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
          Email
        </label>
        <input
          type="email"
          id="email"
          name="email"
          required
          class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
        />
        <span id="emailError" class="hidden text-sm text-red-600 mt-1">Please enter a valid email address</span>
      </div>

      <div>
        <label for="message" class="block text-sm font-medium text-gray-700 mb-2">
          Message
        </label>
        <textarea
          id="message"
          name="message"
          rows="5"
          required
          class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
        ></textarea>
        <span id="messageError" class="hidden text-sm text-red-600 mt-1">Please enter a message</span>
      </div>

      <button
        type="submit"
        id="submitBtn"
        class="w-full bg-blue-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <span id="submitText">Send Message</span>
      </button>
    </form>
  </div>
</section>
EOF

# Create templates/blog-list.html
cat > "$PROJECT_PATH/templates/blog-list.html" << 'EOF'
<section class="py-16">
  <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
    <h1 class="text-4xl font-bold text-gray-900 mb-4">Blog</h1>
    <p class="text-xl text-gray-600 mb-12">Thoughts, tutorials, and insights</p>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
      <%- blogCards %>
    </div>
  </div>
</section>
EOF

# Create templates/blog-post.html
cat > "$PROJECT_PATH/templates/blog-post.html" << 'EOF'
<article class="py-16">
  <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
    <header class="mb-8 pb-8 border-b border-gray-200">
      <h1 class="text-4xl font-bold text-gray-900 mb-4"><%= title %></h1>
      <time datetime="<%= date %>" class="text-gray-600">
        <%= date %>
      </time>
    </header>

    <div class="prose prose-lg max-w-none prose-headings:font-bold prose-a:text-blue-600 prose-a:no-underline hover:prose-a:underline prose-img:rounded-lg prose-pre:bg-gray-900 prose-pre:text-gray-100">
      <%- content %>
    </div>

    <div class="mt-12 pt-8 border-t border-gray-200">
      <a
        href="/blog.html"
        class="inline-flex items-center text-blue-600 hover:text-blue-700 font-semibold"
      >
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
        </svg>
        Back to Blog
      </a>
    </div>
  </div>
</article>
EOF

# Create lib/content.js
cat > "$PROJECT_PATH/lib/content.js" << 'EOF'
import { readFileSync, readdirSync, existsSync } from "fs";
import { join, basename } from "path";
import matter from "gray-matter";
import { marked } from "marked";

marked.setOptions({
  gfm: true,
  breaks: true,
});

export function parseMarkdownFile(filePath) {
  const fileContent = readFileSync(filePath, "utf-8");
  const { data: frontmatter, content } = matter(fileContent);
  const html = marked(content);

  return {
    frontmatter,
    content: html,
    slug: frontmatter.slug || basename(filePath, ".md"),
  };
}

export function getContentFromDirectory(contentDir, options = {}) {
  const { sortBy = "date", order = "desc", filterDraft = true } = options;

  if (!existsSync(contentDir)) {
    return [];
  }

  const files = readdirSync(contentDir).filter((f) => f.endsWith(".md"));

  const items = files.map((file) => {
    const filePath = join(contentDir, file);
    return parseMarkdownFile(filePath);
  });

  const filtered = filterDraft
    ? items.filter((item) => !item.frontmatter.draft)
    : items;

  return filtered.sort((a, b) => {
    const aVal = a.frontmatter[sortBy];
    const bVal = b.frontmatter[sortBy];

    if (sortBy === "date") {
      return order === "desc"
        ? new Date(bVal) - new Date(aVal)
        : new Date(aVal) - new Date(bVal);
    }
    return order === "desc" ? bVal - aVal : aVal - bVal;
  });
}

export function formatDate(date) {
  return new Date(date).toLocaleDateString("en-US", {
    month: "long",
    day: "numeric",
    year: "numeric",
  });
}
EOF

# Create lib/templates.js
cat > "$PROJECT_PATH/lib/templates.js" << 'EOF'
export function generateBlogCard(post) {
  const { frontmatter } = post;
  const date = new Date(frontmatter.date).toLocaleDateString("en-US", {
    month: "short",
    day: "numeric",
    year: "numeric",
  });

  return `
    <article class="bg-white border border-gray-200 rounded-lg p-6 hover:shadow-lg transition-shadow">
      <h3 class="text-xl font-bold text-gray-900 mb-2">
        <a href="/blog/${post.slug}.html" class="hover:text-blue-600 transition-colors">
          ${frontmatter.title}
        </a>
      </h3>
      <time datetime="${frontmatter.date}" class="text-sm text-gray-500 block mb-3">
        ${date}
      </time>
      <p class="text-gray-600 mb-4">${frontmatter.description || ''}</p>
      <a
        href="/blog/${post.slug}.html"
        class="inline-flex items-center text-blue-600 hover:text-blue-700 font-semibold"
      >
        Read More
        <svg class="w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
        </svg>
      </a>
    </article>
  `;
}
EOF

# Create src/main.js
cat > "$PROJECT_PATH/src/main.js" << 'EOF'
import './style.css';
import Alpine from 'alpinejs';

// Make Alpine available globally
window.Alpine = Alpine;

// Start Alpine
Alpine.start();

// Contact Form Handler
document.addEventListener('DOMContentLoaded', () => {
  const contactForm = document.getElementById('contactForm');

  if (!contactForm) return;

  const submitBtn = document.getElementById('submitBtn');
  const submitText = document.getElementById('submitText');
  const successMessage = document.getElementById('successMessage');
  const errorMessage = document.getElementById('errorMessage');

  const nameInput = document.getElementById('name');
  const emailInput = document.getElementById('email');
  const messageInput = document.getElementById('message');

  const nameError = document.getElementById('nameError');
  const emailError = document.getElementById('emailError');
  const messageError = document.getElementById('messageError');

  // Validation functions
  const validateEmail = (email) => {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  };

  const validateName = (name) => {
    return name.trim().length > 0;
  };

  const validateMessage = (message) => {
    return message.trim().length > 0;
  };

  const showError = (input, errorElement, message) => {
    input.classList.add('border-red-500');
    errorElement.textContent = message;
    errorElement.classList.remove('hidden');
  };

  const hideError = (input, errorElement) => {
    input.classList.remove('border-red-500');
    errorElement.classList.add('hidden');
  };

  // Real-time validation
  nameInput.addEventListener('blur', () => {
    if (!validateName(nameInput.value)) {
      showError(nameInput, nameError, 'Please enter your name');
    } else {
      hideError(nameInput, nameError);
    }
  });

  emailInput.addEventListener('blur', () => {
    if (!validateEmail(emailInput.value)) {
      showError(emailInput, emailError, 'Please enter a valid email address');
    } else {
      hideError(emailInput, emailError);
    }
  });

  messageInput.addEventListener('blur', () => {
    if (!validateMessage(messageInput.value)) {
      showError(messageInput, messageError, 'Please enter a message');
    } else {
      hideError(messageInput, messageError);
    }
  });

  // Form submission
  contactForm.addEventListener('submit', async (e) => {
    e.preventDefault();

    // Hide previous messages
    successMessage.classList.add('hidden');
    errorMessage.classList.add('hidden');

    // Validate all fields
    let isValid = true;

    if (!validateName(nameInput.value)) {
      showError(nameInput, nameError, 'Please enter your name');
      isValid = false;
    } else {
      hideError(nameInput, nameError);
    }

    if (!validateEmail(emailInput.value)) {
      showError(emailInput, emailError, 'Please enter a valid email address');
      isValid = false;
    } else {
      hideError(emailInput, emailError);
    }

    if (!validateMessage(messageInput.value)) {
      showError(messageInput, messageError, 'Please enter a message');
      isValid = false;
    } else {
      hideError(messageInput, messageError);
    }

    if (!isValid) {
      return;
    }

    // Disable submit button
    submitBtn.disabled = true;
    submitText.textContent = 'Sending...';

    try {
      // Prepare form data
      const formData = {
        name: nameInput.value.trim(),
        email: emailInput.value.trim(),
        message: messageInput.value.trim()
      };

      // Submit to API, change xxx to your form ID
      const response = await fetch('https://a.firaform.com/api/f/xxx', {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData)
      });

      if (response.ok) {
        // Show success message
        successMessage.classList.remove('hidden');
        // Reset form
        contactForm.reset();
        // Scroll to success message
        successMessage.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      } else {
        // Show error message
        errorMessage.classList.remove('hidden');
      }
    } catch (error) {
      console.error('Form submission error:', error);
      errorMessage.classList.remove('hidden');
    } finally {
      // Re-enable submit button
      submitBtn.disabled = false;
      submitText.textContent = 'Send Message';
    }
  });
});

console.log('staticbase loaded with Tailwind CSS and Alpine.js!');
EOF

# Create src/style.css
cat > "$PROJECT_PATH/src/style.css" << 'EOF'
@import "tailwindcss";
@plugin "@tailwindcss/typography";
EOF

# Create sample blog posts
cat > "$PROJECT_PATH/content/blog/welcome.md" << 'EOF'
---
title: "Welcome to staticbase"
slug: welcome
date: 2026-01-28
description: "Your first blog post using staticbase with Tailwind CSS and Alpine.js"
---

# Welcome to staticbase!

This is your first blog post. staticbase makes it easy to create a simple, clean website with a blog, powered by modern tools:

- **Tailwind CSS** for beautiful, utility-first styling
- **Alpine.js** for lightweight interactivity
- **Vite** for lightning-fast builds
- **Markdown** for easy content writing

## Getting Started

Edit this file or create new markdown files in the `content/blog` directory to add more posts.

Each post needs frontmatter with:
- **title**: The post title
- **slug**: URL-friendly identifier
- **date**: Publication date (YYYY-MM-DD)
- **description**: Short description for SEO

## Writing Content

You can use all standard Markdown features:

- Bulleted lists
- **Bold** and *italic* text
- [Links](https://example.com)
- Code blocks
- Images
- And more!

### Code Example

```javascript
function greet(name) {
  console.log(`Hello, ${name}!`);
}

greet('World');
```

## Next Steps

1. Customize your site colors in Tailwind config
2. Add more pages or blog posts
3. Deploy to your favorite hosting platform

Happy blogging! 🚀
EOF

cat > "$PROJECT_PATH/content/blog/getting-started.md" << 'EOF'
---
title: "Getting Started with Your New Site"
slug: getting-started
date: 2026-01-27
description: "Learn how to customize your new staticbase website with Tailwind CSS and Alpine.js"
---

# Getting Started

Congratulations on setting up your new website! Here's how to customize it and make it your own.

## Project Structure

```
mystaticbase/
├── content/
│   └── blog/          # Blog posts (markdown)
├── templates/         # Page templates
├── lib/               # Helper functions
├── src/
│   ├── main.js       # JavaScript + Alpine.js
│   └── style.css     # Tailwind CSS
├── public/
│   └── images/       # Static images
├── index.html        # Homepage content
├── about.html        # About page content
├── contact.html      # Contact page content
├── base.html         # Base template with navigation
└── vite.config.js    # Vite configuration
```

## Adding Blog Posts

Create a new `.md` file in `content/blog/` with frontmatter:

```markdown
---
title: "My Post Title"
slug: my-post-title
date: 2026-01-28
description: "Post description"
---

Your content here...
```

## Customizing Styles

staticbase uses Tailwind CSS. You can customize the theme by editing `src/style.css`:

```css
@import "tailwindcss";

@theme {
  /* Add custom colors */
  --color-brand: #3b82f6;
}
```

Or use Tailwind's utility classes directly in your HTML:

```html
<div class="bg-blue-600 text-white p-8 rounded-lg">
  Custom styled component
</div>
```

## Adding Interactivity with Alpine.js

Alpine.js is already set up! Add interactive components easily:

```html
<div x-data="{ open: false }">
  <button @click="open = !open">Toggle</button>
  <div x-show="open">Content</div>
</div>
```

## Deployment

Build your site for production:

```bash
npm run build
```

The `dist/` folder can be deployed to:
- **Netlify** - Drag & drop deployment
- **Vercel** - Git integration
- **GitHub Pages** - Free hosting
- **Cloudflare Pages** - Fast global CDN

## Learn More

- [Tailwind CSS Docs](https://tailwindcss.com/docs)
- [Alpine.js Docs](https://alpinejs.dev/)
- [Vite Guide](https://vitejs.dev/guide/)
- [Markdown Guide](https://www.markdownguide.org/)

Enjoy building your site! ✨
EOF

# Create README
cat > "$PROJECT_PATH/README.md" << 'EOFREADME'
# PROJECT_NAME_PLACEHOLDER

A modern, clean website built with staticbase.

## Features

- 📄 Static pages (Home, About, Contact)
- 📝 Markdown-based blog
- ⚡ Fast development with Vite
- 🎨 Tailwind CSS for styling
- 🏔️ Alpine.js for interactivity
- 📱 Fully responsive design

## Getting Started

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## Tech Stack

- **Vite** - Lightning fast build tool
- **Tailwind CSS** - Utility-first CSS framework
- **Alpine.js** - Lightweight JavaScript framework
- **Marked** - Markdown parser
- **Gray Matter** - Frontmatter parser

## Project Structure

```
PROJECT_NAME_PLACEHOLDER/
├── content/blog/      # Blog posts (markdown files)
├── templates/         # Page templates
├── src/
│   ├── main.js       # JavaScript + Alpine.js setup
│   └── style.css     # Tailwind CSS
├── lib/              # Helper functions
├── public/images/    # Static assets
├── index.html        # Homepage content
├── about.html        # About page content
├── contact.html      # Contact page content
├── base.html         # Base template with navigation
└── vite.config.js    # Vite configuration
```

## Adding Blog Posts

Create a new `.md` file in `content/blog/`:

```markdown
---
title: "Your Post Title"
slug: your-post-title
date: 2026-01-28
description: "Brief description"
---

Your content here...
```

## Customization

### Change Theme Colors

Tailwind CSS makes it easy to customize your theme. Edit `src/style.css`:

```css
@import "tailwindcss";

@theme {
  --color-primary: #3b82f6;
}
```

### Modify Pages

- **Homepage**: Edit `index.html`
- **About**: Edit `about.html`
- **Contact**: Edit `contact.html`
- **Layout**: Edit `base.html`

### Add Alpine.js Components

Alpine.js is ready to use. Add interactive components:

```html
<div x-data="{ count: 0 }">
  <button @click="count++">Increment</button>
  <span x-text="count"></span>
</div>
```

## Deployment

### Netlify

```bash
npm run build
# Drag and drop the dist/ folder to Netlify
```

### Vercel

```bash
npm run build
# Deploy dist/ folder or connect your git repo
```

### GitHub Pages

```bash
npm run build
# Push dist/ folder to gh-pages branch
```

## Learn More

- [Vite Documentation](https://vitejs.dev/)
- [Tailwind CSS](https://tailwindcss.com/)
- [Alpine.js](https://alpinejs.dev/)

## License

MIT
EOFREADME
sed -i.bak "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g" "$PROJECT_PATH/README.md" && rm "$PROJECT_PATH/README.md.bak"

# Create .gitignore
cat > "$PROJECT_PATH/.gitignore" << 'EOF'
node_modules/
dist/
.env
.env.local
.DS_Store
*.log
EOF

# Create AGENTS.md
cat > "$PROJECT_PATH/AGENTS.md" << 'EOFAGENTS'
# AGENTS.md

## Guidelines for AI Agents Working on staticbase Projects

This document provides rules and guidelines for AI agents (like Claude, ChatGPT, etc.) when working on staticbase projects.

---

## Project Overview

staticbase is a modern static site generator built with:
- **Vite** - Build tool
- **Tailwind CSS** - Utility-first CSS
- **Alpine.js** - Lightweight JavaScript framework
- **Markdown** - Content format for blog posts

---

## Core Principles

### 1. Simplicity First
- Keep code simple and readable
- Avoid over-engineering solutions
- Use vanilla patterns when possible
- Don't add unnecessary dependencies

### 2. Tailwind-First Approach
- Use Tailwind utility classes for styling
- Avoid writing custom CSS unless absolutely necessary
- Follow Tailwind's responsive design patterns
- Use Tailwind's color and spacing scale

### 3. Alpine.js for Interactivity
- Use Alpine.js for client-side interactivity
- Keep components small and focused
- Prefer declarative syntax over imperative
- Avoid complex state management

### 4. Content-Driven
- Blog posts are markdown files in `content/blog/`
- Each post requires valid frontmatter
- Keep content separate from presentation
- Use semantic HTML

---

## File Structure Rules

### DO:
✅ Create blog posts in `content/blog/` as `.md` files
✅ Use the existing template structure
✅ Keep helper functions in `lib/` directory
✅ Put static assets in `public/` directory
✅ Follow the established naming conventions

### DON'T:
❌ Create new directories without good reason
❌ Modify the build configuration unnecessarily
❌ Add files outside the established structure
❌ Mix content and presentation logic

---

## Code Style Guidelines

### HTML/Templates
```html
<!-- Good: Clean, semantic, Tailwind classes -->
<article class="bg-white rounded-lg shadow-lg p-6">
  <h2 class="text-2xl font-bold text-gray-900 mb-4">
    Title Here
  </h2>
</article>

<!-- Bad: Inline styles, non-semantic -->
<div style="background: white; padding: 20px;">
  <div class="title">Title Here</div>
</div>
```

### Alpine.js Components
```html
<!-- Good: Declarative, simple state -->
<div x-data="{ open: false }">
  <button @click="open = !open">Toggle</button>
  <div x-show="open" x-transition>Content</div>
</div>

<!-- Bad: Complex logic, inline functions -->
<div x-data="{ items: [], filtered: function() { /* complex logic */ } }">
  <!-- Too complex for Alpine -->
</div>
```

### Markdown Blog Posts
```markdown
<!-- Good: Complete frontmatter, clear structure -->
---
title: "Clear, Descriptive Title"
slug: clear-descriptive-title
date: 2026-01-28
description: "A helpful description under 160 characters"
---

# Main Heading

Content with proper markdown formatting...
```

---

## Common Tasks

### Adding a New Page

1. Create HTML content file (e.g., `services.html`)
2. Add navigation link to `base.html`
3. Add page entry to `vite.config.js` pages array:

```javascript
{
  name: "services",
  entry: "/src/main.js",
  data: {
    title: "Services - PROJECT_NAME",
    description: "Our services",
    activePage: "services",
    content: readFileSync(resolve(__dirname, "services.html"), "utf-8"),
  },
}
```

### Creating a Blog Post

1. Create `content/blog/post-slug.md`
2. Add required frontmatter:

```markdown
---
title: "Post Title"
slug: post-slug
date: 2026-01-28
description: "Post description"
---

Content here...
```

3. The build system automatically generates the page

### Styling Components

Use Tailwind utilities:

```html
<!-- Layout -->
<div class="container mx-auto px-4">
  <!-- Spacing -->
  <section class="py-16 space-y-8">
    <!-- Typography -->
    <h1 class="text-4xl font-bold text-gray-900">
    <!-- Colors & Effects -->
    <button class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg transition-colors">
```

### Adding Interactivity

Use Alpine.js:

```html
<!-- Dropdown -->
<div x-data="{ open: false }" @click.away="open = false">
  <button @click="open = !open">Menu</button>
  <div x-show="open" x-transition>Items</div>
</div>

<!-- Form handling -->
<form x-data="{ submitting: false }" @submit.prevent="submitForm">
  <button :disabled="submitting">Submit</button>
</form>
```

---

## Best Practices

### Performance
- Minimize JavaScript usage
- Use Tailwind's JIT mode (default)
- Optimize images before adding to `public/images/`
- Lazy load images when appropriate

### Accessibility
- Use semantic HTML elements
- Add proper ARIA labels when needed
- Ensure keyboard navigation works
- Test with screen readers
- Maintain proper heading hierarchy

### SEO
- Include meta descriptions in page data
- Use descriptive page titles
- Add alt text to all images
- Use semantic HTML structure
- Generate sitemap.xml (if needed)

### Mobile-First
- Start with mobile styles
- Use Tailwind's responsive prefixes (`md:`, `lg:`)
- Test on multiple screen sizes
- Ensure touch targets are large enough

---

## Common Patterns

### Responsive Grid
```html
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
  <!-- Cards -->
</div>
```

### Card Component
```html
<article class="bg-white rounded-lg shadow-lg p-6 hover:shadow-xl transition-shadow">
  <h3 class="text-xl font-bold mb-2">Title</h3>
  <p class="text-gray-600">Description</p>
</article>
```

### Button Variants
```html
<!-- Primary -->
<button class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg">

<!-- Secondary -->
<button class="bg-gray-200 hover:bg-gray-300 text-gray-900 px-6 py-3 rounded-lg">

<!-- Outline -->
<button class="border-2 border-blue-600 text-blue-600 hover:bg-blue-50 px-6 py-3 rounded-lg">
```

---

## Troubleshooting

### Build Issues
- Run `npm install` to ensure dependencies are installed
- Check `vite.config.js` for syntax errors
- Verify all page entries have correct paths
- Clear cache: `rm -rf node_modules/.vite`

### Styling Issues
- Check Tailwind class names for typos
- Ensure `@import "tailwindcss"` is in `style.css`
- Verify responsive prefixes are correct
- Check browser DevTools for applied classes

### Content Issues
- Validate markdown frontmatter syntax
- Ensure dates are in YYYY-MM-DD format
- Check for missing required fields
- Verify markdown syntax is correct

---

## When to Add Dependencies

### DO Add When:
✅ It solves a specific, common problem
✅ It's well-maintained and popular
✅ It's small and focused
✅ It improves DX significantly

### DON'T Add When:
❌ You can implement it in 10 lines of code
❌ It's only used once
❌ It's a large framework for a small feature
❌ A simpler alternative exists

---

## Testing Checklist

Before finishing any task, verify:

- [ ] All pages load without errors
- [ ] Navigation works correctly
- [ ] Responsive design works on mobile
- [ ] Forms submit properly (if applicable)
- [ ] Blog posts render correctly
- [ ] Images load properly
- [ ] Links work (internal and external)
- [ ] No console errors
- [ ] Build completes successfully (`npm run build`)
- [ ] Preview works (`npm run preview`)

---

## Communication with Developers

When working with human developers:

1. **Explain your changes** - Don't just make changes silently
2. **Ask for clarification** - If requirements are unclear
3. **Suggest alternatives** - When you see a better approach
4. **Warn about tradeoffs** - When decisions have consequences
5. **Document assumptions** - Make your reasoning clear

---

## Version Control

### Commit Messages
Use clear, descriptive commit messages:

```
✅ Good:
- Add contact form validation
- Update blog post template styling
- Fix mobile navigation bug

❌ Bad:
- Fixed stuff
- Update
- Changes
```

### What to Commit
- Source files
- Content files
- Configuration files
- Documentation

### What NOT to Commit
- `node_modules/`
- `dist/`
- `.env` files
- Log files
- OS-specific files (`.DS_Store`)

---

## Security Considerations

- Never commit sensitive data (API keys, passwords)
- Validate and sanitize user input
- Use HTTPS for external resources
- Keep dependencies updated
- Don't expose internal paths or structure
- Implement CSP headers (if needed)

---

## Resources

- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Alpine.js Documentation](https://alpinejs.dev/)
- [Vite Documentation](https://vitejs.dev/)
- [Markdown Guide](https://www.markdownguide.org/)
- [Web Accessibility Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

---

## Final Notes

Remember: **staticbase is intentionally simple**. When in doubt:
1. Choose the simpler solution
2. Use existing patterns
3. Keep it maintainable
4. Prioritize user experience
5. Ask for guidance when needed

The goal is a fast, accessible, maintainable website - not showing off technical complexity.

---

*Last Updated: 2026-01-28*
*For questions or clarifications, refer to the project README.md*
EOFAGENTS

echo -e "${GREEN}✅ staticbase project created successfully!${NC}"
echo ""
echo -e "${BLUE}📦 Next steps:${NC}"
echo ""
echo "   cd $PROJECT_NAME"
echo "   npm install"
echo "   npm run dev"
echo ""
echo -e "${GREEN}🌐 Your site will be available at http://localhost:5173${NC}"
echo ""
echo "📚 Check README.md for more information"
echo "🤖 Check AGENTS.md for AI agent guidelines"
