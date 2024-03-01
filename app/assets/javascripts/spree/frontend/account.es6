const fetchAccount = () => {
  return $.ajax({
    url: Spree.localizedPathFor('account_link')
  }).done(function (data) {
    return $('#link-to-account').html(data)
  })
}

document.addEventListener("turbo:load", fetchAccount)
