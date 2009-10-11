$(document).ready(function () {
  klass = "";
  pat = "";

  $('#search_form').bind('submit', function() {
    $('#main').load('/search', 'q=' + klass + ' ' + pat);
    return false;
  });

  classes = [];
  $.get('/classes', null, function(data) {classes = data;}, 'json');

  $('#q').keyup(function(ev) {
    [klass, pat] = $(this).val().split(/\s+/);

    if (!pat) pat = "";
    klass = klass.toLowerCase();

    if ((klass.length == 0) || klass.match(/^\s+$/)) return;

    matches = $.grep(classes, function(name, i) {
      return name.toLowerCase().indexOf(klass) >= 0;
    });

    if (matches.length > 0) {
      klass = matches[0];
      $('#status').html('Find <strong>' + matches[0] + 's</strong> with "' + pat + '"');
    }
  });
});

function ajax_links() {
  $('.object-link').click(function(el) {
    $('#main').load(this.href)
    return false;
  });
}

function set_status(html) {
  $('#status').html(html);
}
