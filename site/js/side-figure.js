import {
  DETAIL, OUTLINE, PALETTE, add, at, circle, lerp, line, mix, normal, placedPath, placer, rad, rotate, scale, stroked, sub, unit, length,
} from './drawing.js';

const FAR_COLORS = { skin: PALETTE.skinFar, shirt: PALETTE.shirtFar, trousers: PALETTE.trousersFar, shoe: PALETTE.shirtFar };
const NEAR_COLORS = { skin: PALETTE.skin, shirt: PALETTE.shirt, trousers: PALETTE.trousers, shoe: PALETTE.shoe };
const HIP = { x: 300, y: 548 };
const KNEE = { x: 486, y: 556 };
const ANKLE = { x: 498, y: 708 };
const KEYS = { x: 506, y: 462 };
const SPINE_LENGTH = 246;
const NECK_LENGTH = 54;
const HEAD_SCALE = 0.84;
const UPPER_ARM = 142;
const FOREARM = 132;
const FAR_OFFSET = { x: 16, y: 3 };

export const SIDE_VIEW_BOX = { x: 150, y: 60, width: 720, height: 720 };

export const SIDE_POSES = {
  upright: { lean: 3, curl: 0.06, neck: 6, nod: 0 },
  headForward: { lean: 5, curl: 0.2, neck: 44, nod: 8 },
  slouching: { lean: 12, curl: 1, neck: 26, nod: 12 },
  leaningIn: { lean: 27, curl: 0.12, neck: 12, nod: 2 },
  shrimp: { lean: 20, curl: 1, neck: 40, nod: 16 },
};

const CROWN = { x: -6, y: -112 };
const upward = (deg) => ({ x: Math.sin(rad(deg)), y: -Math.cos(rad(deg)) });
function smoothPath(points, closed = true) {
  const n = points.length;
  const get = (i) => (closed ? points[(i + n) % n] : points[Math.max(0, Math.min(n - 1, i))]);
  let d = `M${at(points[0])}`;
  const segments = closed ? n : n - 1;
  for (let i = 0; i < segments; i += 1) {
    const [p0, p1, p2, p3] = [get(i - 1), get(i), get(i + 1), get(i + 2)];
    const c1 = add(p1, scale(sub(p2, p0), 1 / 6));
    const c2 = sub(p2, scale(sub(p3, p1), 1 / 6));
    d += ` C${at(c1)} ${at(c2)} ${at(p2)}`;
  }
  return closed ? `${d} Z` : d;
}

function limbOutline(from, to, radii, bulge = 0) {
  const axis = unit(sub(to, from));
  const side = normal(axis);
  const [r0, r1] = radii;
  const mid = mix(from, to, 0.42);
  const rMid = lerp(r0, r1, 0.42);
  return [
    add(from, scale(side, r0)), add(mid, scale(side, rMid + bulge)), add(to, scale(side, r1)),
    add(to, scale(axis, r1)),
    sub(to, scale(side, r1)), sub(mid, scale(side, rMid + bulge * 0.4)), sub(from, scale(side, r0)),
    sub(from, scale(axis, r0)),
  ];
}

function quadPoint(a, c, b, t) {
  return mix(mix(a, c, t), mix(c, b, t), t);
}

function solveElbow(shoulder, wrist) {
  const reach = Math.min(length(sub(wrist, shoulder)), UPPER_ARM + FOREARM - 1);
  const along = (UPPER_ARM ** 2 - FOREARM ** 2 + reach ** 2) / (2 * reach);
  const off = Math.sqrt(Math.max(UPPER_ARM ** 2 - along ** 2, 0));
  const axis = unit(sub(wrist, shoulder));
  return add(add(shoulder, scale(axis, along)), scale(normal(axis), off));
}

function skeleton(pose) {
  const chord = SPINE_LENGTH * (1 - 0.1 * pose.curl);
  const neckBase = add(HIP, scale(upward(pose.lean), chord));
  const spineMid = add(mix(HIP, neckBase, 0.5), scale(normal(upward(pose.lean)), -62 * pose.curl - 6));
  const spineTop = unit(sub(neckBase, spineMid));
  const topAngle = (Math.atan2(spineTop.x, -spineTop.y) * 180) / Math.PI;
  const neckAngle = topAngle * 0.5 + pose.lean * 0.5 + pose.neck;
  const skull = add(neckBase, scale(upward(neckAngle), NECK_LENGTH));
  const headAngle = pose.nod + neckAngle * 0.22;
  const shoulder = add(quadPoint(HIP, spineMid, neckBase, 0.9), scale(spineTop, 4));
  const elbow = solveElbow(shoulder, KEYS);
  const crown = add(skull, rotate(scale(CROWN, HEAD_SCALE), headAngle));
  const backPeak = sub(quadPoint(HIP, spineMid, neckBase, 0.55), scale(normal(unit(sub(neckBase, HIP))), 52));
  return { hip: HIP, spineMid, neckBase, skull, crown, backPeak, headAngle, shoulder, elbow, wrist: KEYS, knee: KNEE, ankle: ANKLE };
}

