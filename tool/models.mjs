// Original low-poly models for the vocabulary words that have no CC0 source.
// These are the app's own artwork; see assets/models/LICENSES.txt.
//
// Usage (from this folder): npm install && node models.mjs ../assets/models [name ...]
import { mkdirSync } from 'node:fs';
import { Model, sphere, cylinder, cone, box, torus, extrude, tube, place, merge } from './geo.mjs';

const [,, outDir, ...only] = process.argv;
mkdirSync(outDir, { recursive: true });

// ---------- shared helpers ----------
const dome = (r, seg = 24, rings = 8, frac = 0.5) => {
  // upper part of a sphere: rings*frac of a full sphere, plus a flat base
  const full = sphere(r, seg, Math.round(rings / frac));
  const keepRings = rings;
  const pos = [], nor = [], idx = [];
  const rowLen = seg + 1;
  for (let y = 0; y <= keepRings; y++) for (let x = 0; x < rowLen; x++) {
    const i = (y * rowLen + x) * 3; pos.push(full.pos[i], full.pos[i + 1], full.pos[i + 2]); nor.push(full.nor[i], full.nor[i + 1], full.nor[i + 2]);
  }
  for (let y = 0; y < keepRings; y++) for (let x = 0; x < seg; x++) { const a = y * rowLen + x, b = a + rowLen; idx.push(a, a + 1, b, b, a + 1, b + 1); }
  // base disc
  const baseY = pos[(keepRings * rowLen) * 3 + 1];
  const rim = Math.hypot(pos[(keepRings * rowLen) * 3], pos[(keepRings * rowLen) * 3 + 2]);
  const c = pos.length / 3; pos.push(0, baseY, 0); nor.push(0, -1, 0);
  for (let x = 0; x <= seg; x++) { const th = (x / seg) * Math.PI * 2; pos.push(Math.cos(th) * rim, baseY, Math.sin(th) * rim); nor.push(0, -1, 0); }
  for (let x = 0; x < seg; x++) idx.push(c, c + 1 + x, c + 2 + x);
  return { pos, nor, idx };
};
const eye = (m, t, r = 0.12, look = [0, 0, 1]) => {
  m.add(sphere(r, 16, 10), '#ffffff', { t });
  m.add(sphere(r * 0.5, 12, 8), '#222222', { t: [t[0] + look[0] * r * 0.65, t[1] + look[1] * r * 0.65, t[2] + look[2] * r * 0.65] });
};
const legs4 = (m, hex, { r = 0.12, h = 0.6, dx = 0.35, dz = 0.22, y = 0.3 } = {}) => {
  for (const sx of [-1, 1]) for (const sz of [-1, 1]) m.add(cylinder(r, r * 0.9, h, 12), hex, { t: [sx * dx, y, sz * dz] });
};
const arc = (n, fn) => Array.from({ length: n }, (_, i) => fn(i / (n - 1)));
const deg = (d) => d * Math.PI / 180;

