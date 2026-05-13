[working-directory: 'server']
link-wrangler-jsonc:
    ln -sf ../wrangler.jsonc ./

[working-directory: 'server/public']
link-public:
    ln -sf ../../docs/site/* ./

[working-directory: 'server']
build: link-wrangler-jsonc link-public
