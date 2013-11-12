(function($, window, document) {
  $("document").ready(function() {
    var openItemUp = function(){
      var prev = $('.items li.selected').prev()
      if (prev.length === 0) {
        prev = $('.items li').last();
      }
      onSelected(prev);
    };

    var openItemDown = function(){
      var next = $('.items li.selected').next()
      if (next.length === 0) {
        next = $('.items li').first()
      }
      onSelected(next);
    };

    $(document).jkey('a', function(){
      showDrawer();
    });
    $(document).jkey('w, k', function(){
      openItemUp();
    });
    $(document).jkey('s, j', function(){
      openItemDown();
    });

    var updateCount = function() {
      var all = $('ul.items li').length;
      var unread = $('ul.items li.unread').length;
      $('.unread-count').text(unread);
      $('.all-count').text(all);
    }

    updateCount();

    // Toggle Content on item list click.
    $(".items li").click(function(){
      onSelected(this);
    });

    var onSelected = function(item){
      var $this = $(item);
      var id = $this.attr('id');

      if ($this.hasClass('selected')) {
        $this.toggleClass('selected');
        $("#content_" + id).hide();
        $("#default").show();
        updateCount();
      } else {
        $this.toggleClass('selected').siblings().removeClass('selected');
        $("#main > div").hide();
        $("#content_" + id).show();

        $.ajax({
            type: "POST",
            url:  "/read",
            data: { userId: 0, itemId: id},
            success: function() {
              $this.removeClass('unread');
            }
        });
        updateCount();
      }
    };

    $("[data-action=remove-item]").click(function(){
      var $this = $(this);
      var id = $this.attr('data-id');
      $.ajax({
            type: "POST",
            url:  "/remove",
            data: { userId: 0, itemId: id},
            success: function() {
              $('[data-item-id='+id+']').hide();
              $('#content_'+id).hide();
            }
        });
    })

    $("#open_drawer").click(function() {
      var $this = $(this);
      if ($this.hasClass('open')) {
        hideDrawer();
      } else {
        showDrawer();
      }
    });

    var buildOptions = function(options){
      var form = '';
      for(var i=0; i<options.length; i++){
        var option = options[i];

        var input = '<input name="providedOptions['+option.key+']" type="'+option.type+'" />';
        var description = '<div class="description">'+option.description+'</div>';
        form += description;
        form += input;
      }

      return $(form);
    };

    $("#add_source_form").submit(function(e){
      var $this = $(this);
      var formData = $this.serialize();
      e.preventDefault();
      $("#submitting").show();
      $.ajax({
        type: "POST",
        url: $this.attr("action"),
        data: formData,
        success: function(requestedOptions) {
          $("#submitting").hide();
          if (!requestedOptions){
            $('#add_source .extra-options').hide();

            $("#add_source").append('<button class="pure-button primary-button success-message">Success!</button>').fadeIn(200);
            var handle = setTimeout(hideDrawer, 500);
            $(".success-message").click(function(){
              clearTimeout(handle);
              hideDrawer();
            });
          } else {
            $('#add_source .extra-options').show();

            var options = buildOptions(requestedOptions);
            $('.extra-options').append(options);
          }
        }
      }).fail(function(data) {
        $("#submitting").hide();
        $("#add_source")
          .append('<button class="pure-button primary-button error-message">Oops! We couldn\'t access that site.<br>Please try again</button>').fadeIn(800);
        $("#add_source_form input[name='url']").val('');
        setTimeout(function(){$(".error-message").remove()}, 8000);
      })
    })

    var post_id = '';
    var hideDrawer = function() {
      $("#nav").animate({"margin-left":"-550px"}, 200);
      $("#add_source_form input[name='url']").val('');
      $("#open_drawer").removeClass('open').text("+");
      $("#drawer_open_info").hide();
      if (post_id != ''){
        $("#content_" + post_id).show();
        post_id = '';
      } else {
        $("#default").show();
      }
      $(".success-message").remove();
    };
    var showDrawer = function() {
      post_id = $(".items li.selected").attr("id");
      $("#nav").animate({"margin-left":"-300px"}, 200);
      $("#open_drawer").addClass('open').text("-");
      $("#content_" + post_id + ", #default").hide();
      $("#drawer_open_info").show();
      $('input[name="url"]').focus()
    };

    var socket = io.connect(window.location.origin);
    var userId = $('#user_id').val();
    socket.emit('setup', userId);

    if (userId != '527fe0c26d189c092d000001') {
      $(".login").hide();
    }

    var newItems = 0;
    var $newItemsButton = $("#new_items");
    socket.on('newItems', function(item){
      newItems++;
      $newItemsButton.show();
    });

    $newItemsButton.click(function(){
      $newItemsButton.hide();
      newItems = 0;
      location.reload();
    })

  });
}(window.jQuery, window, document));
