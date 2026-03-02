## Web Development Extension

This section provides routing and context for web development tasks using Astro, Tailwind CSS v4, TypeScript, and Cloudflare Pages.

### Language Routing

| Language | Research Agent | Implementation Agent |
|----------|----------------|---------------------|
| `web` | web-research | web-implementation |

### Research Tools
- `read` - Analyze existing codebase patterns
- `grep` - Search for code patterns
- `glob` - Find files by pattern
- `webfetch` - Fetch documentation
- `websearch` - Search for best practices

### Implementation Tools
- `read`, `write`, `edit` - File operations
- `bash` - Run pnpm build, pnpm check
- `grep`, `glob` - Code search

### Build Verification

Always verify before completing implementation:

```bash
pnpm check    # TypeScript diagnostics
pnpm build    # Production build
```

### Context Files

Load these for web development tasks:

- `@.opencode/extensions/web/context/project/web/astro-framework.md`
- `@.opencode/extensions/web/context/project/web/tailwind-v4.md`
- `@.opencode/extensions/web/context/project/web/cloudflare-pages.md`
- `@.opencode/extensions/web/context/project/web/standards/accessibility-standards.md`
- `@.opencode/extensions/web/context/project/web/standards/performance-standards.md`
