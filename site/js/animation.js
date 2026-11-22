export const ease = (t) => (t < 0.5 ? 4 * t ** 3 : 1 - (-2 * t + 2) ** 3 / 2);

export const prefersReducedMotion = () => window.matchMedia('(prefers-reduced-motion: reduce)').matches;

export function tween(duration, onFrame) {
  const start = performance.now();
  let id = 0;
  const step = (now) => {
    const t = Math.min(1, (now - start) / duration);
    onFrame(t);
    if (t < 1) id = requestAnimationFrame(step);
  };
  id = requestAnimationFrame(step);
  return () => cancelAnimationFrame(id);
}

export function createLoop(onTick) {
  let id = 0;
  let last = 0;
  const step = (now) => {
    onTick(Math.min(now - last, 100));
    last = now;
    id = requestAnimationFrame(step);
  };
  return {
    start() {
      if (id) return;
      last = performance.now();
      id = requestAnimationFrame(step);
    },
    stop() {
      cancelAnimationFrame(id);
      id = 0;
    },
  };
}
