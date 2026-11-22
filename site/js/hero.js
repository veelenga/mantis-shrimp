import { mixPoses } from './drawing.js';
import { SIDE_SCENE } from './scenes.js';
import { createStage } from './stage.js';
import { createLoop, ease, prefersReducedMotion } from './animation.js';

const HOLD_UPRIGHT = 2500;
const SLOUCH_IN = 1400;
const HOLD_SLOUCHED = 3500;
const SLOUCH_OUT = 1400;
const STATUS_DELAY = 400;
const NOTES_FADE_START = 0.45;
const CYCLE = HOLD_UPRIGHT + SLOUCH_IN + HOLD_SLOUCHED + SLOUCH_OUT;

const MARKS = [
  { kind: 'baseline', text: 'Your baseline' },
  { kind: 'head', text: 'Head forward' },
  { kind: 'back', text: 'Slouching' },
];

const ISSUES_TEXT = MARKS.filter((mark) => mark.kind !== 'baseline').map((mark) => mark.text).join(', ');

const DESCRIPTIONS = {
  good: 'Side view of a person sitting upright at a desk',
  bad: 'Side view of a person slouched at a desk, head pushed toward the laptop, with a faded outline of their upright posture behind',
};

function slouchAt(time) {
  const slouchEnd = HOLD_UPRIGHT + SLOUCH_IN;
  const holdEnd = slouchEnd + HOLD_SLOUCHED;
  if (time < HOLD_UPRIGHT) return 0;
  if (time < slouchEnd) return (time - HOLD_UPRIGHT) / SLOUCH_IN;
  if (time < holdEnd) return 1;
  return 1 - (time - holdEnd) / SLOUCH_OUT;
}

const isPostureBad = (time) => time >= HOLD_UPRIGHT + SLOUCH_IN + STATUS_DELAY && time < HOLD_UPRIGHT + SLOUCH_IN + HOLD_SLOUCHED;

export function initHero(root) {
  const stage = createStage(root.querySelector('svg'), root.querySelector('.notes'), SIDE_SCENE);
  const status = root.querySelector('[data-status]');
  const statusText = root.querySelector('[data-status-text]');
  const toggle = root.querySelector('[data-toggle]');
  let elapsed = 0;
  let drawnProgress = null;
  let bad = null;
  let userPaused = false;
  let onScreen = true;

  function setStatus(nextBad) {
    if (nextBad === bad) return;
    bad = nextBad;
    status.dataset.state = bad ? 'bad' : 'good';
    statusText.textContent = bad ? ISSUES_TEXT : 'Good posture';
    stage.describe(bad ? DESCRIPTIONS.bad : DESCRIPTIONS.good);
  }

  function render(time) {
    setStatus(isPostureBad(time));
    const progress = ease(slouchAt(time));
    if (progress === drawnProgress) return;
    drawnProgress = progress;
    const amount = Math.max(0, (progress - NOTES_FADE_START) / (1 - NOTES_FADE_START));
    stage.draw(mixPoses(SIDE_SCENE.poses.upright, SIDE_SCENE.poses.shrimp, progress), amount);
  }

  stage.configure({ ghost: true, marks: MARKS });

  if (prefersReducedMotion()) {
    stage.draw(SIDE_SCENE.poses.shrimp, 1);
    setStatus(true);
    toggle.hidden = true;
    return;
  }

  const loop = createLoop((delta) => {
    elapsed = (elapsed + delta) % CYCLE;
    render(elapsed);
  });

  function sync() {
    if (!userPaused && onScreen && !document.hidden) loop.start();
    else loop.stop();
    toggle.textContent = userPaused ? 'Play' : 'Pause';
  }

  toggle.addEventListener('click', () => {
    userPaused = !userPaused;
    sync();
  });
  document.addEventListener('visibilitychange', sync);
  new IntersectionObserver(([entry]) => {
    onScreen = entry.isIntersecting;
    sync();
  }).observe(root);

  render(0);
  sync();
}
