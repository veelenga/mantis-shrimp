import { PALETTE, add, normal, scale, sub, unit } from './drawing.js';

const LAYERS = ['back', 'ghost', 'far', 'front', 'near', 'overlay', 'arrows'];
const FIGURE_LAYERS = ['back', 'far', 'front', 'near', 'overlay'];
const GHOST_OPACITY = 0.2;
const ARROW_WIDTH = 8;
const ARROW_HEAD_LENGTH = 30;
const ARROW_HEAD_HALF_WIDTH = 13;
const ARROW_SHAFT_INSET = 18;

function arrowMarkup({ start, bend, tip }) {
  const direction = unit(sub(tip, bend));
  const back = (amount) => sub(tip, scale(direction, amount));
  const halfWidth = scale(normal(direction), ARROW_HEAD_HALF_WIDTH);
  const shaftEnd = back(ARROW_SHAFT_INSET);
  const left = add(back(ARROW_HEAD_LENGTH), halfWidth);
  const right = sub(back(ARROW_HEAD_LENGTH), halfWidth);
  const { coral } = PALETTE;
  return (
    `<path d="M${start.x},${start.y} Q${bend.x},${bend.y} ${shaftEnd.x},${shaftEnd.y}" fill="none" stroke="${coral}" stroke-width="${ARROW_WIDTH}" stroke-linecap="round"/>` +
    `<polygon points="${tip.x},${tip.y} ${left.x},${left.y} ${right.x},${right.y}" fill="${coral}" stroke="${coral}" stroke-width="2" stroke-linejoin="round"/>`
  );
}

const toPercent = (value, origin, size) => `${(((value - origin) / size) * 100).toFixed(2)}%`;

export function createStage(svg, notes, scene) {
  const view = notes ? scene.annotatedView : scene.view;
  const baseline = scene.render(scene.poses.upright);
  const ghostMarkup = `<g opacity="${GHOST_OPACITY}">${scene.ghostLayers.map((name) => baseline[name]).join('')}</g>`;
  svg.setAttribute('viewBox', `${view.x} ${view.y} ${view.width} ${view.height}`);
  svg.innerHTML = LAYERS.map((name) => `<g data-layer="${name}"></g>`).join('');
  const layer = Object.fromEntries(LAYERS.map((name) => [name, svg.querySelector(`[data-layer="${name}"]`)]));
  const drawn = {};
  let marks = [];
  let labels = [];

  function configure({ ghost = false, marks: nextMarks = [] } = {}) {
    marks = nextMarks;
    layer.ghost.innerHTML = ghost ? ghostMarkup : '';
    if (!notes) return;
    labels = marks.map((mark) => {
      const label = document.createElement('span');
      label.className = 'note';
      label.textContent = mark.text;
      return label;
    });
    notes.replaceChildren(...labels);
  }

  function placeLabel(label, anchor, amount) {
    label.dataset.align = anchor.align;
    label.style.left = toPercent(anchor.x, view.x, view.width);
    label.style.top = toPercent(anchor.y, view.y, view.height);
    label.style.opacity = amount;
  }

  function drawMarks(joints, amount) {
    const arrows = marks.map((mark) => scene.marks[mark.kind].arrow(joints, baseline.joints));
    layer.arrows.innerHTML = arrows.filter((arrow) => arrow?.visible).map(arrowMarkup).join('');
    layer.arrows.setAttribute('opacity', amount);
    marks.forEach((mark, index) => placeLabel(labels[index], scene.marks[mark.kind].label(arrows[index]), amount));
  }

  function draw(pose, amount = 1) {
    const figure = scene.render(pose);
    FIGURE_LAYERS.forEach((name) => {
      const markup = figure[name] ?? '';
      if (drawn[name] === markup) return;
      drawn[name] = markup;
      layer[name].innerHTML = markup;
    });
    drawMarks(figure.joints, amount);
  }

  function describe(text) {
    svg.setAttribute('aria-label', text);
  }

  return { configure, draw, describe };
}
