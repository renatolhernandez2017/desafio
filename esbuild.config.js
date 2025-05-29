const path = require('path')
const vuePlugin = require('esbuild-plugin-vue').default
const esbuild = require('esbuild')

const options = {
  entryPoints: ['app/javascript/application.js'],
  bundle: true,
  target: 'es2017',
  outdir: 'app/assets/builds',
  plugins: [vuePlugin()],
  define: {
    __VUE_OPTIONS_API__: 'true',
    __VUE_PROD_DEVTOOLS__: 'false',
  },
  loader: {
    '.js': 'jsx',
    '.vue': 'js',
  },
  sourcemap: true,
}

async function build() {
  if (process.argv.includes('--watch')) {
    const ctx = await esbuild.context(options)
    await ctx.watch()
    console.log('👀 Watching for changes...')
  } else {
    await esbuild.build(options)
    console.log('✅ Build complete')
  }
}

build().catch(() => process.exit(1))
