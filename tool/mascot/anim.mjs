import { createRequire } from 'node:module';
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
const require = createRequire(process.argv[2] + '/');
const { chromium } = require('playwright');
const SVG = readFileSync('relaxmate-mascot-rig.svg', 'utf8').replace(/<\?xml[^>]*>/, '');
const W = Number(process.argv[3] || 396), H = Math.round(W * 900 / 660);
const FPSMAP = { idle: 24, listening: 24, thinking: 24, speaking: 24 };
const f = (s, fr = 0) => s + fr / 60; // detik + frame(60fps)

// Setiap properti: array [waktu(detik), nilai]. dx/dy = selisih posisi dari nilai dasar.
const both = (arr, p) => arr;
const STATES = {
  idle: { dur: 4, tracks: {
    torso: { sy: [[0,1],[2,1.02],[4,1]], sx: [[0,1],[2,1.008],[4,1]] },
    rig_root: { dy: [[0,0],[2,-2],[4,0]] },
    head_group: { dy: [[0,0],[f(2,10),-2],[4,0]], rot: [[0,0],[1,1.5],[2,0],[3,-1.5],[4,0]] },
    face_group: { dx: [[0,0],[f(1,10),2],[f(2,10),0],[f(3,10),-2],[4,0]] },
    antenna_left: { rot: [[0,0],[f(1,20),4],[f(3,10),-2],[4,0]] },
    antenna_ball_left: { rot: [[0,0],[2,-7],[f(3,30),4],[4,0]] },
    antenna_right: { rot: [[0,0],[f(1,10),-3],[f(2,40),2],[4,0]] },
    antenna_ball_right: { rot: [[0,0],[f(1,30),5],[3,-3],[4,0]] },
    arm_left: { rot: [[0,0],[f(2,15),1.5],[4,0]] },
    forearm_left: { rot: [[0,0],[f(2,35),2.5],[4,0]] },
    arm_right: { rot: [[0,0],[f(2,15),-1.5],[4,0]] },
    forearm_right: { rot: [[0,0],[f(2,35),-2.5],[4,0]] },
    eye_left: { sy: [[0,1],[3,1],[f(3,5),0.08],[f(3,12),1],[4,1]] },
    eye_right: { sy: [[0,1],[3,1],[f(3,5),0.08],[f(3,12),1],[4,1]] },
  }},
  listening: { dur: 2, tracks: {
    head_group: { rot: [[0,6],[1,7],[2,6]], dy: [[0,-2],[1,-3],[2,-2]] },
    face_group: { dx: [[0,2],[1,3],[2,2]] },
    eye_left: { sx: [[0,1.12],[1,1.14],[2,1.12]], sy: [[0,1.12],[1,1.14],[2,1.12]] },
    eye_right: { sx: [[0,1.12],[1,1.14],[2,1.12]], sy: [[0,1.12],[1,1.14],[2,1.12]] },
    ear_left: { rot: [[0,-10],[1,-12],[2,-10]] },
    ear_right: { rot: [[0,10],[1,12],[2,10]] },
    antenna_ball_left: { rot: [[0,0],[f(0,40),5],[f(1,20),-5],[2,0]] },
    antenna_ball_right: { rot: [[0,0],[f(0,55),-5],[f(1,35),5],[2,0]] },
  }},
  thinking: { dur: 3, tracks: {
    head_group: { rot: [[0,-5],[1.5,-6],[3,-5]] },
    face_group: { dx: [[0,-2],[3,-2]] },
    eye_left: { sy: [[0,0.88],[3,0.88]], dy: [[0,-8],[3,-8]],
      dx: [[0,10],[1,10],[f(1,8),-10],[2,-10],[f(2,8),10],[3,10]] },
    eye_right: { sy: [[0,0.88],[3,0.88]], dy: [[0,-8],[3,-8]],
      dx: [[0,10],[1,10],[f(1,8),-10],[2,-10],[f(2,8),10],[3,10]] },
    mouth_smile: { sx: [[0,0],[3,0]], sy: [[0,0],[3,0]] },
    mouth_flat: { sx: [[0,1],[3,1]], sy: [[0,1],[3,1]] },
    antenna_ball_left: { sx: [[0,1],[.5,1.35],[1,1],[1.5,1.35],[2,1],[2.5,1.35],[3,1]],
                         sy: [[0,1],[.5,1.35],[1,1],[1.5,1.35],[2,1],[2.5,1.35],[3,1]] },
  }},
  speaking: { dur: 1, tracks: {
    mouth_smile: { sx: [[0,0],[1,0]], sy: [[0,0],[1,0]] },
    mouth_open: {
      sy: [[0,.10],[f(0,8),1],[f(0,16),.4],[f(0,26),.9],[f(0,36),.15],[f(0,46),1],[1,.10]],
      sx: [[0,1.2],[f(0,8),1.5],[f(0,16),1.15],[f(0,26),1.5],[f(0,36),1.2],[f(0,46),1.5],[1,1.2]] },
    head_group: { dy: [[0,0],[f(0,15),-2],[f(0,30),0],[f(0,45),-2],[1,0]],
                  rot: [[0,0],[f(0,20),1.5],[f(0,40),-1.5],[1,0]] },
    antenna_ball_left: { rot: [[0,0],[f(0,20),6],[f(0,40),-6],[1,0]] },
    antenna_ball_right: { rot: [[0,0],[f(0,25),-6],[f(0,45),6],[1,0]] },
  }},
};