function torsoOutline(s) {
  const back = [];
  const front = [];
  const steps = 8;
  for (let i = 0; i <= steps; i += 1) {
    const t = i / steps;
    const p = quadPoint(s.hip, s.spineMid, s.neckBase, t);
    const tangent = unit(sub(quadPoint(s.hip, s.spineMid, s.neckBase, Math.min(t + 0.02, 1)), quadPoint(s.hip, s.spineMid, s.neckBase, Math.max(t - 0.02, 0))));
    const outward = normal(tangent);
    const backWidth = lerp(44, 22, t * t) + Math.sin(t * Math.PI) * 8;
    const frontWidth = lerp(48, 20, t * t) + Math.sin(Math.min(t * 1.3, 1) * Math.PI) * 14;
    back.push(sub(p, scale(outward, backWidth)));
    front.push(add(p, scale(outward, frontWidth)));
  }
  const cap = sub(s.hip, scale(unit(sub(s.neckBase, s.hip)), 40));
  return [cap, ...back, ...front.reverse()];
}

const HEAD_FACE = [
  ['M', 39, -86],
  ['C', 46, -78, 49, -67, 49, -58],
  ['C', 49, -54, 47, -51, 47, -48],
  ['C', 51, -42, 56, -35, 59, -29],
  ['C', 62, -25, 60, -19, 55, -19],
  ['C', 53, -19, 51, -18, 50, -16],
  ['C', 51, -11, 53, -7, 53, -3],
  ['C', 53, 2, 50, 6, 48, 10],
  ['C', 47, 13, 52, 15, 52, 21],
  ['C', 52, 27, 46, 31, 38, 30],
  ['C', 26, 29, 12, 23, 2, 14],
];
const HEAD_SKULL = [
  ['L', -3, -4],
  ['C', -14, 4, -30, 10, -36, 4],
  ['C', -44, -8, -50, -24, -50, -40],
  ['C', -50, -76, -30, -100, -4, -102],
  ['C', 16, -104, 32, -96, 39, -86],
  ['Z'],
];
const HEAD_HAIR = [
  ['M', 39, -86],
  ['C', 31, -103, 6, -113, -18, -107],
  ['C', -46, -99, -61, -72, -57, -42],
  ['C', -55, -22, -47, -6, -39, 6],
  ['L', -27, 2],
  ['C', -29, -8, -27, -18, -21, -25],
  ['C', -24, -37, -15, -47, -6, -49],
  ['C', 0, -51, 6, -49, 8, -43],
  ['L', 10, -32],
  ['L', 16, -34],
  ['C', 16, -46, 15, -58, 20, -68],
  ['C', 25, -76, 33, -79, 39, -86],
  ['Z'],
];
const HEAD_EAR = [
  ['M', -1, -43],
  ['C', -12, -49, -20, -37, -16, -26],
  ['C', -14, -18, -7, -14, -3, -20],
  ['C', 1, -27, 3, -37, -1, -43],
  ['Z'],
];
const HEAD_LINES = {
  earFold: [['M', -4, -38], ['C', -10, -39, -12, -31, -9, -26]],
  brow: [['M', 26, -58], ['C', 31, -62, 39, -62, 44, -58]],
  lash: [['M', 28, -48], ['C', 31, -51, 36, -51, 40, -49]],
  mouth: [['M', 52, -3], ['C', 48, -2, 45, -2, 42, -1]],
};
const HEAD_EYE = { x: 35, y: -46, radius: 3.4 };

const headPlacer = (s) => placer(s.skull, HEAD_SCALE, s.headAngle);

function handOutline(wrist, forearmAxis) {
  const along = unit({ x: forearmAxis.x + 0.25, y: forearmAxis.y + 0.35 });
  const side = normal(along);
  const tip = add(wrist, scale(along, 46));
  return [
    add(wrist, scale(side, -13)), add(mix(wrist, tip, 0.5), scale(side, -15)), add(tip, scale(side, -8)),
    add(tip, scale(along, 6)), add(tip, scale(side, 7)), add(mix(wrist, tip, 0.45), scale(side, 13)), add(wrist, scale(side, 13)),
  ];
}

function shoeOutline(ankle) {
  const p = (x, y) => ({ x: ankle.x + x, y: ankle.y + y });
  return [p(-24, -14), p(8, -20), p(30, -2), p(66, 10), p(80, 24), p(74, 32), p(-22, 32), p(-30, 14)];
}

const shape = (points, fill) => stroked(smoothPath(points), fill);
const rect = (x, y, w, h, r, fill) =>
  `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${r}" fill="${fill}" stroke="${PALETTE.ink}" stroke-width="${OUTLINE}" stroke-linejoin="round"/>`;

const CASTERS = [{ x: 258, y: 734, radius: 11 }, { x: 412, y: 734, radius: 11 }, { x: 335, y: 736, radius: 9 }];

