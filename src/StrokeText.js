import { gsap } from 'gsap';
import './StrokeText.css';

const DEFAULT_TEXT = 'Draw Attention';
const SHADOW_OPACITY = 0.5;

function getWipeFrames(box, wipeFrom) {
  const end = { x: box.x, y: box.y, width: box.width, height: box.height };
  if (wipeFrom === 'right') return { start: { ...end, x: box.x + box.width, width: 0 }, end };
  if (wipeFrom === 'top') return { start: { ...end, height: 0 }, end };
  if (wipeFrom === 'bottom') return { start: { ...end, y: box.y + box.height, height: 0 }, end };
  return { start: { ...end, width: 0 }, end };
}

function getDashPattern(strokeStyle, dashLength, strokeWidth) {
  const width = Math.max(Number(strokeWidth) || 0, 0.1);
  const length = Math.max(Number(dashLength) || 0, 1);
  if (strokeStyle === 'dotted') {
    const gap = Math.max(length, width * 1.8);
    return { array: `0 ${gap}`, period: gap };
  }
  if (strokeStyle === 'dashed') {
    const on = Math.max(length - width, 0.5);
    const off = length * 0.6 + width;
    return { array: `${on} ${off}`, period: on + off };
  }
  return null;
}

export function mountStrokeText(container, {
  text = DEFAULT_TEXT,
  strokeColor = '#A78BFA',
  fillColor = 'currentColor',
  strokeWidth = 1.4,
  drawDuration = 1.6,
  fillDelay = 0.2,
  stagger = 0.05,
  ease = 'power2.out',
  trigger = 'mount',
  fillMode = 'wipe',
  wipeFrom = 'left',
  fontSize = 128,
  fontWeight = 800,
  fontFamily = 'inherit',
  letterSpacing = -4,
  reverse = false,
  strokeStyle = 'solid',
  dashLength = 10,
  marching = false,
  hoverRedraw = true,
  shadow = false,
  shadowColor = null,
  className = '',
  style = {}
} = {}) {
  if (!container) return () => {};

  const baseId = Math.random().toString(36).substring(2, 9);
  const wipeId = `stroke-text-wipe-${baseId}`;
  const revealId = `stroke-text-reveal-${baseId}`;
  const erodeId = `stroke-text-erode-${baseId}`;
  const shadowId = `stroke-text-shadow-${baseId}`;

  const characters = Array.from(String(text ?? ''));
  const dash = Math.max(fontSize * 7, 200);
  const pattern = getDashPattern(strokeStyle, dashLength, strokeWidth);
  const dashArray = pattern ? pattern.array : null;
  const dashPeriod = pattern ? pattern.period : 0;
  const lift = fontSize * 0.06;
  const softness = fontSize * 0.016;
  const castShadow = shadow && fillMode !== 'none';

  const fontStyle = `font-family: ${fontFamily}; font-size: ${fontSize}px; font-weight: ${fontWeight}; letter-spacing: ${letterSpacing}px;`;
  const initViewBox = `0 ${-fontSize} 600 ${fontSize * 1.3}`;

  const strokeChars = characters.map((c, i) => `<tspan ${dashArray ? '' : 'data-stroke-char="true"'} key="s-${i}">${c === ' ' ? '&#160;' : c}</tspan>`).join('');
  const fillChars = characters.map((c, i) => `<tspan data-fill-char="true" key="f-${i}">${c === ' ' ? '&#160;' : c}</tspan>`).join('');

  container.innerHTML = `
    <span class="stroke-text ${trigger === 'hover' ? 'stroke-text--hover' : ''} ${className}".trim() role="img" aria-label="${text}">
      <svg class="stroke-text__svg" viewBox="${initViewBox}" preserveAspectRatio="xMidYMid meet" aria-hidden="true" style="visibility: hidden;">
        <defs>
          <clipPath id="${wipeId}" clipPathUnits="userSpaceOnUse">
            <rect id="wipeRect-${baseId}" x="0" y="0" width="0" height="0"></rect>
          </clipPath>
          ${dashArray ? `
          <filter id="${erodeId}" filterUnits="userSpaceOnUse">
            <feMorphology operator="erode" radius="${(Number(strokeWidth) || 1) / 2 + 0.75}"></feMorphology>
          </filter>
          <mask id="${revealId}" maskUnits="userSpaceOnUse">
            <text x="0" y="0" fill="none" stroke="#fff" stroke-width="${(Number(strokeWidth) || 1) + 2}" stroke-linejoin="round" stroke-linecap="round" style="${fontStyle}">
              ${characters.map((c, i) => `<tspan data-stroke-char key="m-${i}">${c}</tspan>`).join('')}
            </text>
            <text x="0" y="0" fill="#000" stroke="none" filter="url(#${erodeId})" style="${fontStyle}">
              ${characters.map((c, i) => `<tspan key="e-${i}">${c}</tspan>`).join('')}
            </text>
          </mask>
          ` : ''}
          ${castShadow ? `
          <filter id="${shadowId}" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
            <feDropShadow id="shadowDrop-${baseId}" dx="${lift}" dy="${lift}" stdDeviation="${softness}" flood-color="${shadowColor || strokeColor}" flood-opacity="${SHADOW_OPACITY}"></feDropShadow>
          </filter>
          ` : ''}
        </defs>
        <text id="strokeText-${baseId}" class="stroke-text__stroke" x="0" y="0" fill="none" stroke="${strokeColor}" stroke-width="${strokeWidth}" stroke-linejoin="round" stroke-linecap="round" ${dashArray ? `stroke-dasharray="${dashArray}" mask="url(#${revealId})"` : ''} style="${fontStyle}">
          ${strokeChars}
        </text>
        <g ${castShadow ? `filter="url(#${shadowId})"` : ''}>
          <text class="stroke-text__fill" x="0" y="0" fill="${fillColor || 'currentColor'}" stroke="none" style="${fontStyle}" ${fillMode === 'wipe' ? `clip-path="url(#${wipeId})"` : ''}>
            ${fillChars}
          </text>
        </g>
      </svg>
    </span>
  `;

  const root = container.querySelector('.stroke-text');
  const svg = container.querySelector('.stroke-text__svg');
  const strokeOutline = container.querySelector(`#strokeText-${baseId}`);
  const wipeRect = container.querySelector(`#wipeRect-${baseId}`);
  const dropShadow = container.querySelector(`#shadowDrop-${baseId}`);

  Object.assign(root.style, style);

  let currentBox = null;
  let timeline = null;
  let redraw = null;
  let march = null;

  function measure() {
    if (!strokeOutline) return;
    let bbox;
    try {
      bbox = strokeOutline.getBBox();
    } catch {
      return;
    }
    if (!bbox || !bbox.width) return;

    const pad = Math.max(Number(strokeWidth) || 1, fontSize * 0.1);
    const next = {
      x: bbox.x - pad,
      y: bbox.y - pad,
      width: bbox.width + pad * 2,
      height: bbox.height + pad * 2
    };

    currentBox = next;
    svg.setAttribute('viewBox', `${next.x} ${next.y} ${next.width} ${next.height}`);
    svg.style.visibility = 'visible';
    root.style.setProperty('--stroke-text-width', `${next.width}px`);

    if (wipeRect) {
      const frames = getWipeFrames(next, wipeFrom);
      wipeRect.setAttribute('x', frames.start.x);
      wipeRect.setAttribute('y', frames.start.y);
      wipeRect.setAttribute('width', frames.start.width);
      wipeRect.setAttribute('height', frames.start.height);
    }
  }

  function setupAnimation() {
    const g = typeof window !== 'undefined' ? (window.gsap || gsap) : gsap;
    if (!g || !currentBox) return;

    const strokes = g.utils.toArray(root.querySelectorAll('[data-stroke-char]'));
    const fills = g.utils.toArray(root.querySelectorAll('[data-fill-char]'));
    const wipe = wipeRect;
    const drop = dropShadow;
    if (!strokes.length) return;

    const fillEnabled = fillMode !== 'none';
    const useWipe = fillEnabled && fillMode === 'wipe';
    const fillDuration = Math.max(0.4, drawDuration * 0.5);
    const staggerConfig = reverse ? { each: stagger, from: 'end' } : stagger;
    const frames = getWipeFrames(currentBox, wipeFrom);
    const lifted = { dx: lift, dy: lift, 'flood-opacity': SHADOW_OPACITY };
    const grounded = { dx: 0, dy: 0, 'flood-opacity': 0 };
    const targets = [...strokes, ...fills, wipe, drop].filter(Boolean);

    const setStart = () => {
      g.killTweensOf(targets);
      g.set(strokes, { strokeDasharray: dash, strokeDashoffset: dash, strokeOpacity: 1 });
      g.set(fills, { opacity: useWipe ? 1 : 0 });
      if (wipe) g.set(wipe, { attr: frames.start });
      if (drop) g.set(drop, { attr: grounded });
    };

    const setEnd = () => {
      g.killTweensOf(targets);
      g.set(strokes, { strokeDasharray: dash, strokeDashoffset: 0, strokeOpacity: 1 });
      g.set(fills, { opacity: fillEnabled ? 1 : 0 });
      if (wipe) g.set(wipe, { attr: fillEnabled ? frames.end : frames.start });
      if (drop) g.set(drop, { attr: fillEnabled ? lifted : grounded });
    };

    const prefersReducedMotion = window.matchMedia?.('(prefers-reduced-motion: reduce)').matches;
    if (prefersReducedMotion) {
      setEnd();
      return;
    }

    const build = () => {
      setStart();
      const looping = trigger === 'loop';
      const tl = g.timeline({
        paused: true,
        repeat: looping ? -1 : 0,
        repeatDelay: looping ? 0.9 : 0,
        yoyo: looping,
        defaults: { overwrite: 'auto' }
      });

      tl.to(strokes, { strokeDashoffset: 0, duration: drawDuration, ease, stagger: staggerConfig }, 0);

      if (useWipe && wipe) {
        tl.to(wipe, { attr: frames.end, duration: fillDuration, ease: 'power2.inOut' }, drawDuration + fillDelay);
      } else if (fillEnabled) {
        tl.to(
          fills,
          { opacity: 1, duration: fillDuration, ease: 'power2.out', stagger: staggerConfig },
          drawDuration + fillDelay
        );
      }

      if (drop && fillEnabled) {
        tl.to(
          drop,
          { attr: lifted, duration: fillDuration * 1.4, ease: 'power3.out' },
          drawDuration + fillDelay + fillDuration * 0.3
        );
      }

      return tl;
    };

    if (trigger === 'hover') {
      setEnd();
      root.onpointerenter = () => {
        timeline?.kill();
        timeline = build();
        timeline.play(0);
      };
    } else {
      timeline = build();
      timeline.play(0);

      if (hoverRedraw && trigger !== 'loop') {
        root.onpointerenter = () => {
          if (!timeline || timeline.progress() < 1 || redraw?.isActive()) return;
          redraw?.kill();
          redraw = g.timeline()
            .to(strokes, { strokeOpacity: 0, duration: 0.2, ease: 'power1.out' })
            .set(strokes, { strokeDashoffset: dash, strokeOpacity: 1 })
            .to(strokes, { strokeDashoffset: 0, duration: drawDuration * 0.8, ease, stagger: staggerConfig });
        };
      }
    }

    if (dashArray && marching && strokeOutline) {
      march = g.fromTo(
        strokeOutline,
        { strokeDashoffset: 0 },
        { strokeDashoffset: -dashPeriod, duration: dashPeriod / (fontSize * 0.22), ease: 'none', repeat: -1 }
      );
    }
  }

  measure();
  if (document.fonts?.ready) {
    document.fonts.ready.then(() => {
      measure();
      setupAnimation();
    }).catch(() => {});
  } else {
    setupAnimation();
  }

  const observer = typeof ResizeObserver !== 'undefined' ? new ResizeObserver(() => {
    measure();
  }) : null;
  observer?.observe(container);

  return () => {
    observer?.disconnect();
    timeline?.kill();
    redraw?.kill();
    march?.kill();
  };
}

