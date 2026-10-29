'use strict';

(() => {
  const isDark = () => document.documentElement.getAttribute('data-theme') === 'dark';

  const getCellValue = (row, idx) => {
    const cell = row.cells[idx];
    return cell.getAttribute('data-sort-value') || cell.textContent.trim();
  };

  const forEachScored = (container, type, fn) => {
    for (const td of container.querySelectorAll(`td[data-type="${type}"]`)) {
      const score = parseFloat(td.getAttribute('data-score'));
      if (!isNaN(score)) {
        fn(td, score);
      }
    }
  };

  const GRADE_BASE = { F: 0, E: 1, D: 2, C: 3, B: 4, A: 5, S: 6, SS: 7 };

  const gradeRank = (input) => {
    let base = input.trim();
    let mod = 1;
    if (base.endsWith('+')) {
      mod = 2;
      base = base.slice(0, -1);
    } else if (base.endsWith('-')) {
      mod = 0;
      base = base.slice(0, -1);
    }
    return (GRADE_BASE[base] || 0) * 3 + mod;
  };

  const ratingParts = (input) => {
    const [grade, tier = ''] = input.split('/').map((part) => part.trim());
    return [
      gradeRank(grade),
      (parseInt(tier, 10) || 0) * 3 + (tier.endsWith('+') ? 2 : tier.endsWith('-') ? 0 : 1),
    ];
  };

  const COMPARATORS = {
    text: (a, b) => a.localeCompare(b, 'ja'),
    date: (a, b) => a.localeCompare(b),
    rating: (a, b) => {
      const [gradeA, tierA] = ratingParts(a);
      const [gradeB, tierB] = ratingParts(b);
      return gradeA - gradeB || tierA - tierB;
    },
  };
  const numericCmp = (a, b) => (parseFloat(a) || 0) - (parseFloat(b) || 0);

  const ASC_BY_DEFAULT = new Set(['text', 'age-rating', 'heatmap']);

  // ── Color Strategies ──
  const COLOR_STRATEGIES = {
    rating(td, score, dark) {
      const t = Math.max(0, Math.min(score / 100, 1));
      const hue = (1 - t) * 240;
      const l = dark ? 15 + t * 20 : 85 - t * 25;
      td.style.background = `hsl(${hue},70%,${l}%)`;
    },

    heatmap(td, score, dark) {
      const t = Math.min(score / 5, 1);
      if (dark) {
        td.style.background = `rgba(200,200,200,${t * 0.45})`;
        td.style.color = score >= 3 ? '#222' : '';
      } else {
        const g = Math.round(255 * (1 - t));
        td.style.background = `rgb(${g},${g},${g})`;
        td.style.color = t > 0.5 ? '#fff' : '';
      }
    },

    // Blue marks a stronger personal preference, orange a weaker one.
    delta(td, score) {
      if (score > 0) {
        const t = Math.min(score / 3, 1);
        td.style.background = `rgba(40,133,255,${t * 0.6})`;
      } else if (score < 0) {
        const t = Math.min(-score / 3, 1);
        td.style.background = `rgba(255,113,40,${t * 0.6})`;
      }
    },
  };

  // ── Table Init ──

  const initScoreTables = () => {
    for (const table of document.querySelectorAll('.score-table')) {
      const thead = table.querySelector('thead');
      const tbody = table.querySelector('tbody');
      const ths = Array.from(thead.querySelectorAll('th'));
      const scoreIndices = ['总评', '文本']
        .map((header) => ths.findIndex((th) => th.textContent.trim() === header))
        .filter((idx) => idx >= 0);

      for (const [domIdx, th] of ths.entries()) {
        if (th.classList.contains('col-rownum')) {
          continue;
        }
        const colType = th.getAttribute('data-col-type');
        const compare = COMPARATORS[colType] || numericCmp;

        th.querySelector('button').addEventListener('click', () => {
          const current = th.getAttribute('aria-sort');
          const isAsc = current ? current === 'descending' : ASC_BY_DEFAULT.has(colType);
          for (const h of ths) {
            h.removeAttribute('aria-sort');
          }
          th.setAttribute('aria-sort', isAsc ? 'ascending' : 'descending');

          const rows = Array.from(tbody.querySelectorAll('tr'));
          rows.sort((a, b) => {
            let cmp = compare(getCellValue(a, domIdx), getCellValue(b, domIdx));
            if (colType === 'rating' || domIdx === scoreIndices[0]) {
              for (const idx of scoreIndices) {
                if (cmp !== 0) {
                  break;
                }
                cmp = numericCmp(getCellValue(a, idx), getCellValue(b, idx));
              }
            }
            return isAsc ? cmp : -cmp;
          });

          const frag = document.createDocumentFragment();
          for (const row of rows) {
            frag.appendChild(row);
          }
          tbody.appendChild(frag);
        });
      }

      const applyColors = () => {
        const dark = isDark();
        for (const type of Object.keys(COLOR_STRATEGIES)) {
          forEachScored(table, type, (td, score) => COLOR_STRATEGIES[type](td, score, dark));
        }
      };

      applyColors();

      new MutationObserver(applyColors).observe(document.documentElement, {
        attributes: true,
        attributeFilter: ['data-theme'],
      });
    }
  };

  initScoreTables();
})();
