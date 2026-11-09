import { createRequire } from 'node:module'; const require = createRequire('/home/claude/.npm-global/lib/node_modules/'); const { chromium } = require('playwright');
import { readFileSync, writeFileSync } from 'node:fs';
const [, , input, output] = process.argv;
const svg = readFileSync(input, 'utf8');
const b = await chromium.launch();
const p = await b.newPage();
await p.setContent(`<html><body>${svg.replace(/<\?xml[^>]*>/, '')}</body></html>`);
const out = await p.evaluate(() => {
  const nodes = [...document.querySelectorAll('g[data-pivot]')];
  const depth = (n) => { let d = 0; while (n.parentElement) { d++; n = n.parentElement; } return d; };
  nodes.sort((a, c) => depth(c) - depth(a));
  const info = [];
  for (const g of nodes) {
    const [px, py] = g.getAttribute('data-pivot').split(',').map(Number);
    const content = document.getElementById(g.id + '_content');
    const bb = content.getBBox();
    const rx = Math.max(px - bb.x, bb.x + bb.width - px);
    const ry = Math.max(py - bb.y, bb.y + bb.height - py);
    const r = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
    r.setAttribute('id', g.id + '_pivot_pad');
    r.setAttribute('x', (px - rx).toFixed(2)); r.setAttribute('y', (py - ry).toFixed(2));
    r.setAttribute('width', (2 * rx).toFixed(2)); r.setAttribute('height', (2 * ry).toFixed(2));
    r.setAttribute('fill', '#FFFFFF'); r.setAttribute('opacity', '0');
    content.appendChild(r);
    info.push(`${g.id}: pivot ${px},${py} bbox ${bb.x.toFixed(0)},${bb.y.toFixed(0)} ${bb.width.toFixed(0)}x${bb.height.toFixed(0)}`);
    g.removeAttribute('data-pivot');
  }
  const s = document.querySelector('svg');
  return { svg: s.outerHTML, info };
});
writeFileSync(output, '<?xml version="1.0" encoding="UTF-8"?>\n' + out.svg.replace('<svg ', '<svg xmlns="http://www.w3.org/2000/svg" ').replace('xmlns="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg"','xmlns="http://www.w3.org/2000/svg"'));
console.log(out.info.join('\n'));
await b.close();
