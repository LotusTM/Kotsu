# Set up environment variables

Before start rocking with Kotsu you need to setup some environment variables.

Depending on your OS you can set them with one of following commands:
```sh
# for Linux
export TINYPNG_API_KEY=YOUR_API_KEY_HERE

# for Windows
set TINYPNG_API_KEY=YOUR_API_KEY_HERE
```

For local development, you only need to set variables marked as **Local**

Variable | Local | CI | Type | Description
--- | --- | --- | --- | ---
TINYPNG_API_KEY | Yes[*](#required) | Yes[*](#required) | String | used by `grunt-tinypng` to compress images via TinyPNG API. Get your API key [here](https://tinypng.com/developers)
GITHUB_API_KEY | Yes[*](#required) | Yes[*](#required) | String | used by `jspm` to access GitHub API. It's an unencrypted Base64 encoding of the GitHub username and password or access token separated by a `:` (e.g. `username:token`). Get your token [here](https://github.com/settings/tokens)
SERVER_IP | No | Yes[*](#required) | String | an IP address or domain of your server where CI will automatically deploy
SITENAME | No | Yes[*](#required) | String | your site name without protocol specification (e.g. `exapmple.com`)
PRODUCTION | No | Yes | Boolean | `true` by default if using `grunt build`, `false` for `grunt`, useful if you want to override this behavior
STAGING | No | Yes | Boolean | `false` by default

# Required
Variables marked as with asterisk (*) are required for related development environment