function furnitureBack() {
  const backrest = smoothPath([
    { x: 214, y: 306 }, { x: 236, y: 300 }, { x: 246, y: 400 }, { x: 250, y: 520 }, { x: 240, y: 566 }, { x: 222, y: 560 }, { x: 222, y: 420 },
  ]);
  return [
    line('M335,612 L335,712 M262,728 L335,706 L408,728', 9),
    ...CASTERS.map(({ radius, ...center }) => circle(center, radius, PALETTE.ink)),
    stroked(backrest, PALETTE.chair),
    line('M236,566 L262,600', 9),
    rect(770, 496, 18, 236, 3, PALETTE.desk),
    rect(732, 728, 96, 12, 4, PALETTE.desk),
  ].join('');
}

function furnitureFront() {
  return [
    rect(214, 582, 250, 30, 14, PALETTE.chairDark),
  ].join('');
}

function deskAndLaptop() {
  return [
    rect(428, 478, 400, 20, 6, PALETTE.desk),
    stroked('M470,466 L634,466 L638,478 L466,478 Z', PALETTE.laptop),
    stroked('M626,470 L670,326 L682,330 L638,474 Z', PALETTE.laptop),
    line('M634,452 L670,338', 4, 0.35),
  ].join('');
}

function leg(s, offset, colors) {
  const hip = add(s.hip, offset);
  const knee = add(s.knee, offset);
  const ankle = add(s.ankle, offset);
  return [
    shape(shoeOutline(ankle), colors.shoe),
    line(`M${at(add(ankle, { x: -22, y: 26 }))} L${at(add(ankle, { x: 76, y: 26 }))}`, 5),
    shape(limbOutline(knee, add(ankle, { x: 0, y: -10 }), [29, 20], 5), colors.trousers),
    shape(limbOutline(add(hip, { x: -6, y: 0 }), knee, [40, 30], 4), colors.trousers),
  ].join('');
}

function arm(s, offset, colors) {
  const shoulder = add(s.shoulder, offset);
  const elbow = add(s.elbow, offset);
  const wrist = add(s.wrist, offset);
  const forearmAxis = unit(sub(wrist, elbow));
  const sleeveEnd = mix(shoulder, elbow, 0.52);
  return [
    shape(handOutline(wrist, forearmAxis), colors.skin),
    shape(limbOutline(elbow, wrist, [21, 14], 4), colors.skin),
    shape(limbOutline(shoulder, elbow, [25, 20], 3), colors.skin),
    shape(limbOutline(shoulder, sleeveEnd, [31, 27], 2), colors.shirt),
  ].join('');
}

function neck(s) {
  const place = headPlacer(s);
  return shape(limbOutline(add(s.neckBase, { x: 0, y: 16 }), place(-12, 6), [26, 21]), PALETTE.skin);
}

function head(s) {
  const place = headPlacer(s);
  const eye = place(HEAD_EYE.x, HEAD_EYE.y);
  const detail = (commands, width = DETAIL) => line(placedPath(commands, place), width);
  return [
    `<path d="${placedPath([...HEAD_FACE, ...HEAD_SKULL], place)}" fill="${PALETTE.skin}"/>`,
    detail(HEAD_FACE, OUTLINE),
    stroked(placedPath(HEAD_HAIR, place), PALETTE.hair),
    stroked(placedPath(HEAD_EAR, place), PALETTE.skin, DETAIL + 1),
    detail(HEAD_LINES.earFold, 2.5),
    detail(HEAD_LINES.brow, 4.5),
    detail(HEAD_LINES.lash),
    circle(eye, HEAD_EYE.radius * HEAD_SCALE, PALETTE.ink),
    detail(HEAD_LINES.mouth),
  ].join('');
}

function torso(s) {
  const fold = [quadPoint(s.hip, s.spineMid, s.neckBase, 0.3), quadPoint(s.hip, s.spineMid, s.neckBase, 0.5)].map((p, i) => add(p, { x: 26 + i * 6, y: 0 }));
  return [
    shape(torsoOutline(s), PALETTE.shirt),
    line(`M${at(fold[0])} Q${at(add(mix(fold[0], fold[1], 0.5), { x: 14, y: 0 }))} ${at(fold[1])}`, DETAIL, 0.4),
  ].join('');
}

const FURNITURE = { back: furnitureBack(), front: deskAndLaptop() + furnitureFront() };

export function renderSideFigure(pose) {
  const s = skeleton(pose);
  const still = { x: 0, y: 0 };
  return {
    back: FURNITURE.back,
    far: leg(s, FAR_OFFSET, FAR_COLORS) + arm(s, FAR_OFFSET, FAR_COLORS),
    front: FURNITURE.front,
    near: neck(s) + torso(s) + leg(s, still, NEAR_COLORS) + head(s) + arm(s, still, NEAR_COLORS),
    joints: s,
  };
}
