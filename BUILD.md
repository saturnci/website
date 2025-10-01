# Static Site Generator

This site uses a custom Ruby static site generator.

## Structure

- `layouts/` - ERB templates
- `pages/` - Page content (YAML frontmatter + HTML)
- `public/` - Generated output (deploy this)
- `build.rb` - Build script

## Setup

Install dependencies:
```bash
bundle install
```

## Building

```bash
bundle exec ruby build.rb
```

This generates the site in `public/` directory.

For development with auto-rebuild:
```bash
./serve.sh
```

## Adding Pages

1. Create a new file in `pages/` with `.html` extension
2. Add YAML frontmatter:
   ```yaml
   ---
   page_title: Page Name
   nav: page_name
   ---
   ```
3. Add your HTML content below the frontmatter
4. Run `ruby build.rb` to regenerate

## Navigation

Navigation is automatically generated from the layout template. Set the `nav` frontmatter to match one of: `index`, `about`, `documentation`.

## Assets

CSS files and other assets are automatically copied from the root directory to `public/`.