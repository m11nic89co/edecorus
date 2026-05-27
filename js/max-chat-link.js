(function () {
  var PHONE = '79615305504';
  var APP_HTTPS = 'https://max.ru/chat?phone=' + PHONE;
  var WEB_HTTPS = 'https://web.max.ru/chat?phone=' + PHONE;
  var SCHEME = 'max://max.ru/chat?phone=%2B' + PHONE;
  var ANDROID_INTENT =
    'intent://max.ru/chat?phone=' + PHONE +
    '#Intent;scheme=https;package=ru.oneme.app;S.browser_fallback_url=' +
    encodeURIComponent(APP_HTTPS) + ';end';

  function isMobile() {
    return /Android|iPhone|iPad|iPod|Mobile/i.test(navigator.userAgent);
  }

  function isAndroid() {
    return /Android/i.test(navigator.userAgent);
  }

  function isIOS() {
    return /iPhone|iPad|iPod/i.test(navigator.userAgent);
  }

  document.querySelectorAll('[data-max-chat]').forEach(function (link) {
    if (isMobile()) {
      link.setAttribute('href', APP_HTTPS);
      link.removeAttribute('target');
      link.removeAttribute('rel');

      link.addEventListener('click', function (event) {
        event.preventDefault();
        var opened = Date.now();

        if (isAndroid()) {
          window.location.href = ANDROID_INTENT;
        } else if (isIOS()) {
          window.location.href = SCHEME;
        } else {
          window.location.href = APP_HTTPS;
        }

        window.setTimeout(function () {
          if (document.visibilityState !== 'hidden' && Date.now() - opened < 2200) {
            window.location.href = APP_HTTPS;
          }
        }, 1200);
      });
    } else {
      link.setAttribute('href', WEB_HTTPS);
      link.setAttribute('target', '_blank');
      link.setAttribute('rel', 'noopener noreferrer');
    }
  });
})();
