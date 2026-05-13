[working-directory: 'server']
link-wrangler:
    ln -sf ../wrangler.jsonc ./
    ln -sf ../worker-configuration.d.ts ./

[working-directory: 'server/public']
link-docs:
    ln -sf ../../docs/site/* ./

[working-directory: 'server']
link: link-wrangler link-docs
