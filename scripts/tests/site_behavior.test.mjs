// Offline DOM/JavaScript regression checks for index.html. No network calls.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import vm from 'node:vm';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const html = fs.readFileSync(path.join(root, 'index.html'), 'utf8');
const match = html.match(/<script>\s*([\s\S]*?)\s*<\/script>/);
assert.ok(match, 'expected the inline site script');
const startup = match[1].lastIndexOf('\n  loadAll().catch(');
assert.notEqual(startup, -1, 'could not isolate the network startup');
// Execute the actual page script and its DOM listeners, suppressing only the
// initial API request. Expose its real functions for offline assertions.
const script = match[1].slice(0, startup) + `\n  globalThis.subject = {
  FALLBACK_PACKS, FALLBACK_MODS, packsFromReleaseAssets, modsFromContents,
  renderPacks, startDownload, el
};\n})();`;

class Element {
  constructor(tag = 'div') {
    this.tag = tag; this.children = []; this.handlers = {}; this.style = {};
    this.classList = {add() {}, remove() {}};
    this.disabled = false; this._html = ''; this.textContent = '';
  }
  set innerHTML(value) { this._html = value; this.children = []; }
  get innerHTML() { return this._html; }
  appendChild(child) { this.children.push(child); return child; }
  removeChild(child) { this.children = this.children.filter(x => x !== child); }
  addEventListener(name, fn) { this.handlers[name] = fn; }
  setAttribute() {}
  click() { this.clicked = true; }
}
const nodes = new Map();
const document = {
  body: new Element('body'),
  createElement: tag => new Element(tag),
  getElementById: id => { if (!nodes.has(id)) nodes.set(id, new Element()); return nodes.get(id); },
  addEventListener() {},
};
let fetches = 0;
const sandbox = {
  document, window: {addEventListener() {}}, navigator: {}, AbortController,
  setTimeout: () => 0, clearTimeout() {}, setInterval: () => 0, clearInterval() {},
  fetch: async () => { fetches++; return {status: 404, ok: false}; },
};
vm.runInNewContext(script, sandbox, {filename: 'index.html'});
const s = sandbox.subject;
assert.ok(!s.FALLBACK_PACKS.some(p => p.zip === 'guikit-datapack.zip'));
assert.ok(!s.FALLBACK_MODS.some(m => ['datapack-fixer', 'rtwrapper-mod'].includes(m.dir)));

s.renderPacks(s.FALLBACK_PACKS, 'offline list');
assert.equal(s.el.packsGrid.children.length, s.FALLBACK_PACKS.length);
for (const card of s.el.packsGrid.children) {
  const actions = card.children.find(x => x.className === 'card-actions');
  assert.ok(actions.children.every(x => x.disabled), 'offline downloads and copy must be disabled');
  assert.match(card.children.at(-1).textContent, /not verified/i);
}

const base = 'https://github.com/vortaforge/core/releases/download/packs-latest/';
const assets = s.packsFromReleaseAssets([
  {name: 'DailyBonus.zip', browser_download_url: base + 'DailyBonus.zip'},
  {name: 'guikit-datapack.zip', browser_download_url: base + 'guikit-datapack.zip'},
  {name: 'missing.zip'},
  {name: 'evil.zip', browser_download_url: 'https://example.com/evil.zip'},
  {name: 'readme.txt', browser_download_url: base + 'readme.txt'},
]);
assert.equal(assets.length, 2, 'do not construct guessed URLs or accept other hosts');
assert.match(assets.find(p => p.zip === 'guikit-datapack.zip').name, /historical asset/i);
const live = assets.find(p => p.zip === 'DailyBonus.zip');
s.renderPacks([live], 'live');
let actions = s.el.packsGrid.children[0].children.find(x => x.className === 'card-actions');
assert.ok(actions.children.every(x => !x.disabled && typeof x.handlers.click === 'function'));
s.renderPacks([live], 'cached');
actions = s.el.packsGrid.children[0].children.find(x => x.className === 'card-actions');
assert.ok(actions.children.every(x => x.disabled), 'cached release assets can be stale');
s.renderPacks([{name: 'bad', zip: 'bad.zip', downloadUrl: 'javascript:alert(1)'}], 'live');
actions = s.el.packsGrid.children[0].children.find(x => x.className === 'card-actions');
assert.ok(actions.children.every(x => x.disabled), 'live cards still validate their URLs');

const mods = s.modsFromContents(['afk-manager', 'TEMPLATE-MOD', 'datapack-fixer', 'rtwrapper-mod']
  .map(name => ({name, type: 'dir'})));
assert.equal(mods.length, 1);
assert.equal(mods[0].dir, 'afk-manager');

const btn = new Element('button'), status = new Element();
await s.startDownload(live, btn, status);
assert.equal(fetches, 1);
assert.match(status.textContent, /404/);
assert.equal(document.body.children.length, 0, '404 must not start a download');
console.log('Website fallback, live/cached assets, retirement and 404 checks passed.');
