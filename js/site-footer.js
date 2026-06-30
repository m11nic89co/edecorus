(function () {
  if (document.querySelector('.site-footer')) {
    return;
  }

  var footerHtml =
    '<footer class="site-footer text-white">' +
      '<div class="site-footer__inner">' +
        '<p class="site-footer__legal">&copy; 2017&ndash;2026 Торговый Дом &laquo;Ёдекор&raquo;. ОГРН 1172375087125.</p>' +
        '<p class="site-footer__rights">Все права защищены.</p>' +
        '<p class="site-footer__privacy">' +
          '<a href="#" class="site-footer__link" data-modal-open="#privacyModal">' +
            'Политика конфиденциальности. Согласие на обработку данных.' +
          '</a>' +
        '</p>' +
      '</div>' +
    '</footer>';

  var modalHtml =
    '<div class="modal" id="privacyModal" tabindex="-1" role="dialog" aria-labelledby="privacyModalLabel" aria-hidden="true">' +
      '<div class="modal__dialog modal__dialog--scrollable" role="document">' +
        '<div class="modal__content">' +
          '<div class="modal__header">' +
            '<h5 class="modal__title" id="privacyModalLabel">Политика конфиденциальности. Согласие на обработку данных.</h5>' +
            '<button type="button" class="modal__close" data-modal-dismiss aria-label="Закрыть">&times;</button>' +
          '</div>' +
          '<div class="modal__body">' +
            '<p>Согласие на обработку данных:<br>' +
            'Оставляя заявку на сайте, вы даёте согласие ООО &laquo;Ёдекор&raquo; на обработку ваших персональных данных (ФИО, контактные данные) в соответствии с Федеральным законом №152-ФЗ &laquo;О персональных данных&raquo;.</p>' +
            '<p><strong>Политика конфиденциальности</strong></p>' +
            '<p>1. Какие данные мы собираем?<br>' +
            'Мы собираем контактные, платежные и технические данные для оформления заказов, связи с клиентами и аналитики.</p>' +
            '<p>2. Цели обработки данных:<br>' +
            'Оформление и доставка заказов, связь с клиентами, персонализация контента.</p>' +
            '<p>3. Кому мы передаём данные?<br>' +
            'Данные могут передаваться курьерским службам, платежным системам и государственным органам по запросу.</p>' +
            '<p>4. Безопасность данных:<br>' +
            'Передача данных защищена HTTPS, доступ к персональным данным ограничен уполномоченными сотрудниками.</p>' +
            '<p>5. Ваши права:<br>' +
            'Вы можете запросить доступ к своим данным, их удаление и отказаться от рассылки.</p>' +
            '<p>6. Контакты:<br>' +
            'По вопросам персональных данных обращайтесь по email: <a href="mailto:info@edecorus.ru">info@edecorus.ru</a></p>' +
          '</div>' +
        '</div>' +
      '</div>' +
    '</div>';

  var mount = document.getElementById('site-footer-root');
  var html = footerHtml + modalHtml;

  if (mount) {
    mount.insertAdjacentHTML('afterend', html);
    mount.remove();
  } else {
    document.body.insertAdjacentHTML('beforeend', html);
  }
})();
