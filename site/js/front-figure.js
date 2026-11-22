import { DETAIL, OUTLINE, PALETTE, add, at, circle, fmt, line, placedPath, placer, scale, stroked } from './drawing.js';

const CENTER_X = 405;
const NECK_PIVOT = { x: CENTER_X, y: 418 };
const HEAD_SCALE = 0.82;
const ISSUE_LIMITS = { tilt: 8, lift: 20 };
const TRACKING_LINE = 5;
const TRACKING_DOT = { radius: 8, outline: 2.5 };
const SHOULDER_HALF_SPAN = 150;
const SHOULDER_TOP = 492;
const BOTTOM = 760;

export const FRONT_VIEW_BOX = { x: 90, y: 130, width: 630, height: 560 };

export const FRONT_POSES = {
  upright: { tilt: 0, liftLeft: 0, liftRight: 0 },
  headTiltedLeft: { tilt: -15, liftLeft: 0, liftRight: 0 },
  headTiltedRight: { tilt: 15, liftLeft: 0, liftRight: 0 },
  leftShoulderRaised: { tilt: 0, liftLeft: 38, liftRight: 0 },
  rightShoulderRaised: { tilt: 0, liftLeft: 0, liftRight: 38 },
};

const HEAD_FACE = [
  ['M', 0, -224],
  ['C', 52, -224, 86, -188, 86, -140],
  ['C', 86, -100, 78, -62, 60, -32],
  ['C', 46, -8, 24, 8, 0, 8],
  ['C', -24, 8, -46, -8, -60, -32],
  ['C', -78, -62, -86, -100, -86, -140],
  ['C', -86, -188, -52, -224, 0, -224],
  ['Z'],
];
const HEAD_HAIR = [
  ['M', -90, -122],
  ['C', -100, -200, -58, -242, 0, -242],
  ['C', 58, -242, 100, -200, 90, -122],
  ['L', 80, -128],
  ['C', 78, -156, 62, -180, 34, -186],
  ['C', 10, -190, -16, -186, -40, -176],
  ['C', -62, -168, -78, -152, -80, -128],
  ['Z'],
];
const HEAD_LINES = {
  browLeft: [['M', -54, -138], ['C', -44, -146, -30, -146, -20, -141]],
  browRight: [['M', 54, -138], ['C', 44, -146, 30, -146, 20, -141]],
  lashLeft: [['M', -48, -122], ['C', -42, -128, -30, -128, -24, -122]],
  lashRight: [['M', 48, -122], ['C', 42, -128, 30, -128, 24, -122]],
  nose: [['M', 3, -112], ['C', -2, -96, -11, -84, -6, -77], ['C', -2, -73, 5, -73, 8, -77]],
  mouth: [['M', -20, -42], ['C', -8, -37, 8, -37, 20, -42]],
};
const EARS = [{ x: -88, y: -116 }, { x: 88, y: -116 }];
const EAR_RADII = { x: 12, y: 22 };
const EYES = [{ x: -36, y: -118 }, { x: 36, y: -118 }];
const EYE_RADIUS = 4.4;
const NOSE_TIP = { x: 0, y: -82 };
const CROWN = { x: 0, y: -242 };
const NECK_HALF_WIDTH = { top: 34, bottom: 46 };
const NECK_TOP = -24;
const NECK_BOTTOM_Y = 478;

const headPlacer = (pose) => placer(NECK_PIVOT, HEAD_SCALE, pose.tilt);

function shoulders(pose) {
  return {
    left: { x: CENTER_X - SHOULDER_HALF_SPAN, y: SHOULDER_TOP - pose.liftLeft },
    right: { x: CENTER_X + SHOULDER_HALF_SPAN, y: SHOULDER_TOP - pose.liftRight },
  };
}

function shirtSide(direction, lift) {
  const x = (distance) => fmt(CENTER_X + direction * distance);
  const y = (base, share = 1) => fmt(base - lift * share);
  return {
    neck: `${x(46)},${y(452, 0.25)}`,
    toShoulder: `C${x(80)},${y(462, 0.5)} ${x(120)},${y(472)} ${x(150)},${y(486)}`,
    toArm: `C${x(178)},${y(492)} ${x(196)},${y(520, 0.8)} ${x(200)},${y(560, 0.6)}`,
    hem: `${x(214)},${BOTTOM}`,
    fromArm: `${x(200)},${y(560, 0.6)} C${x(196)},${y(520, 0.8)} ${x(178)},${y(492)} ${x(150)},${y(486)}`,
    fromShoulder: `C${x(120)},${y(472)} ${x(80)},${y(462, 0.5)} ${x(46)},${y(452, 0.25)}`,
    armpit: `M${x(150)},${BOTTOM} L${x(142)},${y(606, 0.4)}`,
  };
}

