(function () {
  function openModal(id) {
    var modal = document.getElementById(id);
    if (!modal) {
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

  function getModalIdFromOpener(opener) {
    var target = opener.getAttribute('data-modal-open') || opener.getAttribute('data-target');
    if (!target) {
      return null;
    }
    return target.charAt(0) === '#' ? target.slice(1) : target;
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
    var opener = event.target.closest('[data-modal-open], [data-target^="#"]');
    if (opener && getModalIdFromOpener(opener)) {
      event.preventDefault();
      openModal(getModalIdFromOpener(opener));
      return;
    }

    if (event.target.closest('[data-modal-dismiss], [data-dismiss="modal"]')) {
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
