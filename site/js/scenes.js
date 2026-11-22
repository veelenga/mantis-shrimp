import { add, distance, mix } from './drawing.js';
import { SIDE_POSES, SIDE_VIEW_BOX, renderSideFigure } from './side-figure.js';
import { FRONT_POSES, FRONT_VIEW_BOX, renderFrontFigure } from './front-figure.js';

const MIN_ARROW_TRAVEL = 4;
const LABEL_MARGIN = 90;
const ANNOTATED_SIDE_VIEW = { ...SIDE_VIEW_BOX, x: SIDE_VIEW_BOX.x - LABEL_MARGIN, width: SIDE_VIEW_BOX.width + LABEL_MARGIN };
const HEAD_ARROW_OFFSET = { x: 40, y: -34 };
const HEAD_ARROW_BEND = { x: 20, y: -50 };
const HEAD_LABEL_OFFSET = { x: 18, y: -34 };
const BACK_ARROW = { start: { x: 196, y: 330 }, bend: { x: 160, y: 420 }, tip: { x: 176, y: 512 }, visible: true };
const BACK_LABEL = { x: 68, y: 292, align: 'above' };
const BASELINE_LABEL = { x: 68, y: 98, align: 'start' };
const TILT_ARROW = { startBack: 10, startLift: 24, tipReach: 32, tipLift: 8, bendLift: 44 };
const TILT_LABEL_OFFSET = { x: 14, y: -32 };
const LIFT_ARROW = { outward: 78, startDrop: 62, tipRise: 26 };
const LIFT_LABEL_GAP = 12;
const FRONT_LABEL_INSET = 14;

const midpoint = (a, b) => mix(a, b, 0.5);

function headArrow(joints, baseline) {
  const start = add(baseline.crown, HEAD_ARROW_OFFSET);
  const tip = add(joints.crown, HEAD_ARROW_OFFSET);
  const bend = { x: midpoint(start, tip).x + HEAD_ARROW_BEND.x, y: Math.min(start.y, tip.y) + HEAD_ARROW_BEND.y };
  return { start, bend, tip, visible: distance(start, tip) >= MIN_ARROW_TRAVEL };
}

function tiltArrow(joints, baseline) {
  const side = Math.sign(joints.crown.x - baseline.crown.x) || 1;
  const start = add(baseline.crown, { x: -side * TILT_ARROW.startBack, y: -TILT_ARROW.startLift });
  const tip = add(joints.crown, { x: side * TILT_ARROW.tipReach, y: -TILT_ARROW.tipLift });
  const bend = add(midpoint(start, tip), { x: 0, y: -TILT_ARROW.bendLift });
  return { start, bend, tip, side, visible: distance(joints.crown, baseline.crown) >= MIN_ARROW_TRAVEL };
}

function liftArrow(side, shoulder) {
  return (joints, baseline) => {
    const x = baseline[shoulder].x + side * LIFT_ARROW.outward;
    const start = { x, y: baseline[shoulder].y + LIFT_ARROW.startDrop };
    const tip = { x, y: joints[shoulder].y - LIFT_ARROW.tipRise };
    const visible = baseline[shoulder].y - joints[shoulder].y >= MIN_ARROW_TRAVEL;
    return { start, bend: midpoint(start, tip), tip, side, visible };
  };
}

const tiltLabel = (arrow) => ({
  ...add(arrow.tip, { x: arrow.side * TILT_LABEL_OFFSET.x, y: TILT_LABEL_OFFSET.y }),
  align: arrow.side < 0 ? 'end' : 'start',
});

const liftLabel = (arrow) => ({
  x: arrow.side < 0 ? FRONT_VIEW_BOX.x + FRONT_LABEL_INSET : FRONT_VIEW_BOX.x + FRONT_VIEW_BOX.width - FRONT_LABEL_INSET,
  y: arrow.tip.y - LIFT_LABEL_GAP,
  align: arrow.side < 0 ? 'above' : 'above-end',
});

export const SIDE_SCENE = {
  view: SIDE_VIEW_BOX,
  annotatedView: ANNOTATED_SIDE_VIEW,
  poses: SIDE_POSES,
  render: renderSideFigure,
  ghostLayers: ['far', 'near'],
  marks: {
    baseline: { arrow: () => null, label: () => BASELINE_LABEL },
    head: { arrow: headArrow, label: (arrow) => ({ ...add(arrow.tip, HEAD_LABEL_OFFSET), align: 'start' }) },
    back: { arrow: () => BACK_ARROW, label: () => BACK_LABEL },
  },
};

export const FRONT_SCENE = {
  view: FRONT_VIEW_BOX,
  annotatedView: FRONT_VIEW_BOX,
  poses: FRONT_POSES,
  render: renderFrontFigure,
  ghostLayers: ['near'],
  marks: {
    tilt: { arrow: tiltArrow, label: tiltLabel },
    liftLeft: { arrow: liftArrow(-1, 'leftShoulder'), label: liftLabel },
    liftRight: { arrow: liftArrow(1, 'rightShoulder'), label: liftLabel },
  },
};
