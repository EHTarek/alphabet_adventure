// Tiny procedural-geometry toolkit for building original low-poly GLB models.
// Every builder returns {pos: number[], nor: number[], idx: number[]} in Y-up
// space; `place()` applies translate/rotate/scale; `Model` collects coloured
// parts and writes a self-contained GLB.
import { Document, NodeIO } from '@gltf-transform/core';
import { dedup, prune, unpartition } from '@gltf-transform/functions';
import earcut from 'earcut';

const TAU = Math.PI * 2;

// ---------- primitives ----------
export function sphere(r = 1, seg = 24, rings = 14) {
  const pos = [], nor = [], idx = [];
  for (let y = 0; y <= rings; y++) {
    const v = y / rings, phi = v * Math.PI;
    for (let x = 0; x <= seg; x++) {
      const u = x / seg, th = u * TAU;
      const nx = Math.sin(phi) * Math.cos(th), ny = Math.cos(phi), nz = Math.sin(phi) * Math.sin(th);
      pos.push(nx * r, ny * r, nz * r); nor.push(nx, ny, nz);
    }
  }
  for (let y = 0; y < rings; y++) for (let x = 0; x < seg; x++) {
    const a = y * (seg + 1) + x, b = a + seg + 1;
    idx.push(a, a + 1, b, b, a + 1, b + 1);
  }
  return { pos, nor, idx };
}

export function cylinder(rTop = 1, rBot = 1, h = 1, seg = 24, caps = true) {
  const pos = [], nor = [], idx = [];
  const slope = (rBot - rTop) / h;
  for (let x = 0; x <= seg; x++) {
    const th = (x / seg) * TAU, c = Math.cos(th), s = Math.sin(th);
    const len = Math.hypot(1, slope);
    pos.push(c * rTop, h / 2, s * rTop); nor.push(c / len, slope / len, s / len);
    pos.push(c * rBot, -h / 2, s * rBot); nor.push(c / len, slope / len, s / len);
  }
  for (let x = 0; x < seg; x++) {
    const a = x * 2, b = a + 1, c = a + 2, d = a + 3;
    idx.push(a, c, b, b, c, d);
  }
  if (caps) {
    for (const [r, y, ny] of [[rTop, h / 2, 1], [rBot, -h / 2, -1]]) {
      if (r <= 0) continue;
      const center = pos.length / 3;
      pos.push(0, y, 0); nor.push(0, ny, 0);
      for (let x = 0; x <= seg; x++) {
        const th = (x / seg) * TAU;
        pos.push(Math.cos(th) * r, y, Math.sin(th) * r); nor.push(0, ny, 0);
      }
      for (let x = 0; x < seg; x++) {
        if (ny > 0) idx.push(center, center + 2 + x, center + 1 + x);
        else idx.push(center, center + 1 + x, center + 2 + x);
      }
    }
  }
  return { pos, nor, idx };
}
export const cone = (r, h, seg = 24) => cylinder(0, r, h, seg);

export function box(w = 1, h = 1, d = 1) {
  const x = w / 2, y = h / 2, z = d / 2;
  const faces = [
    [[1, 0, 0], [[x, -y, -z], [x, y, -z], [x, y, z], [x, -y, z]]],
    [[-1, 0, 0], [[-x, -y, z], [-x, y, z], [-x, y, -z], [-x, -y, -z]]],
    [[0, 1, 0], [[-x, y, -z], [-x, y, z], [x, y, z], [x, y, -z]]],
    [[0, -1, 0], [[-x, -y, z], [-x, -y, -z], [x, -y, -z], [x, -y, z]]],
    [[0, 0, 1], [[-x, -y, z], [x, -y, z], [x, y, z], [-x, y, z]]],
    [[0, 0, -1], [[x, -y, -z], [-x, -y, -z], [-x, y, -z], [x, y, -z]]],
  ];
  const pos = [], nor = [], idx = [];
  for (const [n, v] of faces) {
    const base = pos.length / 3;
    for (const p of v) { pos.push(...p); nor.push(...n); }
    idx.push(base, base + 1, base + 2, base, base + 2, base + 3);
  }
  return { pos, nor, idx };
}