function shirt(pose) {
  const left = shirtSide(-1, pose.liftLeft);
  const right = shirtSide(1, pose.liftRight);
  const collar = `C${fmt(CENTER_X + 30)},488 ${fmt(CENTER_X - 30)},488 ${left.neck}`;
  const outline = `M${left.neck} ${left.toShoulder} ${left.toArm} L${left.hem} L${right.hem} L${right.fromArm} ${right.fromShoulder} ${collar} Z`;
  return stroked(outline, PALETTE.shirt) + line(left.armpit, DETAIL, 0.5) + line(right.armpit, DETAIL, 0.5);
}

function neck(place) {
  const top = [place(-NECK_HALF_WIDTH.top, NECK_TOP), place(NECK_HALF_WIDTH.top, NECK_TOP)];
  const bottom = [
    { x: CENTER_X + NECK_HALF_WIDTH.bottom, y: NECK_BOTTOM_Y },
    { x: CENTER_X - NECK_HALF_WIDTH.bottom, y: NECK_BOTTOM_Y },
  ];
  return stroked(`M${at(top[0])} L${at(top[1])} L${at(bottom[0])} L${at(bottom[1])} Z`, PALETTE.skin);
}

function ellipse(center, radii, angle, fill, width) {
  return `<ellipse cx="${fmt(center.x)}" cy="${fmt(center.y)}" rx="${radii.x}" ry="${radii.y}" transform="rotate(${angle} ${fmt(center.x)} ${fmt(center.y)})" fill="${fill}" stroke="${PALETTE.ink}" stroke-width="${width}"/>`;
}

function head(pose, place) {
  const detail = (commands, width = DETAIL) => line(placedPath(commands, place), width);
  const earRadii = scale(EAR_RADII, HEAD_SCALE);
  return [
    ...EARS.map((ear) => ellipse(place(ear.x, ear.y), earRadii, pose.tilt, PALETTE.skin, OUTLINE)),
    stroked(placedPath(HEAD_FACE, place), PALETTE.skin),
    stroked(placedPath(HEAD_HAIR, place), PALETTE.hair),
    detail(HEAD_LINES.browLeft, 4.5),
    detail(HEAD_LINES.browRight, 4.5),
    detail(HEAD_LINES.lashLeft),
    detail(HEAD_LINES.lashRight),
    ...EYES.map((eye) => circle(place(eye.x, eye.y), EYE_RADIUS * HEAD_SCALE, PALETTE.ink)),
    detail(HEAD_LINES.nose),
    detail(HEAD_LINES.mouth),
  ].join('');
}

function hasIssue(pose) {
  return Math.abs(pose.tilt) >= ISSUE_LIMITS.tilt || Math.max(pose.liftLeft, pose.liftRight) >= ISSUE_LIMITS.lift;
}

function trackingLine(from, to, color) {
  return `<path d="M${at(from)} L${at(to)}" stroke="${color}" stroke-width="${TRACKING_LINE}" stroke-linecap="round"/>`;
}

function tracking(points, color) {
  const { eyes, ears, nose, shoulderLine } = points;
  return [
    trackingLine(eyes[0], eyes[1], color),
    trackingLine(shoulderLine[0], shoulderLine[1], color),
    ...[...eyes, ...ears, nose, ...shoulderLine].map((point) => circle(point, TRACKING_DOT.radius, color, TRACKING_DOT.outline)),
  ].join('');
}

export function renderFrontFigure(pose) {
  const place = headPlacer(pose);
  const shoulder = shoulders(pose);
  const points = {
    eyes: EYES.map((eye) => place(eye.x, eye.y)),
    ears: EARS.map((ear) => place(ear.x, ear.y)),
    nose: place(NOSE_TIP.x, NOSE_TIP.y),
    shoulderLine: [add(shoulder.left, { x: 14, y: 22 }), add(shoulder.right, { x: -14, y: 22 })],
  };
  return {
    near: neck(place) + shirt(pose) + head(pose, place),
    overlay: tracking(points, hasIssue(pose) ? PALETTE.trackingIssue : PALETTE.trackingGood),
    joints: { crown: place(CROWN.x, CROWN.y), leftShoulder: shoulder.left, rightShoulder: shoulder.right },
  };
}
