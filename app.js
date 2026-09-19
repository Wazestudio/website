function copyInstallCommand(btn, text) {
  navigator.clipboard.writeText(text).then(() => {
    const original = btn.textContent;
    btn.textContent = 'Copié !';
    setTimeout(() => { btn.textContent = original; }, 1800);
  });
}

// Menu mobile (nav du site)
document.addEventListener('DOMContentLoaded', () => {
  const toggle = document.querySelector('.nav-toggle');
  const menu = document.querySelector('.mobile-menu');
  if (toggle && menu) {
    toggle.addEventListener('click', () => menu.classList.toggle('open'));
  }

  // Tabs "avec domaine / sans domaine" de la section installation
  const tabButtons = document.querySelectorAll('.tab-switch button');
  tabButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      tabButtons.forEach(b => b.classList.remove('active'));
      document.querySelectorAll('.install-pane').forEach(p => p.classList.remove('active'));
      btn.classList.add('active');
      document.getElementById(btn.dataset.pane).classList.add('active');
    });
  });

  // Sommaire actif de la page documentation
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