export function torus(R = 1, r = 0.3, seg = 32, tube = 12, arc = TAU) {
  const pos = [], nor = [], idx = [];
  const closed = arc >= TAU - 1e-6;
  for (let i = 0; i <= seg; i++) {
    const u = (i / seg) * arc, cu = Math.cos(u), su = Math.sin(u);
    for (let j = 0; j <= tube; j++) {
      const v = (j / tube) * TAU, cv = Math.cos(v), sv = Math.sin(v);
      pos.push((R + r * cv) * cu, r * sv, (R + r * cv) * su);
      nor.push(cv * cu, sv, cv * su);
    }
  }
  for (let i = 0; i < seg; i++) for (let j = 0; j < tube; j++) {
    const a = i * (tube + 1) + j, b = a + tube + 1;
    idx.push(a, a + 1, b, b, a + 1, b + 1);
  }
  if (!closed) { // cap the ends with flat discs
    for (const [i, flip] of [[0, true], [seg, false]]) {
      const u = (i / seg) * arc, cu = Math.cos(u), su = Math.sin(u);
      const n = flip ? [su, 0, -cu] : [-su, 0, cu];
      const c = pos.length / 3;
      pos.push(R * cu, 0, R * su); nor.push(...n);
      for (let j = 0; j <= tube; j++) {
        const v = (j / tube) * TAU, cv = Math.cos(v), sv = Math.sin(v);
        pos.push((R + r * cv) * cu, r * sv, (R + r * cv) * su); nor.push(...n);
      }
      for (let j = 0; j < tube; j++) flip ? idx.push(c, c + 1 + j, c + 2 + j) : idx.push(c, c + 2 + j, c + 1 + j);
    }
  }
  return { pos, nor, idx };
}

/// Flat polygon (array of [x,y]) extruded along Z by `depth`, flat-shaded.
export function extrude(poly, depth = 0.2) {
  const flat = poly.flat();
  const tris = earcut(flat);
  const pos = [], nor = [], idx = [];
  const z = depth / 2;
  // front (+z) and back (-z)
  for (const [sign, order] of [[1, [0, 1, 2]], [-1, [0, 2, 1]]]) {
    const base = pos.length / 3;
    for (const [x, y] of poly) { pos.push(x, y, sign * z); nor.push(0, 0, sign); }
    for (let t = 0; t < tris.length; t += 3) idx.push(base + tris[t + order[0]], base + tris[t + order[1]], base + tris[t + order[2]]);
  }
  // sides
  for (let i = 0; i < poly.length; i++) {
    const [x1, y1] = poly[i], [x2, y2] = poly[(i + 1) % poly.length];
    const nx = y2 - y1, ny = -(x2 - x1), len = Math.hypot(nx, ny) || 1;
    const base = pos.length / 3;
    pos.push(x1, y1, z, x2, y2, z, x2, y2, -z, x1, y1, -z);
    for (let k = 0; k < 4; k++) nor.push(nx / len, ny / len, 0);
    idx.push(base, base + 2, base + 1, base, base + 3, base + 2);
  }
  // earcut gives CCW for CCW input; if the polygon is CW the front face winds
  // the wrong way, so orient by signed area.
  let area = 0;
  for (let i = 0; i < poly.length; i++) { const [x1, y1] = poly[i], [x2, y2] = poly[(i + 1) % poly.length]; area += x1 * y2 - x2 * y1; }
  if (area < 0) { for (let t = 0; t < idx.length; t += 3) { const tmp = idx[t + 1]; idx[t + 1] = idx[t + 2]; idx[t + 2] = tmp; } for (let k = 0; k < nor.length; k += 3) { nor[k] = -nor[k]; nor[k + 1] = -nor[k + 1]; nor[k + 2] = -nor[k + 2]; } }
  return { pos, nor, idx };
}

/// Sweeps a circle of radius r(t) along a polyline of [x,y,z] points.
export function tube(path, r = 0.1, seg = 12, taper = null) {
  const pos = [], nor = [], idx = [];
  const n = path.length;
  let prevN = null;
  for (let i = 0; i < n; i++) {
    const p = path[i];
    const a = path[Math.max(i - 1, 0)], b = path[Math.min(i + 1, n - 1)];
    let t = [b[0] - a[0], b[1] - a[1], b[2] - a[2]];
    const tl = Math.hypot(...t) || 1; t = t.map(v => v / tl);
    let up = Math.abs(t[1]) < 0.9 ? [0, 1, 0] : [1, 0, 0];
    let nx = cross(up, t); const nl = Math.hypot(...nx) || 1; nx = nx.map(v => v / nl);
    if (prevN && dot(prevN, nx) < 0) nx = nx.map(v => -v);
    prevN = nx;
    const bn = cross(t, nx);
    const rad = taper ? taper(i / (n - 1)) * r : r;
    for (let j = 0; j <= seg; j++) {
      const th = (j / seg) * TAU, c = Math.cos(th), s = Math.sin(th);
      const nrm = [nx[0] * c + bn[0] * s, nx[1] * c + bn[1] * s, nx[2] * c + bn[2] * s];
      pos.push(p[0] + nrm[0] * rad, p[1] + nrm[1] * rad, p[2] + nrm[2] * rad); nor.push(...nrm);
    }
  }
  for (let i = 0; i < n - 1; i++) for (let j = 0; j < seg; j++) {
    const a = i * (seg + 1) + j, b = a + seg + 1;
    idx.push(a, a + 1, b, b, a + 1, b + 1);
  }
  // end caps
  for (const [i, flip] of [[0, false], [n - 1, true]]) {
    const p = path[i], c = pos.length / 3;
    const a = path[Math.max(i - 1, 0)], b = path[Math.min(i + 1, n - 1)];
    let t = [b[0] - a[0], b[1] - a[1], b[2] - a[2]]; const tl = Math.hypot(...t) || 1; t = t.map(v => v / tl * (flip ? 1 : -1));
    pos.push(...p); nor.push(...t);
    const ring = i * (seg + 1);
    for (let j = 0; j <= seg; j++) { pos.push(pos[(ring + j) * 3], pos[(ring + j) * 3 + 1], pos[(ring + j) * 3 + 2]); nor.push(...t); }
    for (let j = 0; j < seg; j++) flip ? idx.push(c, c + 1 + j, c + 2 + j) : idx.push(c, c + 2 + j, c + 1 + j);
  }
  return { pos, nor, idx };
}
const cross = (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]];
const dot = (a, b) => a[0] * b[0] + a[1] * b[1] + a[2] * b[2];

