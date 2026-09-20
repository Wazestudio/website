function copyInstallCommand(btn, text) {
  navigator.clipboard.writeText(text).then(() => {
    const original = btn.textContent;
    btn.textContent = 'Copied!';
    setTimeout(() => { btn.textContent = original; }, 1800);
  });
}

// Mobile nav menu
document.addEventListener('DOMContentLoaded', () => {
  const toggle = document.querySelector('.nav-toggle');
  const menu = document.querySelector('.mobile-menu');
  if (toggle && menu) {
    toggle.addEventListener('click', () => menu.classList.toggle('open'));
  }

  // "With a domain / by IP" tabs in the installation section
  const tabButtons = document.querySelectorAll('.tab-switch button');
  tabButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      tabButtons.forEach(b => b.classList.remove('active'));
      document.querySelectorAll('.install-pane').forEach(p => p.classList.remove('active'));
      btn.classList.add('active');
      document.getElementById(btn.dataset.pane).classList.add('active');
    });
  });

  // Active table-of-contents entry on the docs page
  const tocLinks = Array.from(document.querySelectorAll('.docs-toc a'));
  if (tocLinks.length === 0) return;
  const sections = tocLinks
    .map(a => document.querySelector(a.getAttribute('href')))
    .filter(Boolean);

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        tocLinks.forEach(a => a.classList.remove('active'));
        const match = tocLinks.find(a => a.getAttribute('href') === '#' + entry.target.id);
        if (match) match.classList.add('active');
      }
    });
  }, { rootMargin: '-100px 0px -70% 0px' });

  sections.forEach(s => observer.observe(s));
});
