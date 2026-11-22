import { mixPoses } from './drawing.js';
import { FRONT_SCENE, SIDE_SCENE } from './scenes.js';
import { createStage } from './stage.js';
import { ease, prefersReducedMotion, tween } from './animation.js';

const MOVE_DURATION = 1100;
const VIEWS = {
  side: { scene: SIDE_SCENE, tag: 'Side view · the faded outline is your baseline', name: 'Side view' },
  front: { scene: FRONT_SCENE, tag: 'Front view · the dots are what the app tracks', name: 'Front view' },
};

function createView(root, key) {
  const { scene, tag, name } = VIEWS[key];
  const element = root.querySelector(`[data-figure="${key}"]`);
  const stage = createStage(element.querySelector('svg'), element.querySelector('.notes'), scene);
  return { element, stage, scene, tag, name, pose: scene.poses.upright };
}

export function initExplorer(root) {
  const buttons = [...root.querySelectorAll('[data-issue]')];
  const viewTag = root.querySelector('[data-view-tag]');
  const views = Object.fromEntries(Object.keys(VIEWS).map((key) => [key, createView(root, key)]));
  const reduced = prefersReducedMotion();
  let cancelMove = () => {};

  function activate(active) {
    Object.values(views).forEach((view) => {
      view.element.hidden = view !== active;
      if (view !== active) view.pose = view.scene.poses.upright;
    });
    viewTag.textContent = active.tag;
  }

  function show(button) {
    const { view: key, pose: poseName, mark } = button.dataset;
    const label = button.querySelector('.issue-name').textContent;
    const view = views[key];
    const from = view.pose;
    const target = view.scene.poses[poseName];
    activate(view);
    view.stage.configure({ ghost: true, marks: [{ kind: mark, text: label }] });
    view.stage.describe(`${view.name} of a person at a desk showing ${label.toLowerCase()}, with a faded outline of their upright posture behind`);
    if (reduced) {
      view.pose = target;
      view.stage.draw(target, 1);
      return;
    }
    cancelMove = tween(MOVE_DURATION, (t) => {
      const eased = ease(t);
      view.pose = mixPoses(from, target, eased);
      view.stage.draw(view.pose, eased);
    });
  }

  function select(button) {
    cancelMove();
    buttons.forEach((item) => item.setAttribute('aria-pressed', String(item === button)));
    show(button);
  }

  buttons.forEach((button) => button.addEventListener('click', () => select(button)));
  select(buttons.find((button) => button.getAttribute('aria-pressed') === 'true') ?? buttons[0]);
}
