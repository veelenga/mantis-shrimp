const RESET_DELAY = 2000;
const IDLE_LABEL = 'Copy';
const COPIED = { label: 'Copied', announcement: 'Commands copied to the clipboard' };
const FAILED = { label: 'Copy failed', announcement: 'Copy failed, select the commands by hand' };

export function initCopy(root) {
  const button = root.querySelector('[data-copy]');
  const source = root.querySelector('[data-copy-source]');
  const announcer = root.querySelector('[data-copy-status]');
  if (!navigator.clipboard) return;
  let timer = 0;

  function show({ label, announcement }) {
    button.textContent = label;
    announcer.textContent = announcement;
    clearTimeout(timer);
    timer = setTimeout(() => {
      button.textContent = IDLE_LABEL;
      announcer.textContent = '';
    }, RESET_DELAY);
  }

  button.hidden = false;
  button.addEventListener('click', () => {
    announcer.textContent = '';
    navigator.clipboard.writeText(source.textContent.trim()).then(
      () => show(COPIED),
      () => show(FAILED),
    );
  });
}