const models = {
  ant(m) {
    const k = '#3a2a1e';
    m.add(sphere(0.26, 20, 12), k, { t: [-0.62, 0.55, 0] });               // head
    m.add(sphere(0.22, 20, 12), k, { t: [-0.1, 0.55, 0] });                // thorax
    m.add(sphere(0.34, 20, 12), k, { t: [0.55, 0.55, 0], s: [1.35, 1, 1] }); // abdomen
    eye(m, [-0.78, 0.65, 0.16], 0.06, [-0.4, 0.2, 1]); eye(m, [-0.78, 0.65, -0.16], 0.06, [-0.4, 0.2, -1]);
    for (const sz of [-1, 1]) {
      for (const [x, ang] of [[-0.3, -35], [-0.08, 0], [0.16, 35]]) {
        const path = [[x, 0.5, sz * 0.15], [x + ang / 200, 0.62, sz * 0.5], [x + ang / 100, 0.02, sz * 0.75]];
        m.add(tube(path, 0.03, 8), k);
      }
      m.add(tube([[-0.75, 0.75, sz * 0.1], [-0.95, 1.05, sz * 0.32], [-1.1, 1.0, sz * 0.4]], 0.025, 8), k); // antenna
    }
  },
  airplane(m) {
    m.add(cylinder(0.24, 0.24, 2.2, 20), '#f4f4f4', { r: [0, 0, 90], t: [0, 0.8, 0] });      // fuselage
    m.add(sphere(0.24, 20, 12), '#f4f4f4', { t: [1.1, 0.8, 0], s: [1.2, 1, 1] });             // nose
    m.add(cylinder(0.1, 0.24, 0.7, 20), '#f4f4f4', { r: [0, 0, 90], t: [-1.45, 0.83, 0] });    // tail taper
    m.add(box(0.9, 0.06, 2.8), '#3b8beb', { t: [0.1, 0.7, 0] });                               // wings
    m.add(box(0.4, 0.05, 1.1), '#3b8beb', { t: [-1.55, 0.9, 0] });                             // stabilizers
    m.add(extrude([[0, 0], [0.5, 0], [0.15, 0.6], [-0.05, 0.6]], 0.06), '#e94f4f', { r: [0, 90, 0], t: [-1.55, 0.95, 0] }); // fin
    m.add(box(0.08, 0.7, 0.1), '#333333', { r: [0, 0, 0], t: [1.36, 0.8, 0] });                 // propeller
    m.add(box(0.08, 0.1, 0.7), '#333333', { t: [1.36, 0.8, 0] });
    m.add(sphere(0.09, 12, 8), '#333333', { t: [1.36, 0.8, 0] });
    for (const x of [0.6, 0.3, 0, -0.3, -0.6]) for (const sz of [-1, 1]) m.add(sphere(0.06, 10, 6), '#2a3d55', { t: [x, 0.88, sz * 0.22] });
    m.add(sphere(0.12, 12, 8), '#2a3d55', { t: [0.85, 0.95, 0], s: [1.4, 0.8, 1.2] });          // cockpit
    for (const sz of [-1, 1]) m.add(cylinder(0.06, 0.06, 0.15, 10), '#333333', { r: [90, 0, 0], t: [0.2, 0.42, sz * 0.5] }); // wheels
    for (const sz of [-1, 1]) m.add(cylinder(0.03, 0.03, 0.25, 8), '#888888', { t: [0.2, 0.55, sz * 0.5] });
  },
  drum(m) {
    m.add(cylinder(0.65, 0.65, 0.7, 28), '#d33a3a', { t: [0, 0.4, 0] });
    m.add(cylinder(0.62, 0.62, 0.04, 28), '#f6efd9', { t: [0, 0.77, 0] });
    for (const y of [0.76, 0.06]) m.add(torus(0.65, 0.045, 32, 10), '#e8c25c', { t: [0, y, 0] });
    for (let i = 0; i < 8; i++) { const a = deg(i * 45); m.add(cylinder(0.03, 0.03, 0.7, 8), '#e8c25c', { t: [Math.cos(a) * 0.66, 0.41, Math.sin(a) * 0.66] }); }
    for (const [x, rz] of [[-0.25, 25], [0.25, -25]]) {
      m.add(cylinder(0.03, 0.03, 1.1, 8), '#c99a5b', { r: [0, 0, rz], t: [x, 1.15, 0.15] });
      m.add(sphere(0.07, 12, 8), '#c99a5b', { t: [x - Math.sin(deg(rz)) * 0.55, 1.15 + Math.cos(deg(rz)) * 0.55, 0.15] });
    }
  },
  frog(m) {
    const g = '#4caf50', d = '#3e8e41';
    m.add(sphere(0.6, 24, 14), g, { t: [0, 0.45, 0], s: [1, 0.62, 0.85] });        // body
    m.add(sphere(0.45, 24, 14), '#c8e6a0', { t: [0, 0.32, 0.12], s: [0.9, 0.5, 0.8] }); // belly
    m.add(sphere(0.42, 24, 14), g, { t: [0, 0.6, 0.35], s: [1, 0.7, 0.8] });        // head
    for (const sx of [-1, 1]) {
      m.add(sphere(0.17, 16, 10), g, { t: [sx * 0.24, 0.9, 0.4] });               // eye sockets
      eye(m, [sx * 0.24, 0.92, 0.48], 0.12, [0, 0.2, 1]);
      m.add(sphere(0.26, 16, 10), d, { t: [sx * 0.58, 0.28, -0.2], s: [1, 0.7, 1.2] }); // back legs
      m.add(sphere(0.16, 12, 8), d, { t: [sx * 0.7, 0.08, 0.15], s: [1.3, 0.35, 1.6] }); // back feet
      m.add(cylinder(0.07, 0.07, 0.4, 10), d, { r: [20, 0, sx * -15], t: [sx * 0.3, 0.2, 0.55] }); // front legs
      m.add(sphere(0.1, 12, 8), d, { t: [sx * 0.34, 0.03, 0.72], s: [1.3, 0.3, 1.4] });
    }
    m.add(torus(0.22, 0.02, 24, 6, Math.PI), '#2b5e2e', { r: [90, 0, 0], t: [0, 0.5, 0.72] }); // smile
  },
  goat(m) {
    const w = '#e9e4d8';
    m.add(sphere(0.55, 24, 14), w, { t: [0, 0.85, 0], s: [1.4, 0.85, 0.8] });
    legs4(m, '#cfc8ba', { r: 0.09, h: 0.7, dx: 0.5, dz: 0.22, y: 0.35 });
    m.add(cylinder(0.18, 0.22, 0.5, 14), w, { r: [0, 0, -35], t: [0.75, 1.2, 0] });         // neck
    m.add(sphere(0.3, 20, 12), w, { t: [1.0, 1.42, 0], s: [1.25, 0.9, 0.8] });                // head
    m.add(sphere(0.14, 12, 8), '#e2b8b8', { t: [1.36, 1.35, 0], s: [0.8, 0.7, 0.9] });        // muzzle
    m.add(cone(0.08, 0.32, 10), '#d8d0c0', { r: [0, 0, 180], t: [1.28, 1.05, 0] });             // beard
    for (const sz of [-1, 1]) {
      m.add(tube(arc(6, (t) => [1.0 - t * 0.35, 1.65 + t * 0.55 - t * t * 0.25, sz * (0.1 + t * 0.2)]), 0.045, 8, (t) => 1 - t * 0.7), '#8d7357');
      m.add(sphere(0.1, 12, 8), w, { t: [0.95, 1.55, sz * 0.32], s: [1.2, 0.5, 0.6], r: [0, 0, sz * 20] });
      eye(m, [1.2, 1.5, sz * 0.2], 0.05, [0.6, 0.2, sz]);
    }
    m.add(sphere(0.1, 12, 8), w, { t: [-0.78, 1.05, 0], s: [1.2, 0.6, 0.6] });                 // tail
  },
  guitar(m) {
    const body = arc(41, (t) => { const a = t * Math.PI * 2; const r = 0.62 + 0.28 * Math.cos(a * 2) * (Math.sin(a) > 0 ? 0.5 : 1); return [Math.sin(a) * (0.72 - 0.16 * Math.max(0, Math.cos(a * 2))), Math.cos(a) * 0.95 - (Math.cos(a) > 0 ? 0.22 : 0) + 0]; });
    body.pop();
    m.add(extrude(body, 0.28), '#c9853d');
    m.add(cylinder(0.2, 0.2, 0.02, 24), '#1d1d1d', { r: [90, 0, 0], t: [0, 0.08, 0.145] });    // sound hole
    m.add(box(0.5, 0.12, 0.06), '#3b2a1e', { t: [0, -0.3, 0.15] });                             // bridge
    m.add(box(0.18, 1.7, 0.08), '#3b2a1e', { t: [0, 1.4, 0.06] });                              // neck
    m.add(box(0.26, 0.5, 0.08), '#2a1c12', { t: [0, 2.45, 0.06] });                             // headstock
    for (let i = 0; i < 6; i++) { const x = -0.075 + i * 0.03; m.add(cylinder(0.006, 0.006, 2.7, 6), '#e0e0e0', { t: [x, 1.05, 0.12] }); }
    for (let i = 0; i < 9; i++) m.add(box(0.18, 0.015, 0.01), '#d0d0d0', { t: [0, 0.75 + i * 0.17, 0.105] });
    for (const sx of [-1, 1]) for (let i = 0; i < 3; i++) m.add(sphere(0.035, 8, 6), '#e0e0e0', { t: [sx * 0.15, 2.3 + i * 0.13, 0.06] });
  },
  hat(m) {
    m.add(cylinder(0.95, 0.95, 0.06, 32), '#1c1c1c', { t: [0, 0.03, 0] });
    m.add(cylinder(0.52, 0.55, 0.85, 32), '#1c1c1c', { t: [0, 0.48, 0] });
    m.add(cylinder(0.565, 0.565, 0.17, 32), '#c62828', { t: [0, 0.18, 0] });
    m.add(torus(0.95, 0.035, 32, 8), '#2c2c2c', { t: [0, 0.05, 0] });
  },
  ice(m) {
    m.add(box(1, 1, 1), '#bfe6ff', { t: [0, 0.5, 0] }, { rough: 0.15 });
    m.add(box(0.8, 0.8, 0.8), '#cdeeff', { r: [0, 35, 0], t: [1.0, 0.4, 0.35] }, { rough: 0.15 });
    m.add(box(0.6, 0.6, 0.6), '#d9f2ff', { r: [0, -20, 0], t: [-0.55, 1.3, 0.2] }, { rough: 0.15 });
  },
  igloo(m) {
    m.add(dome(1.0, 28, 9, 0.5), '#f1f5f8');
    for (const y of [0.25, 0.5, 0.72]) { const r = Math.sqrt(1 - y * y); m.add(torus(r, 0.02, 32, 6), '#cfd8e0', { t: [0, y, 0] }); }
    for (let i = 0; i < 12; i++) m.add(box(0.02, 0.24, 0.02), '#cfd8e0', { r: [0, i * 30, 0], t: [Math.cos(deg(i * 30)) * 0.99, 0.12, Math.sin(deg(i * 30)) * 0.99] });
    m.add(place(dome(0.42, 20, 7, 0.5), { s: [1, 1, 1.6], t: [0, 0, 1.05] }), '#e8edf2');
    m.add(cylinder(0.3, 0.3, 0.02, 20), '#1a2733', { r: [90, 0, 0], t: [0, 0.02, 1.71], s: [1, 1, 1] });
    m.add(place(dome(0.3, 20, 6, 0.5), { t: [0, -0.005, 1.7], s: [1, 1, 0.05] }), '#1a2733');
  },
  jellyfish(m) {
    const p = '#f48fb1';
    m.add(dome(0.75, 28, 10, 0.5), p, { t: [0, 1.1, 0] });
    m.add(torus(0.73, 0.06, 32, 10), '#f06292', { t: [0, 1.1, 0] });
    for (let i = 0; i < 8; i++) {
      const a = deg(i * 45 + 20), r0 = 0.55;
      m.add(tube(arc(9, (t) => [Math.cos(a) * (r0 + Math.sin(t * 6) * 0.08), 1.05 - t * 1.4, Math.sin(a) * (r0 + Math.cos(t * 5) * 0.08)]), 0.035, 8, (t) => 1 - t * 0.6), '#f8bbd0');
    }
    for (let i = 0; i < 4; i++) { const a = deg(i * 90 + 45); m.add(tube(arc(7, (t) => [Math.cos(a) * 0.15 + Math.sin(t * 8 + i) * 0.06, 1.0 - t * 0.9, Math.sin(a) * 0.15]), 0.05, 8), '#ec407a'); }
    for (const sx of [-1, 1]) m.add(sphere(0.05, 10, 6), '#ad1457', { t: [sx * 0.2, 1.35, 0.6] });
  },
  kite(m) {
    m.add(extrude([[0, 1.0], [0.75, 0.1], [0, -1.35], [-0.75, 0.1]], 0.03), '#ef5350');
    m.add(extrude([[0, 1.0], [0.75, 0.1], [0, 0.1]], 0.04), '#ffca28');
    m.add(extrude([[0, -1.35], [-0.75, 0.1], [0, 0.1]], 0.04), '#ffca28');
    m.add(box(0.03, 2.35, 0.03), '#8d6e63', { t: [0, -0.175, 0.03] });
    m.add(box(1.5, 0.03, 0.03), '#8d6e63', { t: [0, 0.1, 0.03] });
    m.add(tube(arc(14, (t) => [Math.sin(t * 9) * 0.25, -1.35 - t * 1.6, Math.cos(t * 7) * 0.1]), 0.012, 6), '#795548');
    for (const t of [0.25, 0.55, 0.85]) m.add(box(0.28, 0.1, 0.03), t > 0.5 ? '#42a5f5' : '#66bb6a', { r: [0, 0, 30], t: [Math.sin(t * 9) * 0.25, -1.35 - t * 1.6, Math.cos(t * 7) * 0.1] });
  },
  king(m) {
    m.add(cylinder(0.32, 0.55, 1.2, 24), '#6a1b9a', { t: [0, 0.6, 0] });
    m.add(cylinder(0.33, 0.56, 0.18, 24), '#f5f5f5', { t: [0, 0.1, 0] });               // ermine hem
    m.add(sphere(0.32, 24, 14), '#ffcc9c', { t: [0, 1.5, 0] });
    m.add(sphere(0.22, 16, 10), '#e0e0e0', { t: [0, 1.32, 0.16], s: [1.2, 1, 0.8] });    // beard
    eye(m, [-0.11, 1.56, 0.28], 0.05, [0, 0, 1]); eye(m, [0.11, 1.56, 0.28], 0.05, [0, 0, 1]);
    m.add(cylinder(0.3, 0.3, 0.22, 24), '#ffc107', { t: [0, 1.84, 0] });
    for (let i = 0; i < 6; i++) { const a = deg(i * 60); m.add(cone(0.07, 0.25, 8), '#ffc107', { t: [Math.cos(a) * 0.27, 2.05, Math.sin(a) * 0.27] }); m.add(sphere(0.045, 8, 6), i % 2 ? '#e53935' : '#1e88e5', { t: [Math.cos(a) * 0.3, 1.86, Math.sin(a) * 0.3] }); }
    for (const sx of [-1, 1]) m.add(cylinder(0.09, 0.09, 0.7, 10), '#6a1b9a', { r: [0, 0, sx * 20], t: [sx * 0.5, 0.85, 0] });
    m.add(cylinder(0.04, 0.04, 1.3, 8), '#ffc107', { t: [0.72, 0.85, 0.05] }); m.add(sphere(0.1, 12, 8), '#e53935', { t: [0.72, 1.55, 0.05] }); // sceptre
  },
  kangaroo(m) {
    const b = '#c48c5a', l = '#e5c39c';
    m.add(sphere(0.5, 24, 14), b, { t: [0, 0.9, 0], s: [0.8, 1.15, 0.7], r: [-15, 0, 0] });
    m.add(sphere(0.3, 20, 12), l, { t: [0, 0.75, 0.28], s: [0.75, 0.9, 0.5] });                // pouch/belly
    m.add(cylinder(0.14, 0.2, 0.5, 14), b, { r: [25, 0, 0], t: [0, 1.5, 0.12] });
    m.add(sphere(0.25, 20, 12), b, { t: [0, 1.8, 0.35], s: [0.9, 0.85, 1.3] });                 // head
    m.add(sphere(0.07, 10, 6), '#3e2723', { t: [0, 1.75, 0.68] });
    for (const sx of [-1, 1]) {
      m.add(sphere(0.1, 12, 8), b, { t: [sx * 0.16, 2.12, 0.25], s: [0.6, 1.6, 0.5], r: [0, 0, sx * -15] });
      eye(m, [sx * 0.13, 1.88, 0.55], 0.05, [sx * 0.3, 0, 1]);
      m.add(sphere(0.2, 14, 8), b, { t: [sx * 0.42, 0.5, 0.05], s: [0.8, 1, 1.2] });          // thighs
      m.add(sphere(0.12, 12, 8), b, { t: [sx * 0.4, 0.12, 0.3], s: [1, 0.5, 2.6] });           // big feet
      m.add(cylinder(0.06, 0.06, 0.4, 8), b, { r: [-40, 0, sx * 10], t: [sx * 0.3, 1.2, 0.35] }); // arms
    }
    m.add(tube(arc(8, (t) => [0, 0.55 - t * 0.5 + t * t * 0.2, -0.3 - t * 1.2]), 0.14, 10, (t) => 1 - t * 0.6), b);
  },
  leaf(m) {
    const outline = arc(30, (t) => { const a = t * Math.PI * 2; return [Math.sin(a) * 0.55 * Math.pow(Math.abs(Math.sin(a)), 0.3) * (Math.cos(a) > 0 ? 1 : 1), Math.cos(a) * 1.1]; });
    outline.pop();
    m.add(extrude(outline, 0.03), '#43a047', { r: [-70, 0, 0], t: [0, 0.3, 0] });
    m.add(box(0.035, 2.1, 0.02), '#2e7d32', { r: [-70, 0, 0], t: [0, 0.32, 0.01] });
    for (const sx of [-1, 1]) for (let i = 0; i < 4; i++) m.add(box(0.02, 0.45, 0.02), '#2e7d32', { r: [-70, 0, sx * 55], t: [sx * 0.15, 0.32 + (i - 1.5) * 0.14, 0.1 - (i - 1.5) * 0.37] });
    m.add(cylinder(0.035, 0.035, 0.55, 8), '#6d4c41', { r: [-70, 0, 0], t: [0, 0.22, 1.28] });
  },
  moon(m) {
    m.add(sphere(1, 32, 20), '#d8dbe0', {}, { rough: 0.95 });
    for (const [rx, ry, r] of [[20, 0, 0.22], [-35, 40, 0.16], [50, 120, 0.2], [-10, 200, 0.14], [30, 260, 0.11], [-55, 300, 0.18], [70, 30, 0.12], [-25, 90, 0.1]]) {
      const p = place({ pos: [0, 0.995, 0], nor: [0, 1, 0], idx: [] }, { r: [rx, ry, 0] });
      m.add(cylinder(r, r * 0.8, 0.03, 20), '#aeb3ba', { r: [rx, ry, 0], t: p.pos });
      m.add(torus(r, 0.025, 20, 6), '#c5c9d0', { r: [rx, ry, 0], t: p.pos.map((v, i) => v * 1.005) });
    }
  },
  mango(m) {
    m.add(sphere(0.6, 28, 16), '#f9a825', { t: [0, 0.6, 0], s: [1.05, 0.8, 0.7], r: [0, 0, -20] });
    m.add(sphere(0.35, 20, 12), '#e64a19', { t: [-0.35, 0.8, 0.25], s: [1, 0.7, 0.6], r: [0, 0, -20] });
    m.add(cylinder(0.03, 0.04, 0.3, 8), '#6d4c41', { r: [0, 0, -20], t: [0.52, 1.0, 0] });
    m.add(extrude([[0, 0], [0.32, 0.12], [0.65, 0.02], [0.35, -0.1]], 0.02), '#43a047', { r: [10, 0, 35], t: [0.55, 1.05, 0.05] });
  },
  nest(m) {
    m.add(torus(0.75, 0.3, 32, 12), '#8d6e63', { t: [0, 0.3, 0] });
    m.add(cylinder(0.6, 0.6, 0.15, 24), '#795548', { t: [0, 0.2, 0] });
    for (let i = 0; i < 14; i++) { const a = deg(i * 26 + 7); m.add(tube(arc(4, (t) => [Math.cos(a + t * 0.6) * (0.55 + t * 0.55), 0.15 + Math.sin(t * 5 + i) * 0.15 + t * 0.2, Math.sin(a + t * 0.6) * (0.55 + t * 0.55)]), 0.025, 6), i % 2 ? '#a1887f' : '#6d4c41'); }
    for (const [x, z, ry] of [[-0.18, 0.05, 20], [0.2, 0.1, -30], [0.02, -0.22, 60]]) m.add(sphere(0.19, 20, 12), '#bde0fe', { t: [x, 0.42, z], s: [0.85, 1.15, 0.85], r: [0, ry, 15] });
  },
  nurse(m) {
    m.add(cylinder(0.3, 0.45, 1.15, 24), '#ffffff', { t: [0, 0.58, 0] });
    m.add(cylinder(0.31, 0.36, 0.3, 24), '#42a5f5', { t: [0, 0.95, 0] });                    // top
    m.add(sphere(0.3, 24, 14), '#ffcc9c', { t: [0, 1.48, 0] });
    m.add(sphere(0.32, 24, 14), '#5d4037', { t: [0, 1.58, -0.05], s: [1, 0.8, 1] });         // hair
    eye(m, [-0.1, 1.52, 0.27], 0.05, [0, 0, 1]); eye(m, [0.1, 1.52, 0.27], 0.05, [0, 0, 1]);
    m.add(torus(0.12, 0.02, 20, 6, Math.PI), '#c62828', { r: [90, 0, 0], t: [0, 1.38, 0.28] });
    m.add(box(0.5, 0.22, 0.4), '#ffffff', { t: [0, 1.9, 0] });                                // cap
    m.add(box(0.2, 0.06, 0.02), '#e53935', { t: [0, 1.92, 0.21] }); m.add(box(0.06, 0.2, 0.02), '#e53935', { t: [0, 1.92, 0.21] });
    m.add(box(0.22, 0.07, 0.02), '#e53935', { t: [0, 0.85, 0.36] }); m.add(box(0.07, 0.22, 0.02), '#e53935', { t: [0, 0.85, 0.36] });
    for (const sx of [-1, 1]) { m.add(cylinder(0.08, 0.08, 0.65, 10), '#42a5f5', { r: [0, 0, sx * 18], t: [sx * 0.45, 0.9, 0] }); m.add(sphere(0.09, 10, 6), '#ffcc9c', { t: [sx * 0.55, 0.58, 0] }); }
    m.add(tube(arc(9, (t) => [Math.cos(t * Math.PI) * 0.28, 1.15 - Math.sin(t * Math.PI) * 0.3, 0.3]), 0.025, 8), '#37474f'); // stethoscope
    m.add(sphere(0.07, 10, 6), '#78909c', { t: [-0.28, 1.15, 0.32] });
  },
  nut(m) {
    const t = '#d4a05a';
    m.add(sphere(0.42, 24, 14), t, { t: [-0.42, 0.42, 0], s: [1.1, 1, 0.95] }, { rough: 0.9 });
    m.add(sphere(0.38, 24, 14), t, { t: [0.42, 0.4, 0], s: [1.1, 0.95, 0.9] }, { rough: 0.9 });
    m.add(sphere(0.3, 20, 12), t, { t: [0, 0.4, 0], s: [1.4, 1, 1] }, { rough: 0.9 });
  },
  octopus(m) {
    const p = '#8e44ad', l = '#a569bd';
    m.add(sphere(0.6, 28, 16), p, { t: [0, 1.0, 0], s: [1, 1.15, 1] });
    eye(m, [-0.24, 1.05, 0.5], 0.13, [0, 0, 1]); eye(m, [0.24, 1.05, 0.5], 0.13, [0, 0, 1]);
    m.add(torus(0.15, 0.02, 20, 6, Math.PI), '#4a235a', { r: [90, 0, 0], t: [0, 0.82, 0.58] });
    for (let i = 0; i < 8; i++) {
      const a = deg(i * 45 + 22), wob = i % 2 ? 1 : -1;
      m.add(tube(arc(10, (t) => [Math.cos(a) * (0.35 + t * 1.0) + Math.sin(t * 4) * 0.15 * wob * Math.sin(a), 0.65 - t * 0.55 + Math.sin(t * 3) * 0.12, Math.sin(a) * (0.35 + t * 1.0) + Math.sin(t * 4) * 0.15 * wob * Math.cos(a)]), 0.14, 10, (t) => 1 - t * 0.75), i % 2 ? p : l);
    }
  },
  owl(m) {
    const b = '#8d6e63', c = '#d7ccc8';
    m.add(sphere(0.6, 28, 16), b, { t: [0, 0.75, 0], s: [0.9, 1.2, 0.85] });
    m.add(sphere(0.42, 24, 14), c, { t: [0, 0.6, 0.3], s: [0.85, 1.05, 0.5] });
    m.add(sphere(0.52, 28, 16), b, { t: [0, 1.5, 0], s: [1, 0.85, 0.9] });
    for (const sx of [-1, 1]) {
      m.add(cylinder(0.22, 0.22, 0.03, 20), '#ffe082', { r: [90, 0, 0], t: [sx * 0.22, 1.55, 0.44] });
      eye(m, [sx * 0.22, 1.55, 0.47], 0.16, [0, 0, 1]);
      m.add(cone(0.11, 0.35, 10), b, { r: [sx * -20, 0, sx * 30], t: [sx * 0.4, 1.95, 0] });         // ear tufts
      m.add(sphere(0.25, 20, 12), '#6d4c41', { t: [sx * 0.55, 0.8, 0], s: [0.5, 1.2, 0.8], r: [0, 0, sx * -10] }); // wings
      for (let k = -1; k <= 1; k++) m.add(cylinder(0.03, 0.02, 0.22, 6), '#ff8f00', { r: [90, 0, k * 25], t: [sx * 0.22 + k * 0.06, 0.05, 0.25] });
    }
    m.add(cone(0.08, 0.22, 8), '#ff8f00', { r: [-90, 0, 0], t: [0, 1.38, 0.5] });
  },
  pencil(m) {
    const L = 3.0;
    m.add(cylinder(0.17, 0.17, L, 6), '#fdd835', { t: [0, L / 2 + 0.55, 0] });
    m.add(cylinder(0.05, 0.17, 0.4, 6), '#e6c39a', { t: [0, 0.35, 0] });
    m.add(cone(0.05, 0.2, 6), '#333333', { r: [0, 0, 180], t: [0, 0.06, 0] });
    m.add(cylinder(0.175, 0.175, 0.2, 12), '#b0bec5', { t: [0, L + 0.65, 0] });
    m.add(cylinder(0.16, 0.16, 0.22, 12), '#f48fb1', { t: [0, L + 0.86, 0] });
    m.add(box(0.005, L, 0.4), '#f9a825', { t: [0, L / 2 + 0.55, 0] });
  },
  queen(m) {
    m.add(cylinder(0.3, 0.7, 1.25, 28), '#d81b60', { t: [0, 0.62, 0] });
    m.add(cylinder(0.31, 0.71, 0.1, 28), '#f8bbd0', { t: [0, 0.07, 0] });
    m.add(sphere(0.3, 24, 14), '#ffcc9c', { t: [0, 1.52, 0] });
    m.add(sphere(0.33, 24, 14), '#ffb300', { t: [0, 1.6, -0.05], s: [1, 0.85, 1] });
    for (const sx of [-1, 1]) m.add(cylinder(0.12, 0.14, 0.6, 12), '#ffb300', { t: [sx * 0.26, 1.2, -0.1] });   // long hair
    eye(m, [-0.1, 1.56, 0.27], 0.05, [0, 0, 1]); eye(m, [0.1, 1.56, 0.27], 0.05, [0, 0, 1]);
    m.add(torus(0.1, 0.018, 20, 6, Math.PI), '#c62828', { r: [90, 0, 0], t: [0, 1.42, 0.28] });
    m.add(torus(0.28, 0.04, 28, 8), '#ffc107', { t: [0, 1.85, 0] });
    for (let i = 0; i < 5; i++) { const a = deg(i * 36 + 90); m.add(cone(0.05, i === 2 ? 0.32 : 0.2, 8), '#ffc107', { t: [Math.cos(a) * 0.28, 1.95, -Math.sin(a) * 0.28 + 0.0] }); }
    m.add(sphere(0.06, 10, 6), '#e53935', { t: [0, 2.12, -0.28] });
    for (const sx of [-1, 1]) m.add(cylinder(0.08, 0.08, 0.65, 10), '#d81b60', { r: [0, 0, sx * 22], t: [sx * 0.48, 0.9, 0] });
    m.add(sphere(0.18, 12, 8), '#e53935', { t: [0, 1.15, 0.3], s: [0.6, 0.8, 0.5] });
  },
  question(m) {
    const c = '#5c6bc0';
    m.add(torus(0.55, 0.16, 32, 14, deg(270)), c, { r: [90, 0, -90], t: [0, 1.35, 0] });
    m.add(cylinder(0.16, 0.16, 0.5, 14), c, { t: [0, 0.55, 0] });
    m.add(sphere(0.2, 16, 10), c, { t: [0, 0.0, 0] });
  },
  rain(m) {
    for (const [x, y, r] of [[-0.6, 2.0, 0.42], [0, 2.2, 0.55], [0.6, 2.05, 0.45], [-0.3, 1.85, 0.4], [0.35, 1.8, 0.42]]) m.add(sphere(r, 20, 12), '#eceff1', { t: [x, y, 0] });
    m.add(box(1.7, 0.4, 0.8), '#eceff1', { t: [0, 1.75, 0] });
    for (let i = 0; i < 9; i++) {
      const x = -0.9 + i * 0.225, y = 0.3 + ((i * 7) % 5) * 0.25;
      m.add(sphere(0.08, 12, 8), '#42a5f5', { t: [x, y, ((i * 3) % 4 - 1.5) * 0.15] });
      m.add(cone(0.08, 0.2, 12), '#42a5f5', { t: [x, y + 0.13, ((i * 3) % 4 - 1.5) * 0.15] });
    }
  },
  sun(m) {
    m.add(sphere(0.75, 32, 20), '#ffd54f', {}, { emissive: '#7a5a00' });
    for (let i = 0; i < 12; i++) { const a = i * 30; m.add(cone(0.12, 0.5, 8), '#ffb300', { r: [0, 0, a - 90], t: [Math.cos(deg(a)) * 1.05, Math.sin(deg(a)) * 1.05, 0] }); }
    m.add(sphere(0.055, 10, 6), '#5d4037', { t: [-0.25, 0.15, 0.7] }); m.add(sphere(0.055, 10, 6), '#5d4037', { t: [0.25, 0.15, 0.7] });
    m.add(torus(0.22, 0.03, 20, 6, Math.PI), '#5d4037', { r: [90, 0, 0], t: [0, -0.1, 0.72] });
  },
  snake(m) {
    const path = arc(40, (t) => [Math.sin(t * 7.5) * 0.45 * (1 - t * 0.2), 0.16, -1.6 + t * 3.2]);
    m.add(tube(path, 0.17, 12, (t) => t < 0.25 ? 0.35 + t * 2.6 : 1), '#43a047');
    m.add(tube(path.map(p => [p[0], p[1] - 0.05, p[2]]), 0.12, 8, (t) => t < 0.25 ? 0.35 + t * 2.6 : 1), '#c5e1a5');
    for (let i = 0; i < 9; i++) m.add(torus(0.18, 0.03, 12, 6), '#2e7d32', { r: [90, 0, 0], t: [path[10 + i * 3][0], 0.16, path[10 + i * 3][2]] });
    const h = path[path.length - 1];
    m.add(sphere(0.26, 20, 12), '#43a047', { t: [h[0], 0.2, h[2] + 0.15], s: [1, 0.8, 1.3] });
    eye(m, [h[0] - 0.14, 0.32, h[2] + 0.3], 0.06, [0, 0.3, 1]); eye(m, [h[0] + 0.14, 0.32, h[2] + 0.3], 0.06, [0, 0.3, 1]);
    m.add(tube([[h[0], 0.15, h[2] + 0.45], [h[0], 0.15, h[2] + 0.75]], 0.02, 6), '#e53935');
    m.add(tube([[h[0], 0.15, h[2] + 0.75], [h[0] - 0.08, 0.15, h[2] + 0.9]], 0.02, 6), '#e53935'); m.add(tube([[h[0], 0.15, h[2] + 0.75], [h[0] + 0.08, 0.15, h[2] + 0.9]], 0.02, 6), '#e53935');
  },
  umbrella(m) {
    const colors = ['#e53935', '#fdd835', '#43a047', '#1e88e5'];
    m.add(dome(1.05, 32, 8, 0.42), '#e53935', { t: [0, 1.3, 0] });
    for (let i = 0; i < 8; i++) {
      const a = deg(i * 45);
      m.add(tube(arc(8, (t) => { const ph = t * deg(76); return [Math.cos(a) * Math.sin(ph) * 1.06, 1.3 + Math.cos(ph) * 1.06, Math.sin(a) * Math.sin(ph) * 1.06]; }), 0.02, 6), '#3e2723');
      m.add(sphere(0.06, 10, 6), colors[i % 4], { t: [Math.cos(a) * 1.03, 1.3 + Math.cos(deg(76)) * 1.06, Math.sin(a) * 1.03] });
    }
    m.add(cone(0.05, 0.25, 8), '#3e2723', { t: [0, 2.45, 0] });
    m.add(cylinder(0.035, 0.035, 2.0, 10), '#3e2723', { t: [0, 0.65, 0] });
    m.add(torus(0.22, 0.035, 20, 8, Math.PI), '#3e2723', { r: [90, 0, 0], t: [-0.22, -0.35, 0] });
  },
  unicorn(m) {
    const w = '#fafafa';
    m.add(sphere(0.55, 24, 14), w, { t: [0, 1.0, 0], s: [1.5, 0.85, 0.8] });
    legs4(m, '#eeeeee', { r: 0.1, h: 0.8, dx: 0.55, dz: 0.24, y: 0.4 });
    m.add(cylinder(0.18, 0.25, 0.8, 14), w, { r: [0, 0, -40], t: [0.85, 1.45, 0] });
    m.add(sphere(0.3, 20, 12), w, { t: [1.2, 1.85, 0], s: [1.3, 0.85, 0.8] });
    m.add(cone(0.07, 0.6, 8), '#ffd54f', { r: [0, 0, -30], t: [1.35, 2.3, 0] }, { emissive: '#4a3a00' });
    for (const sz of [-1, 1]) { m.add(cone(0.07, 0.25, 8), w, { r: [sz * 20, 0, 0], t: [1.05, 2.15, sz * 0.15] }); eye(m, [1.42, 1.92, sz * 0.2], 0.05, [0.6, 0.2, sz]); }
    m.add(sphere(0.13, 12, 8), '#f8bbd0', { t: [1.55, 1.78, 0], s: [0.8, 0.7, 0.9] });
    const mane = ['#f06292', '#ba68c8', '#4fc3f7', '#aed581', '#ffd54f'];
    for (let i = 0; i < 6; i++) m.add(sphere(0.13, 12, 8), mane[i % 5], { t: [1.15 - i * 0.16, 2.05 - i * 0.14, -0.12], s: [0.7, 1, 1] });
    m.add(tube(arc(7, (t) => [-0.8 - t * 0.5, 1.15 - t * 0.9 + t * t * 0.3, Math.sin(t * 4) * 0.1]), 0.1, 8, (t) => 1 - t * 0.4), '#f06292');
    m.add(tube(arc(7, (t) => [-0.82 - t * 0.5, 1.13 - t * 0.9 + t * t * 0.3, Math.sin(t * 4) * 0.1 + 0.1]), 0.06, 8, (t) => 1 - t * 0.4), '#ba68c8');
  },
  up(m) {
    m.add(extrude([[-0.3, -1.0], [0.3, -1.0], [0.3, 0.2], [0.75, 0.2], [0, 1.1], [-0.75, 0.2], [-0.3, 0.2]], 0.3), '#43a047', { t: [0, 1.1, 0] });
    m.add(cylinder(0.9, 0.9, 0.08, 32), '#a5d6a7', { t: [0, 0.04, 0] });
  },
  violin(m) {
    const outline = [];
    for (let i = 0; i < 48; i++) { const a = i / 48 * Math.PI * 2; const y = Math.cos(a); let r = 0.7 - 0.12 * Math.cos(a * 2); if (Math.abs(y) < 0.28) r = 0.42; if (y > 0.28) r = 0.62 - (y - 0.28) * 0.35; if (y < -0.28) r = 0.75 - (-y - 0.28) * 0.1; outline.push([Math.sin(a) * r, y * 1.05]); }
    m.add(extrude(outline, 0.25), '#b5651d');
    m.add(box(0.14, 2.0, 0.06), '#3e2723', { t: [0, 1.5, 0.05] });
    m.add(box(0.1, 1.3, 0.06), '#212121', { t: [0, 0.75, 0.16] });
    m.add(sphere(0.12, 12, 8), '#3e2723', { t: [0, 2.55, 0.05] });
    m.add(box(0.14, 0.4, 0.14), '#3e2723', { t: [0, 2.3, 0] });
    for (const sx of [-1, 1]) for (let i = 0; i < 2; i++) m.add(cylinder(0.03, 0.03, 0.14, 8), '#212121', { r: [0, 0, 90], t: [sx * 0.12, 2.2 + i * 0.16, 0] });
    for (let i = 0; i < 4; i++) m.add(cylinder(0.005, 0.005, 2.6, 6), '#eeeeee', { t: [-0.045 + i * 0.03, 1.05, 0.2] });
    m.add(box(0.36, 0.14, 0.04), '#d7ccc8', { t: [0, -0.15, 0.2] });
    m.add(box(0.12, 0.5, 0.05), '#212121', { t: [0, -0.7, 0.15] });
    for (const sx of [-1, 1]) m.add(box(0.03, 0.4, 0.02), '#212121', { r: [0, 0, sx * 12], t: [sx * 0.3, 0.05, 0.13] });
    m.add(cylinder(0.02, 0.02, 2.8, 8), '#3e2723', { r: [0, 0, 70], t: [1.0, 0.6, 0.35] });
    m.add(box(2.6, 0.03, 0.01), '#f5f5f5', { r: [0, 0, 70], t: [1.05, 0.62, 0.35] });
  },
  volcano(m) {
    m.add(cylinder(0.45, 1.4, 1.3, 28), '#6d4c41', { t: [0, 0.65, 0] });
    m.add(cylinder(0.32, 0.32, 0.05, 24), '#ff7043', { t: [0, 1.32, 0] }, { emissive: '#5a1a00' });
    for (const a of [10, 130, 250]) m.add(tube(arc(6, (t) => [Math.cos(deg(a)) * (0.4 + t * 0.85), 1.3 - t * 1.15, Math.sin(deg(a)) * (0.4 + t * 0.85)]), 0.08, 8, (t) => 1 - t * 0.5), '#ff5722', {}, { emissive: '#4a1500' });
    for (const [x, y, z, r] of [[0, 1.75, 0, 0.3], [0.25, 2.05, 0.1, 0.35], [-0.2, 2.35, -0.1, 0.3], [0.1, 2.6, 0.2, 0.25]]) m.add(sphere(r, 16, 10), '#9e9e9e', { t: [x, y, z] });
    m.add(cylinder(1.4, 1.5, 0.08, 28), '#4caf50', { t: [0, 0.04, 0] });
  },
  water(m) {
    const drop = (r) => merge(sphere(r, 20, 12), place(cone(r * 0.98, r * 1.6, 20), { t: [0, r * 0.75, 0] }));
    m.add(drop(0.5), '#42a5f5', { t: [0, 0.5, 0] }, { rough: 0.3 });
    m.add(drop(0.22), '#64b5f6', { t: [0.75, 0.25, 0.2] }, { rough: 0.3 });
    m.add(drop(0.16), '#90caf9', { t: [-0.65, 0.2, -0.1] }, { rough: 0.3 });
    m.add(sphere(0.08, 10, 6), '#e3f2fd', { t: [-0.18, 0.62, 0.42] });
  },
  xylophone(m) {
    const colors = ['#e53935', '#fb8c00', '#fdd835', '#43a047', '#1e88e5', '#3949ab', '#8e24aa', '#ec407a'];
    for (const sz of [-1, 1]) m.add(extrude([[-1.3, 0], [1.3, 0], [1.3, 0.2], [-1.3, 0.2]], 0.1), '#8d6e63', { r: [0, 0, 0], t: [0, 0, sz * 0.55] });
    for (let i = 0; i < 8; i++) { const x = -1.1 + i * 0.315, len = 1.5 - i * 0.12; m.add(box(0.26, 0.08, len), colors[i], { t: [x, 0.25, 0] }); for (const sz of [-1, 1]) m.add(sphere(0.025, 8, 6), '#9e9e9e', { t: [x, 0.3, sz * 0.45] }); }
    for (const [x, rz] of [[-0.5, 30], [0.5, -30]]) { m.add(cylinder(0.025, 0.025, 1.0, 8), '#a1887f', { r: [0, 0, rz], t: [x, 0.8, 0.9] }); m.add(sphere(0.09, 12, 8), '#3e2723', { t: [x - Math.sin(deg(rz)) * 0.5, 0.8 + Math.cos(deg(rz)) * 0.5, 0.9] }); }
  },
  yak(m) {
    const d = '#4e342e';
    m.add(sphere(0.7, 24, 14), d, { t: [0, 1.0, 0], s: [1.5, 0.9, 0.9] });
    m.add(sphere(0.35, 20, 12), d, { t: [0.3, 1.55, 0], s: [1, 0.6, 0.9] });                    // hump
    for (let i = 0; i < 9; i++) for (const sz of [-1, 1]) m.add(box(0.14, 0.45, 0.08), '#3e2723', { t: [-0.85 + i * 0.21, 0.55, sz * 0.62] });   // shaggy fringe
    legs4(m, d, { r: 0.13, h: 0.7, dx: 0.6, dz: 0.3, y: 0.35 });
    m.add(sphere(0.34, 20, 12), d, { t: [1.05, 1.15, 0], s: [1.2, 0.9, 0.9] });                  // head
    m.add(sphere(0.2, 16, 10), '#8d6e63', { t: [1.38, 1.05, 0], s: [0.8, 0.7, 1] });             // muzzle
    m.add(sphere(0.25, 16, 10), '#5d4037', { t: [1.0, 1.42, 0], s: [1, 0.5, 1.1] });              // forelock
    for (const sz of [-1, 1]) { m.add(tube(arc(7, (t) => [1.0 + t * 0.2, 1.3 + t * 0.55, sz * (0.25 + t * 0.55 - t * t * 0.25)]), 0.06, 8, (t) => 1 - t * 0.6), '#d7ccc8'); eye(m, [1.28, 1.25, sz * 0.22], 0.05, [0.6, 0.1, sz]); }
    m.add(tube(arc(6, (t) => [-1.0 - t * 0.35, 1.1 - t * 0.7, 0]), 0.05, 8), d); m.add(sphere(0.14, 12, 8), '#3e2723', { t: [-1.38, 0.35, 0], s: [0.7, 1.3, 0.7] });
  },
  yarn(m) {
    m.add(sphere(0.8, 32, 20), '#ec407a');
    for (let i = 0; i < 14; i++) m.add(torus(0.8, 0.032, 48, 8), i % 2 ? '#d81b60' : '#f06292', { r: [(i * 37) % 180, (i * 61) % 180, (i * 23) % 180] });
    m.add(tube(arc(10, (t) => [0.6 + t * 1.2, -0.6 - Math.sin(t * 3) * 0.2 - t * 0.15, 0.4 + Math.cos(t * 4) * 0.25]), 0.035, 8), '#ec407a');
  },
  yogurt(m) {
    m.add(cylinder(0.55, 0.42, 0.95, 28), '#fafafa', { t: [0, 0.48, 0] });
    m.add(cylinder(0.53, 0.47, 0.34, 28), '#42a5f5', { t: [0, 0.5, 0] });
    m.add(cylinder(0.58, 0.58, 0.05, 28), '#90caf9', { t: [0, 0.98, 0] });
    m.add(box(0.28, 0.02, 0.25), '#90caf9', { r: [0, 0, 25], t: [0.62, 1.05, 0] });
    m.add(cylinder(0.5, 0.5, 0.06, 28), '#fff3e0', { t: [0, 0.99, 0] });
    m.add(sphere(0.13, 14, 8), '#e53935', { t: [0.15, 1.1, 0.1], s: [1, 1.2, 1] }); m.add(cone(0.06, 0.1, 6), '#43a047', { t: [0.15, 1.3, 0.1] });
    m.add(cylinder(0.025, 0.025, 1.1, 8), '#eeeeee', { r: [0, 0, -30], t: [-0.4, 1.3, 0] });
    m.add(sphere(0.12, 12, 8), '#eeeeee', { t: [-0.13, 1.78, 0], s: [1, 0.5, 0.8], r: [0, 0, -30] });
  },
  zipper(m) {
    for (const sx of [-1, 1]) m.add(box(0.42, 2.6, 0.06), '#1e88e5', { t: [sx * 0.31, 1.3, 0] });
    for (let i = 0; i < 24; i++) { const sx = i % 2 ? 1 : -1; m.add(box(0.14, 0.09, 0.09), '#cfd8dc', { t: [sx * 0.07, 0.08 + i * 0.106, 0.02] }); }
    m.add(box(0.28, 0.32, 0.14), '#78909c', { t: [0, 1.45, 0.05] });
    m.add(box(0.12, 0.45, 0.05), '#90a4ae', { r: [0, 0, 0], t: [0, 1.1, 0.14] });
    m.add(torus(0.07, 0.025, 16, 6), '#90a4ae', { r: [90, 0, 0], t: [0, 0.83, 0.14] });
    m.add(box(0.28, 0.12, 0.14), '#78909c', { t: [0, 2.68, 0.02] });
  },
  zoo(m) {
    const stone = '#a1887f';
    for (const sx of [-1, 1]) m.add(box(0.5, 2.6, 0.5), stone, { t: [sx * 1.6, 1.3, 0] });
    for (const sx of [-1, 1]) m.add(box(0.7, 0.2, 0.7), '#8d6e63', { t: [sx * 1.6, 2.7, 0] });
    m.add(box(3.9, 0.7, 0.2), '#43a047', { t: [0, 3.1, 0] });
    m.add(extrude([[-0.25, 0.25], [0.25, 0.25], [0.25, 0.12], [-0.05, -0.12], [0.25, -0.12], [0.25, -0.25], [-0.25, -0.25], [-0.25, -0.12], [0.05, 0.12], [-0.25, 0.12]], 0.1), '#fdd835', { t: [-0.75, 3.1, 0.15] });
    for (const x of [0, 0.75]) m.add(torus(0.2, 0.07, 24, 8), '#fdd835', { r: [90, 0, 0], t: [x, 3.1, 0.15] });
    for (let i = 0; i < 9; i++) m.add(cylinder(0.04, 0.04, 1.6, 8), '#37474f', { t: [-1.2 + i * 0.3, 0.8, 0] });
    for (const y of [0.3, 1.5]) m.add(box(2.5, 0.06, 0.06), '#37474f', { t: [0, y, 0] });
    m.add(cylinder(2.4, 2.4, 0.06, 32), '#a5d6a7', { t: [0, 0.03, 0] });
  },
};

const names = only.length ? only : Object.keys(models);
for (const name of names) {
  const m = new Model(name);
  models[name](m);
  await m.write(`${outDir}/${name}.glb`);
  console.log('wrote', name, m.parts.length, 'parts');
}
