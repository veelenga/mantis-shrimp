import { SIDE_SCENE } from './scenes.js';
import { createStage } from './stage.js';
import { initHero } from './hero.js';
import { initExplorer } from './explorer.js';
import { initCopy } from './install.js';

function initCalibrateFigure(root) {
  const stage = createStage(root.querySelector('svg'), null, SIDE_SCENE);
  stage.draw(SIDE_SCENE.poses.upright);
  stage.describe('Side view of a person sitting upright at a desk');
}

initHero(document.querySelector('[data-hero]'));
initExplorer(document.querySelector('[data-explorer]'));
initCalibrateFigure(document.querySelector('[data-calibrate]'));
initCopy(document.querySelector('[data-install]'));
