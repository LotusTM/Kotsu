# URLs

In Kotsu all URLs are just... well, URLs.

However, there are few things should be highlighted.

## Recommended format of URLs

### Always root-relative

For internal links, it is recommended to use only root-relative URLs and never absolute or document-relative ones.

Ok:

```
href='/'
href='/my-page/inner'
```

Not Ok:

```
href='https://example.com/my-page/inner'
href=''
href='inner'
```

While absolute URLs will make your website less portable, they are also completely redundant. Though, they are acceptable for rare cases when absolute URL should be provided (for instance, for Open Graph).

Document-relative URLs might be an unwise idea because they are affected by trailing slash:

For URL `/my-page/inner/`

```html
<a href='other'>Link</a>
```

will result in `/my-page/inner/other`.

But for `/my-page/inner`, the same anchor will result in `/my-page/other`, because the last segment will be considered as a document.

### Never with trailing slash

Because of how supplied with Kotsu Nginx Docker container set up by default and to avoid unnecessary redirects, we strongly recommend to never add a trailing slash to the end of URL.

Ok urls:

```
href='/'
href='/my-page'
href='/my-page/inner'
```

Those are not:

```
href='/my-page/'
href='/my-page/inner/'
```

If trailing slash will be explicitly added, Nginx simply will redirect that url to the one without trailing slash, with 301 code. This is to avoid content duplication.

Note, that this recommendation is true only if Kotsu used with supplied Docker container and default container settings, otherwise it will depend on your server configuration.

More on why this is recommended format [here](#remove-trailing-slash).

## Specificity of URLs handling by supplied Nginx server

Out of the box, Kotsu supplied with Nginx Docker container, which is preconfigured to operate with URLs in a specific way.

### Not found resources

If no file or page found at all, the server will always serve `404.html` page:

```
/nope
- Try file `/nope`
- No `/nope` found
- Serve `/404.html`
```

### Resolve to `index.html`

If no file found with specified URL, the server will try to resolve to `index.html`:

```
/examples
- Try file `/examples`
- No file `/examples` found
- Try file `/examples/index.html`
- If found, serve, otherwise, serve `404.html` page
```

This feature allows using human-readable URLs by simply omitting `index.html` part.

### Remove trailing slash

If URL with trailing slash provided, the server will redirect to the same URL without trailing slash:

```
/examples/
- Redirect with 303 to `/examples`
- Continue with regular routine...
```

Such approach allows avoiding content duplication, since by some search providers `/examples/` and `/examples` can be considered as two different pages with same content.

Due to that, it is strongly recommended never to use a trailing slash in URLs to avoid additional redirects.

More on this in issue [#170](https://github.com/LotusTM/Kotsu/issues/170).

Just for the information, we opted to always remove trailing slash instead of always add it for directories only, because it makes operations with URLs segments easier on front-end side.

For instance, it is not uncommon when you need to generate URLs for some resources in loops. Unfortunately, front-end can't know is resource a file or a directory — it is known only to servers or through probing, which isn't a sane thing to do for lots of URLs. Because of that, front-end usually can't know should resource have a trailing slash or not, and any URLs with "wrong" trailing slash will result in additional redirect, which will decrease the responsiveness of website navigation.

To ease the pain, we simply made URLs without trailing slashes always canonical, regardless of is it a file or a directory. We treat everything as a document. Now fronted should never care about trailing slashes at all — it just has to always omit it whenever possible and let the server do all resolving.

## Helpers

To make work with URLs easier, Kotsu provides few built-in custom function and components.

### Nunjucks functions

#### `urljoin`

Accepts array of URL segments and intelligently joins them into single URL, resolved and normalized.

[Documentation](https://github.com/LotusTM/Kotsu/blob/master/modules/urljoin.js)

#### `URI`

Whole `URI.js` library available to Nunjucks to make URLs manipulations easier.

[Documentation](https://medialize.github.io/URI.js/)

#### `absoluteurl`

Takes in URL. In a case of absolute URLs, returns it as it is, otherwise resolves against current site domain.

Though, might be slightly obscure, this function is useful when you not sure will be input absolute URL or no, but needs to always return absolute URL, no matter what.

[Documentation](https://github.com/LotusTM/Kotsu/blob/master/modules/nunjucks-extensions.js)

#### `isActive`

If compared URL is part of current page URL, will return true.

[Documentation](https://github.com/LotusTM/Kotsu/blob/master/modules/nunjucks-extensions.js)

### Nunjucks components

#### `Link`

Based on `isActive` function, constructs the whole anchor which will receive an active class in case link considered active.

It will also try to load URL from page Front Matter, in case it has a custom one.

Useful for navigation links.

[Documentation](https://github.com/LotusTM/Kotsu/blob/master/source/templates/_components/_Link.nj)

#### Other

There are some other built-in components, which partially related to links construction too, like `Nav`, `NavItem` and `Breadcrumb` components.

See [all Nunjucks components](https://github.com/LotusTM/Kotsu/tree/master/source/templates/_components) for details.