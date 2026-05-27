(function () {
  var cfg = window.EDECORUS_MAX || {};
  var PHONE_DIGITS = cfg.phoneDigits || '79882472355';
  var PHONE_DISPLAY = cfg.phoneDisplay || '+7 (988) 247-23-55';
  var PHONE_E164 = cfg.phoneE164 || '+79882472355';
  var PROFILE_URL = (cfg.profileUrl || '').trim();
  var MAX_HOME = 'https://max.ru/';
  var SHARE_URL =
    'https://max.ru/:share?text=' +
    encodeURIComponent('Здравствуйте! Торговый дом «Ёдекор». Телефон: ' + PHONE_DISPLAY);

  function isMobile() {
    return /Android|iPhone|iPad|iPod|Mobile/i.test(navigator.userAgent);
  }

  function isAndroid() {
    return /Android/i.test(navigator.userAgent);
  }

  function openInMaxApp(httpsUrl) {
    var target = httpsUrl || MAX_HOME;
    if (isAndroid()) {
      var path = target.replace(/^https?:\/\//, '');
      window.location.href =
        'intent://' +
        path +
        '#Intent;scheme=https;package=ru.oneme.app;S.browser_fallback_url=' +
        encodeURIComponent(target) +
        ';end';
      return;
    }
    window.location.href = target;
  }

  function copyText(text, onDone) {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(onDone).catch(fallbackCopy);
      return;
    }
    fallbackCopy();

    function fallbackCopy() {
      var ta = document.createElement('textarea');
      ta.value = text;
      ta.style.position = 'fixed';
      ta.style.left = '-9999px';
      document.body.appendChild(ta);
      ta.select();
      try {
        document.execCommand('copy');
        onDone();
      } catch (e) {
        /* ignore */
      }
      document.body.removeChild(ta);
    }
  }

  function showMaxModal() {
    var modal = document.getElementById('maxChatModal');
    if (!modal || !window.jQuery) {
      openInMaxApp(MAX_HOME);
      return;
    }
    window.jQuery(modal).modal('show');
  }

  function bindModalActions() {
    var btnOpen = document.getElementById('btnMaxOpenApp');
    var btnCopy = document.getElementById('btnMaxCopyPhone');
    var btnShare = document.getElementById('btnMaxShare');

    if (btnOpen && !btnOpen.dataset.bound) {
      btnOpen.dataset.bound = '1';
      btnOpen.addEventListener('click', function () {
        openInMaxApp(MAX_HOME);
      });
    }

    if (btnCopy && !btnCopy.dataset.bound) {
      btnCopy.dataset.bound = '1';
      btnCopy.addEventListener('click', function () {
        copyText(PHONE_E164, function () {
          var orig = btnCopy.innerHTML;
          btnCopy.innerHTML = '<i class="fas fa-check"></i> Скопировано';
          btnCopy.classList.add('btn-success');
          btnCopy.classList.remove('btn-secondary');
          setTimeout(function () {
            btnCopy.innerHTML = orig;
            btnCopy.classList.remove('btn-success');
            btnCopy.classList.add('btn-secondary');
          }, 1500);
        });
      });
    }

    if (btnShare && !btnShare.dataset.bound) {
      btnShare.dataset.bound = '1';
      btnShare.addEventListener('click', function () {
        openInMaxApp(SHARE_URL);
      });
    }
  }

  document.querySelectorAll('[data-max-chat]').forEach(function (link) {
    bindModalActions();

    if (PROFILE_URL) {
      link.setAttribute('href', PROFILE_URL);
      if (!isMobile()) {
        link.setAttribute('target', '_blank');
        link.setAttribute('rel', 'noopener noreferrer');
      } else {
        link.removeAttribute('target');
        link.removeAttribute('rel');
      }
      link.addEventListener('click', function (event) {
        if (!isMobile()) {
          return;
        }
        event.preventDefault();
        openInMaxApp(PROFILE_URL);
      });
      return;
    }

    link.setAttribute('href', '#');
    link.removeAttribute('target');
    link.removeAttribute('rel');

    link.addEventListener('click', function (event) {
      event.preventDefault();
      if (isMobile()) {
        copyText(PHONE_E164, showMaxModal);
      } else {
        showMaxModal();
      }
    });
  });
})();
