# Structured data

Kotsu comes with already built-in minimal recommended structured data for social services and search providers.

This allows to kick-in website quickly without worrying about typical optimizations for social services cards and search providers snippets, but in some cases it still require manual adjustments to fit specific websites.

## Structured data format

Kotsu opted to use [RDFa](https://rdfa.info/) syntax as a way to markup structured data.

RDFa was chosen over [Microdata](https://www.w3.org/TR/microdata/) because it is modern, expressive and compact.

`JSON-LD` looks promising too and widely supported, but in same time slightly more restrictive when you need to markup generated in loops structures (for instance, Breadcrumb), since you need to replicate loop twice and it isn't that handy. Just for the note, `JSON-LD` can be mixed with RDFa. No one will die.

Some more information in relevant issue [#89](https://github.com/LotusTM/Kotsu/issues/89).

## Structured data vocabulary

[Schema.org](http://schema.org/) used as main vocabulary because of it wide popularity.

It is declared on root of each page (if you use `_base.nj` layout), so you don't need to use any prefixes to call it.

Additionally, Open Graph (`og:`) and Twitter Cards (`twitter:`) vocabularies used for respective meta tags. But note that while they seems like part of RDFa, they are not.

If you need even more vocabularies, you can always add it through RDFa `prefix` property.

Also, see issue [#89](https://github.com/LotusTM/Kotsu/issues/89).

## Setting up structured data

Kotsu will try to fill structured data as much as possible based on provided in [`source/data`](https://github.com/LotusTM/Kotsu/tree/master/source/data) data, and when no specific data available, it will try to fill it with more generic values.

Thus, it is crucial to change all default Kotsu values. More on Kotsu data [here](https://github.com/LotusTM/Kotsu/blob/master/docs/Data.md).

In some cases you might need to adjust already existing structured data to fit your needs or add custom data. Head to [Customizing structured data](#customizing-structured-data) section for more information.

## Out of box structured data

Kotsu does not provide structured data for everything and tries to focus only on important for any website structured data.

Out of box it covers following services:

  * Facebook with [Open Graph](http://ogp.me/)
  * Twitter with [Twitter Cards](https://dev.twitter.com/cards/overview)
  * Search providers (Google, Yandex) with [RDFa](https://rdfa.info/) syntax and [Schema.org](http://schema.org/) vocabulary

And provides following structured data as part of [`_base.nj`](https://github.com/LotusTM/Kotsu/blob/master/source/templates/_layouts/_base.nj) layout:

  * Open Graph meta
  * Twitter Cards meta
  * [Site logo](https://developers.google.com/search/docs/data-types/logo)
  * [Social profiles](https://developers.google.com/search/docs/data-types/social-profile-links)
  * [Website and preferred site name](https://developers.google.com/search/docs/data-types/sitename)
  * Organization (as part of [Social profiles](https://developers.google.com/search/docs/data-types/social-profile-links))

Following structured data as part of [`_main_.nj`](https://github.com/LotusTM/Kotsu/blob/master/source/templates/_layouts/_main.nj) layout:

  * [Breadcrumb](https://developers.google.com/search/docs/data-types/breadcrumbs)

And as part of [`blog/_entry.nj`](https://github.com/LotusTM/Kotsu/blob/master/source/templates/blog/_entry.nj) layout:

  * [NewsArticle](https://developers.google.com/search/docs/data-types/articles)

Most part of default structured data is a part of [`_base.nj`](https://github.com/LotusTM/Kotsu/blob/master/source/templates/_layouts/_base.nj) layout, so it is preferred to extend `_base.nj` whenever you need to build your own pages. Since base layout is mostly design-free and widely configurable, it shouldn't be hard. Otherwise, you will need to replicate that functionality.

Breadcrumb structured data is tied to [`Breadcrumb()`](https://github.com/LotusTM/Kotsu/blob/master/source/templates/_components/_Breadcrumb.nj) component, which is used in [`_main_.nj`](https://github.com/LotusTM/Kotsu/blob/master/source/templates/_layouts/_main.nj) by default. If you extend base layout directly, you will need to call that component somewhere in your document to make Breadcrumb structured data work. Or just pretend like you didn't read this.

## Resources

Sometimes you might need to use certain structured data, which already exists on your website, in another structured data. For instance, `NewsArticle` `publisher` property expects a `Person` or `Organization`, and in most cases you'd want to state as publisher yourself or your organization.

Structured data about your Organization (website) already provided, so repeating all properties inside `NewsArticle` `publisher` can be cumbersome.

Fortunately, RDFa allows to refer already existing on website structured data. And to facilitate it, Kotsu provide some useful resources ids.

### `#this`

By default website `Organization` structured data, which represents site owner or site itself, is resourced as `#this`.

It allows whenever needed to reference that structure instead of duplicating it properties.

For instance, it used in blog `NewsArticle` `publisher` property to reference current website as publisher instead of duplicating properties as follows:

```html
<meta property='publisher' resource='#this'>
```

### `#this-website`

Same way as with `#this`, Kotsu provides `#this-website` resource which points to current `WebSite` structured data and can be used to reference in other structured data.

## Customizing structured data

When default Kotsu data isn't enough, it's time to make some manual adjustments.

Lets look at most typical scenarios
  
### Your site represents a Person, not an Organization

Change meta data in [`_base.nj`](https://github.com/LotusTM/Kotsu/blob/master/source/templates/_layouts/_base.nj) layout. Just look for `typeof='Organization'`, then change it to [Person](http://schema.org/Person) following all Schema.org guidelines. Do not remove `resource='#this'`, since even due to type change, it still can be referenced in most cases as publisher, or author or whenever you prefer.

Note, that Google doesn't state anywhere that it supports `Person` type, so we can not guarantee that it will appear in search results.

### You need additional structured data for Products, Reviews, etc.

As already stated, Kotsu isn't packed with all structured data, since most part of it is quite opinionated and specific only for some portion of websites.

So, it is quite okey that you will need to add your own structured data. Follow [RDFa Primer](https://www.w3.org/TR/xhtml-rdfa-primer/) to understand how.

When structured data tied to specific pages, like in case of a Product or Review, add structured data right on relevant pages pages, where these entries occurs. To mix it with html or use `<meta>` tags is up to you.

If structured data you want to add is global and relates to whole website (like, [LocalBusinesses](https://developers.google.com/search/docs/data-types/local-businesses) or [Corporate contacts](https://developers.google.com/search/docs/data-types/corporate-contacts)) it is better to add them in `<head>` of [`_base.nj`](https://github.com/LotusTM/Kotsu/blob/master/source/templates/_layouts/_base.nj) layout, where `WebSite` and `Organization` stored.

Since in `<head>` you can not nest elements to create types and it is anyway recommended to resource globally available structured data, follow this patter to make it work:

```html
<head>
    ...

    <meta typeof='Schema.org_type_here' resource='#this-YOUR_TYPE_HERE'>
    <meta about='#this-YOUR_TYPE_HERE' property='name' content='...'>
    <meta about='#this-YOUR_TYPE_HERE' property='url' content='...'>
    ...other related to `#this-YOUR_TYPE_HERE` properties

    ...
</head>
```

Don't forget to use Kotsu data and add new properties to it whenever your data shared across the site to keep crucial data well organized and centralized.

Keep in mind, that Google and other popular services supports limited amount of structured data. See [list of supported by Google structured data types](https://developers.google.com/search/docs/guides/search-gallery).

### Open Graph or Twitter Cards structured data doesn't fit well

As all other built-in structured data, Kotsu builds those based on provided to Kotsu [data](https://github.com/LotusTM/Kotsu/blob/master/docs/Data.md). Results usually should fit most cases. In very rare ones, you might need to adjust Open Graph or Twitter Cards structured data directly to add some not-so-often occurring information, like app id for Facebook.

If you need to add completely new property or radically change values, you don't have any other options except go and edit in [`_base.nj`](https://github.com/LotusTM/Kotsu/blob/master/source/templates/_layouts/_base.nj) layout sections related to Open Graph and Twitter Cards.

If you need to change values only on specific pages (for instance, when in Blog scope, you'd want to change Open Graph `type` to `article`), you might use Front Matter or other [ways to configure Kotsu data](https://github.com/LotusTM/Kotsu/blob/master/docs/Data.md#defining-custom-data). They will effectively override values only for those specific pages.