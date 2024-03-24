$(() => {
  // On trunk click
  $(".btn-left").click(function() {
    $.post(`https://${GetParentResourceName()}/trunk`);
  });

  $(".btn-right").click(function() {
    $.post(`https://${GetParentResourceName()}/alarm`);
  });

  $(".btn-top").click(function(e) {
    $.post(`https://${GetParentResourceName()}/unlock`);
  });


  $(".btn-circle").click(function() {
    $.post(`https://${GetParentResourceName()}/lock`);
  });

  $(`.window`).click(function() {
    const id = $(this).data("windowid")
     $.post(`https://${GetParentResourceName()}/toggleWindow`, JSON.stringify({window: id}))
  });

  window.addEventListener(`message`, (event) => {
    if (event.data.type == "enableKeyFob") {
     $("#fob").show();
    } else if (event.data.type == "playSound") {
      const audioPlayer = new Audio(`./sounds/${event.data.file}.ogg`);
      audioPlayer.volume = event.data.volume;
      audioPlayer.play();
    }
  });

  document.onkeyup = (data) => {
    if (data.key == `Backspace` || data.key == `Escape`) {
      $.post(`https://${GetParentResourceName()}/escape`);
      $("#fob").hide();
    }
  };
});
