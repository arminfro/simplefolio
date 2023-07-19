import "vanilla-hcaptcha";
import jQuery from "jquery";

export default function initForm() {
  jQuery("#form").on("submit", onSubmit);
}

function onSubmit(e) {
  e.preventDefault();
  const $constactStatus = jQuery("#contact-status");

  function onSubmitSuccess() {
    jQuery(".js-contact-field").val("");
    $constactStatus.text($constactStatus.data("success-msg"));
  }

  function onSubmitError() {
    $constactStatus.text($constactStatus.data("error-msg"));
  }

  // Make a POST request using jQuery AJAX
  jQuery.ajax({
    url: "https://mailform.your-server.com/default-target",
    type: "POST",
    data: new FormData(this),
    processData: false,
    contentType: false,
    success: onSubmitSuccess,
    error: onSubmitError,
  });
}
