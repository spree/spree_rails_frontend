document.addEventListener("turbo:load", function() {
  $('#new_spree_user').on('submit', function() {
    sessionStorage.setItem('page-invalidated', 'true')
  })
})