// ---------- transforms ----------
/// Applies scale, then rotation (degrees, X then Y then Z), then translation.
export function place(g, { t = [0, 0, 0], r = [0, 0, 0], s = [1, 1, 1] } = {}) {
  if (typeof s === 'number') s = [s, s, s];
  const [rx, ry, rz] = r.map(d => d * Math.PI / 180);
  const cx = Math.cos(rx), sx = Math.sin(rx), cy = Math.cos(ry), sy = Math.sin(ry), cz = Math.cos(rz), sz = Math.sin(rz);
  const rot = (v) => {
    let [x, y, z] = v;
    [y, z] = [y * cx - z * sx, y * sx + z * cx];
    [x, z] = [x * cy + z * sy, -x * sy + z * cy];
    [x, y] = [x * cz - y * sz, x * sz + y * cz];
    return [x, y, z];
  };
  const pos = [], nor = [];
  for (let i = 0; i < g.pos.length; i += 3) {
    const p = rot([g.pos[i] * s[0], g.pos[i + 1] * s[1], g.pos[i + 2] * s[2]]);
    pos.push(p[0] + t[0], p[1] + t[1], p[2] + t[2]);
    const nn = rot([g.nor[i] / s[0], g.nor[i + 1] / s[1], g.nor[i + 2] / s[2]]);
    const l = Math.hypot(...nn) || 1;
    nor.push(nn[0] / l, nn[1] / l, nn[2] / l);
  }
  return { pos, nor, idx: g.idx.slice() };
}
export const merge = (...gs) => {
  const pos = [], nor = [], idx = [];
  for (const g of gs) { const base = pos.length / 3; pos.push(...g.pos); nor.push(...g.nor); idx.push(...g.idx.map(i => i + base)); }
  return { pos, nor, idx };
};

// ---------- model writer ----------
export class Model {
  constructor(name) { this.name = name; this.parts = []; }
  /// Adds geometry `g` in colour `hex` (e.g. '#ff8800'), optionally placed.
  add(g, hex, placement, opts = {}) { this.parts.push({ g: placement ? place(g, placement) : g, hex, opts }); return this; }
  async write(path) {
    const doc = new Document();
    const buffer = doc.createBuffer();
    const scene = doc.createScene(this.name);
    doc.getRoot().setDefaultScene(scene);
    const node = doc.createNode(this.name);
    scene.addChild(node);
    const mesh = doc.createMesh(this.name);
    node.setMesh(mesh);
    const mats = new Map();
    for (const { g, hex, opts } of this.parts) {
      const key = hex + JSON.stringify(opts);
      if (!mats.has(key)) {
        const m = doc.createMaterial(hex).setBaseColorFactor([...hexToRgb(hex), 1]).setMetallicFactor(0).setRoughnessFactor(opts.rough ?? 0.75);
        if (opts.emissive) m.setEmissiveFactor(hexToRgb(opts.emissive));
        mats.set(key, m);
      }
      const p = doc.createAccessor().setType('VEC3').setArray(new Float32Array(g.pos)).setBuffer(buffer);
      const n = doc.createAccessor().setType('VEC3').setArray(new Float32Array(g.nor)).setBuffer(buffer);
      const i = doc.createAccessor().setType('SCALAR').setArray(g.pos.length / 3 > 65535 ? new Uint32Array(g.idx) : new Uint16Array(g.idx)).setBuffer(buffer);
      mesh.addPrimitive(doc.createPrimitive().setAttribute('POSITION', p).setAttribute('NORMAL', n).setIndices(i).setMaterial(mats.get(key)));
    }
    await doc.transform(dedup(), prune(), unpartition());
    await new NodeIO().write(path, doc);
  }
}
function hexToRgb(hex) {
  const v = parseInt(hex.slice(1), 16);
  // sRGB -> linear, since baseColorFactor is linear
  return [((v >> 16) & 255) / 255, ((v >> 8) & 255) / 255, (v & 255) / 255].map(c => c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4));
}