// cubic-bezier(0.42,0,0.58,1)
function ease(x) {
  const p1x=.42,p1y=0,p2x=.58,p2y=1;
  const bx=t=>3*(1-t)*(1-t)*t*p1x+3*(1-t)*t*t*p2x+t*t*t;
  const by=t=>3*(1-t)*(1-t)*t*p1y+3*(1-t)*t*t*p2y+t*t*t;
  let lo=0,hi=1;for(let i=0;i<30;i++){const m=(lo+hi)/2;bx(m)<x?lo=m:hi=m;}
  return by((lo+hi)/2);
}
function sample(keys, t) {
  if (t <= keys[0][0]) return keys[0][1];
  for (let i = 0; i < keys.length - 1; i++) {
    const [t0, v0] = keys[i], [t1, v1] = keys[i+1];
    if (t <= t1) return v0 + (v1 - v0) * ease((t - t0) / (t1 - t0));
  }
  return keys[keys.length-1][1];
}

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: 1 });
await page.setContent(`<html><body style="margin:0;background:transparent">${SVG}</body></html>`);
await page.evaluate(([W,H]) => { const s=document.querySelector('svg'); s.setAttribute('width',W); s.setAttribute('height',H); }, [W,H]);
// ambil nilai dasar tiap node
const base = await page.evaluate(() => {
  const out = {};
  document.querySelectorAll('g[id]').forEach(g => {
    const m = /translate\(([-\d.]+) ([-\d.]+)\)(?: scale\(([-\d.]+)\))?/.exec(g.getAttribute('transform')||'');
    if (m && !g.id.endsWith('_content')) out[g.id] = { x:+m[1], y:+m[2], s: m[3]?+m[3]:1 };
  });
  return out;
});
mkdirSync('anim', { recursive: true });
for (const [name, st] of Object.entries(STATES)) {
  const FPS = FPSMAP[name]; const N = Math.round(st.dur * FPS);
  for (let k = 0; k < N; k++) {
    const t = k / FPS;
    const updates = {};
    for (const [id, props] of Object.entries(st.tracks)) {
      const b = base[id]; if (!b) throw new Error('node tidak ada: ' + id);
      const v = { dx:0, dy:0, rot:0, sx:b.s, sy:b.s };
      for (const [p, keys] of Object.entries(props)) v[p] = sample(keys, t);
      updates[id] = `translate(${b.x+v.dx} ${b.y+v.dy}) rotate(${v.rot}) scale(${v.sx} ${v.sy})`;
    }
    await page.evaluate(u => { for (const [id, tr] of Object.entries(u)) document.getElementById(id).setAttribute('transform', tr); }, updates);
    await page.screenshot({ path: `anim/${name}_${String(k).padStart(3,'0')}.png`, omitBackground: true, clip: {x:0,y:0,width:W,height:H} });
  }
  // kembalikan ke dasar
  await page.evaluate(b => { for (const [id, v] of Object.entries(b)) document.getElementById(id).setAttribute('transform', `translate(${v.x} ${v.y})` + (v.s!==1?` scale(${v.s})`:'')); }, base);
  console.log(name, N, 'frame');
}
await browser.close();
