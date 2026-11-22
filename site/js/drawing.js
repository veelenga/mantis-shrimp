export const PALETTE = {
  ink: '#161A24', skin: '#D49A73', skinFar: '#B98360', shirt: '#F7F4EE', shirtFar: '#DAD6CE',
  trousers: '#3E4A63', trousersFar: '#2F3950', hair: '#262A35', shoe: '#F7F4EE',
  chair: '#8F9CAE', chairDark: '#6F7C8F', desk: '#C9D1DC', laptop: '#4A5367',
  coral: '#FF6B45', trackingGood: '#34C759', trackingIssue: '#FF9500',
};
export const OUTLINE = 5;
export const DETAIL = 3;

export const rad = (deg) => (deg * Math.PI) / 180;
export const add = (a, b) => ({ x: a.x + b.x, y: a.y + b.y });
export const sub = (a, b) => ({ x: a.x - b.x, y: a.y - b.y });
export const scale = (a, k) => ({ x: a.x * k, y: a.y * k });
export const length = (a) => Math.hypot(a.x, a.y);
export const distance = (a, b) => length(sub(b, a));
export const unit = (a) => scale(a, 1 / (length(a) || 1));
export const normal = (a) => ({ x: -a.y, y: a.x });
export const lerp = (a, b, t) => a + (b - a) * t;
export const mix = (a, b, t) => ({ x: lerp(a.x, b.x, t), y: lerp(a.y, b.y, t) });
export const rotate = (p, deg) => {
  const c = Math.cos(rad(deg));
  const s = Math.sin(rad(deg));
  return { x: p.x * c - p.y * s, y: p.x * s + p.y * c };
};
export const placer = (anchor, factor, angle) => (x, y) => add(anchor, rotate(scale({ x, y }, factor), angle));
export const fmt = (n) => Number(n.toFixed(1));
export const at = (p) => `${fmt(p.x)},${fmt(p.y)}`;

export function placedPath(commands, place) {
  return commands
    .map(([command, ...values]) => {
      const points = [];
      for (let i = 0; i < values.length; i += 2) points.push(at(place(values[i], values[i + 1])));
      return `${command}${points.join(' ')}`;
    })
    .join(' ');
}

export const stroked = (d, fill, width = OUTLINE) =>
  `<path d="${d}" fill="${fill}" stroke="${PALETTE.ink}" stroke-width="${width}" stroke-linejoin="round" stroke-linecap="round"/>`;
export const line = (d, width = DETAIL, opacity = 1) =>
  `<path d="${d}" fill="none" stroke="${PALETTE.ink}" stroke-width="${width}" stroke-linecap="round" stroke-linejoin="round" opacity="${opacity}"/>`;
export const circle = (center, radius, fill, strokeWidth = 0) => {
  const outline = strokeWidth ? ` stroke="${PALETTE.ink}" stroke-width="${strokeWidth}"` : '';
  return `<circle cx="${fmt(center.x)}" cy="${fmt(center.y)}" r="${radius}" fill="${fill}"${outline}/>`;
};

export function mixPoses(from, to, t) {
  return Object.fromEntries(Object.keys(from).map((key) => [key, lerp(from[key], to[key], t)]));
}
