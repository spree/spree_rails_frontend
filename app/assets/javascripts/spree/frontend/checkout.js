//= require spree/frontend/coupon_manager

Spree.disableSaveOnClick = function () {
  $('form.edit_order').on('submit', function (event) {
    if ($(this).data('submitted') === true) {
      event.preventDefault()
    } else {
      $(this).data('submitted', true)
      $(this).find(':submit, :image').removeClass('primary').addClass('disabled')
    }
  })
}

Spree.enableSave = function () {
  $('#checkout form').data('submitted', false).find(':submit, :image').attr('disabled', false).addClass('primary').removeClass('disabled')
}

document.addEventListener("turbo:load", function() {
  Spree.Checkout = {}

  var formCheckoutConfirm = $('form#checkout_form_confirm')
  if (formCheckoutConfirm.length) {
    $('form#checkout_form_confirm button#shopping-cart-coupon-code-button').off('click').on('click', function(event) {
      event.preventDefault()

      var input = {
        appliedCouponCodeField: $('#order_applied_coupon_code'),
        couponCodeField: $('#order_coupon_code'),
        couponStatus: $('#coupon_status'),
        couponButton: $('#shopping-cart-coupon-code-button'),
        removeCouponButton: $('#shopping-cart-remove-coupon-code-button')
      }

      if ($.trim(input.couponCodeField.val()).length && new CouponManager(input).applyCoupon()) {
        location.reload();
        return true
      } else {
        return false
      }
    })

    $('form#checkout_form_confirm button#shopping-cart-remove-coupon-code-button').off('click').on('click', function(event) {
      var input = {
        appliedCouponCodeField: $('#order_applied_coupon_code'),
        couponCodeField: $('#order_coupon_code'),
        couponStatus: $('#coupon_status'),
        couponButton: $('#shopping-cart-coupon-code-button'),
        removeCouponButton: $('#shopping-cart-remove-coupon-code-button')
      }

      if (new CouponManager(input).removeCoupon()) {
        return true
      } else {
        event.preventDefault()
        return false
      }
    })
  }

  return Spree.Checkout
})

$('.js-remove-credit-card').click(function() {
  if (confirm(Spree.translations.credit_card_remove_confirmation)) {
    return $.ajax({
      async: false,
      method: 'DELETE',
      url: Spree.routes.api_v2_storefront_destroy_credit_card(this.dataset.id),
      dataType: 'json',
      headers: {
        'Authorization': 'Bearer ' + SpreeAPI.oauthToken
      }
    }).done(function() {
      location.reload();
    })
  }
})
