(function () {
  function openModal(id) {
    var modal = document.getElementById(id);
    if (!modal || !modal.classList.contains('modal')) {
      return;
    }
    modal.classList.add('show');
    modal.setAttribute('aria-hidden', 'false');
    document.body.classList.add('modal-open');
  }

  function closeModal(modal) {
    if (!modal) {
      return;
    }
    modal.classList.remove('show');
    modal.setAttribute('aria-hidden', 'true');
    if (!document.querySelector('.modal.show')) {
      document.body.classList.remove('modal-open');
    }
  }

  var toggler = document.querySelector('.navbar-toggler');
  var collapse = document.querySelector('.navbar-collapse');
  if (toggler && collapse) {
    toggler.addEventListener('click', function () {
      var expanded = collapse.classList.toggle('show');
      toggler.setAttribute('aria-expanded', expanded ? 'true' : 'false');
    });
  }

  document.addEventListener('click', function (event) {
    var opener = event.target.closest('[data-modal-open]');
    if (opener) {
      var target = opener.getAttribute('data-modal-open');
      if (target && target.charAt(0) === '#') {
        event.preventDefault();
        openModal(target.slice(1));
      }
      return;
    }

    if (event.target.closest('[data-modal-dismiss]')) {
      closeModal(event.target.closest('.modal'));
      return;
    }

    if (event.target.classList.contains('modal') && event.target.classList.contains('show')) {
      closeModal(event.target);
    }
  });

  document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape') {
      document.querySelectorAll('.modal.show').forEach(closeModal);
    }
  });

  window.EDECORUS_MODAL = { open: openModal, close: closeModal };
})();
