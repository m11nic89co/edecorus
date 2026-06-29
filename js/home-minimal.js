(function () {
  var toggler = document.querySelector('.navbar-toggler');
  var collapse = document.querySelector('.navbar-collapse');

  if (toggler && collapse) {
    toggler.addEventListener('click', function () {
      var expanded = collapse.classList.toggle('show');
      toggler.setAttribute('aria-expanded', expanded ? 'true' : 'false');
    });
  }

  function openModal(id) {
    var modal = document.getElementById(id);
    if (!modal) {
      return;
    }
    modal.classList.add('show');
    document.body.classList.add('modal-open');
  }

  function closeModal(modal) {
    if (!modal) {
      return;
    }
    modal.classList.remove('show');
    if (!document.querySelector('.modal.show')) {
      document.body.classList.remove('modal-open');
    }
  }

  document.addEventListener('click', function (event) {
    var opener = event.target.closest('[data-target="#privacyModal"]');
    if (opener) {
      event.preventDefault();
      openModal('privacyModal');
      return;
    }

    if (event.target.closest('[data-dismiss="modal"]')) {
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
})();
