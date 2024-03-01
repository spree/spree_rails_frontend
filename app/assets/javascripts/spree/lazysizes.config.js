window.lazySizesConfig = window.lazySizesConfig || {}
window.lazySizesConfig.loadMode = 1
window.lazySizesConfig.init = false
window.lazySizesConfig.loadHidden = false

document.addEventListener("turbo:load", function() {
  window.lazySizes.init()
})
